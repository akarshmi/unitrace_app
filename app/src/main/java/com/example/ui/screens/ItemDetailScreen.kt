package com.example.ui.screens

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import com.example.data.AppRepository
import com.example.data.ItemResponse
import com.example.ui.components.StatusPill
import com.example.ui.components.TypeBadge
import com.example.ui.theme.*
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ItemDetailScreen(
    item: ItemResponse,
    repository: AppRepository,
    onBack: () -> Unit,
    onStatusUpdated: (ItemResponse) -> Unit,
    onShowMessage: (String) -> Unit
) {
    var currentItem by remember { mutableStateOf(item) }
    var showStatusDialog by remember { mutableStateOf(false) }
    var isUpdatingStatus by remember { mutableStateOf(false) }
    val scope = rememberCoroutineScope()

    val isLost = currentItem.type.equals("LOST", ignoreCase = true)
    val isClosed = currentItem.status.equals("CLOSED", ignoreCase = true)

    if (showStatusDialog) {
        val oasStatuses = listOf("OPEN", "MATCHED", "CLAIMED", "CLOSED")
        AlertDialog(
            onDismissRequest = { showStatusDialog = false },
            title = { Text("Update Case Status", fontWeight = FontWeight.Bold) },
            text = {
                Column {
                    Text(
                        "Select new OAS 3.1 status for this item:",
                        fontSize = 13.sp,
                        color = SlateMuted
                    )
                    Spacer(modifier = Modifier.height(12.dp))
                    oasStatuses.forEach { statusOption ->
                        Surface(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(vertical = 4.dp),
                            shape = RoundedCornerShape(8.dp),
                            color = if (currentItem.status == statusOption) NavyPrimary.copy(alpha = 0.1f) else SlateSubtle,
                            border = if (currentItem.status == statusOption) BorderStroke(1.dp, NavyPrimary) else null,
                            onClick = {
                                showStatusDialog = false
                                isUpdatingStatus = true
                                scope.launch {
                                    val result = repository.updateStatus(currentItem.id, statusOption)
                                    isUpdatingStatus = false
                                    if (result.isSuccess) {
                                        val updated = result.getOrNull()!!
                                        currentItem = updated
                                        onStatusUpdated(updated)
                                        onShowMessage("Status updated to $statusOption")
                                    } else {
                                        onShowMessage("Failed to update status")
                                    }
                                }
                            }
                        ) {
                            Row(
                                modifier = Modifier.padding(horizontal = 14.dp, vertical = 10.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                StatusPill(status = statusOption)
                                Spacer(modifier = Modifier.width(12.dp))
                                Text(
                                    statusOption,
                                    fontWeight = FontWeight.SemiBold,
                                    color = TextPrimary
                                )
                                Spacer(modifier = Modifier.weight(1f))
                                if (currentItem.status == statusOption) {
                                    Icon(Icons.Default.Check, contentDescription = null, tint = NavyPrimary)
                                }
                            }
                        }
                    }
                }
            },
            confirmButton = {},
            dismissButton = {
                TextButton(onClick = { showStatusDialog = false }) {
                    Text("Cancel")
                }
            }
        )
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(if (isLost) "Lost Item Case" else "Found Item Case", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                },
                actions = {
                    IconButton(
                        onClick = { showStatusDialog = true },
                        modifier = Modifier.testTag("change_status_top_button")
                    ) {
                        Icon(Icons.Outlined.EditNote, contentDescription = "Change Status", tint = Color.White)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = NavyPrimary,
                    titleContentColor = Color.White,
                    navigationIconContentColor = Color.White,
                    actionIconContentColor = Color.White
                )
            )
        },
        containerColor = SlateBackground
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .verticalScroll(rememberScrollState())
        ) {
            // Photo Header
            if (!currentItem.imageUrl.isNullOrEmpty()) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(240.dp)
                ) {
                    AsyncImage(
                        model = currentItem.imageUrl,
                        contentDescription = currentItem.title,
                        contentScale = ContentScale.Crop,
                        modifier = Modifier.fillMaxSize()
                    )
                }
            } else {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(160.dp)
                        .background(SlateSubtle),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Icon(
                            if (isLost) Icons.Default.Search else Icons.Outlined.Inventory2,
                            contentDescription = null,
                            tint = SlateMuted,
                            modifier = Modifier.size(48.dp)
                        )
                        Spacer(modifier = Modifier.height(6.dp))
                        Text("No photo provided for this case", fontSize = 12.sp, color = SlateMuted)
                    }
                }
            }

            // Main Content Body
            Column(modifier = Modifier.padding(20.dp)) {
                // Badges Row
                Row(verticalAlignment = Alignment.CenterVertically) {
                    TypeBadge(
                        type = currentItem.type,
                        fontSize = 12.sp,
                        horizontalPadding = 10.dp,
                        verticalPadding = 4.dp
                    )

                    Spacer(modifier = Modifier.width(8.dp))

                    StatusPill(
                        status = currentItem.status,
                        fontSize = 12.sp,
                        horizontalPadding = 10.dp,
                        verticalPadding = 4.dp
                    )

                    Spacer(modifier = Modifier.weight(1f))

                    // Quick status edit button
                    OutlinedButton(
                        onClick = { showStatusDialog = true },
                        contentPadding = PaddingValues(horizontal = 10.dp, vertical = 2.dp),
                        modifier = Modifier.height(32.dp),
                        colors = ButtonDefaults.outlinedButtonColors(contentColor = NavyPrimary)
                    ) {
                        Icon(Icons.Default.Edit, contentDescription = null, modifier = Modifier.size(14.dp))
                        Spacer(modifier = Modifier.width(4.dp))
                        Text("Status", fontSize = 12.sp, fontWeight = FontWeight.Bold)
                    }
                }

                Spacer(modifier = Modifier.height(14.dp))

                // Title
                Text(
                    text = currentItem.title,
                    fontSize = 22.sp,
                    fontWeight = FontWeight.Bold,
                    color = TextPrimary
                )

                Spacer(modifier = Modifier.height(14.dp))

                // Location Card
                Surface(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(10.dp),
                    color = SurfaceLight,
                    border = BorderStroke(1.dp, SlateBorder)
                ) {
                    Row(
                        modifier = Modifier.padding(12.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(Icons.Default.LocationOn, contentDescription = null, tint = NavyPrimary, modifier = Modifier.size(24.dp))
                        Spacer(modifier = Modifier.width(10.dp))
                        Column {
                            Text("Location Reported", fontSize = 11.sp, color = SlateMuted, fontWeight = FontWeight.SemiBold)
                            Text(
                                currentItem.location.ifEmpty { "Main Campus Grounds" },
                                fontSize = 14.sp,
                                fontWeight = FontWeight.Medium,
                                color = TextPrimary
                            )
                            if (currentItem.geoLocation != null) {
                                Text(
                                    "GPS: ${currentItem.geoLocation?.latitude}, ${currentItem.geoLocation?.longitude}",
                                    fontSize = 11.sp,
                                    color = NavyPrimary
                                )
                            }
                        }
                    }
                }

                // Timing Card (eventFrom to eventTo)
                if (!currentItem.eventFrom.isNullOrEmpty() || !currentItem.createdAt.isNullOrEmpty()) {
                    Spacer(modifier = Modifier.height(10.dp))
                    Surface(
                        modifier = Modifier.fillMaxWidth(),
                        shape = RoundedCornerShape(10.dp),
                        color = SurfaceLight,
                        border = BorderStroke(1.dp, SlateBorder)
                    ) {
                        Row(
                            modifier = Modifier.padding(12.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Icon(Icons.Outlined.AccessTime, contentDescription = null, tint = NavyPrimary, modifier = Modifier.size(24.dp))
                            Spacer(modifier = Modifier.width(10.dp))
                            Column {
                                Text("Incident Time / Reported At", fontSize = 11.sp, color = SlateMuted, fontWeight = FontWeight.SemiBold)
                                val timeText = when {
                                    !currentItem.eventFrom.isNullOrEmpty() && !currentItem.eventTo.isNullOrEmpty() ->
                                        "${currentItem.eventFrom} - ${currentItem.eventTo}"
                                    !currentItem.eventFrom.isNullOrEmpty() -> currentItem.eventFrom!!
                                    else -> currentItem.createdAt ?: "N/A"
                                }
                                Text(timeText, fontSize = 13.sp, color = TextPrimary)
                            }
                        }
                    }
                }

                Spacer(modifier = Modifier.height(16.dp))

                // Description
                Text("Case Description", fontSize = 15.sp, fontWeight = FontWeight.Bold, color = TextPrimary)
                Spacer(modifier = Modifier.height(6.dp))
                Text(
                    text = if (currentItem.description.isNotEmpty()) currentItem.description else "No description provided.",
                    fontSize = 14.sp,
                    color = TextBody,
                    lineHeight = 20.sp
                )

                Spacer(modifier = Modifier.height(20.dp))

                // Reporter Info Card
                Surface(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(10.dp),
                    color = SlateSubtle
                ) {
                    Row(
                        modifier = Modifier.padding(12.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Surface(
                            shape = CircleShape,
                            color = NavyPrimary.copy(alpha = 0.1f),
                            modifier = Modifier.size(36.dp)
                        ) {
                            Box(contentAlignment = Alignment.Center) {
                                Icon(Icons.Default.Person, contentDescription = null, tint = NavyPrimary, modifier = Modifier.size(20.dp))
                            }
                        }
                        Spacer(modifier = Modifier.width(10.dp))
                        Column {
                            Text("Reported By", fontSize = 11.sp, color = SlateMuted)
                            Text(
                                currentItem.reportedByName ?: "Verified University Student",
                                fontSize = 14.sp,
                                fontWeight = FontWeight.SemiBold,
                                color = TextPrimary
                            )
                        }
                    }
                }

                Spacer(modifier = Modifier.height(28.dp))

                // Actions
                if (isClosed) {
                    Surface(
                        modifier = Modifier.fillMaxWidth(),
                        shape = RoundedCornerShape(10.dp),
                        color = StatusClosedBg,
                        border = BorderStroke(1.dp, StatusClosedBorder)
                    ) {
                        Box(
                            modifier = Modifier.padding(14.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                "This item case is Closed & Resolved",
                                fontWeight = FontWeight.Bold,
                                color = StatusClosedText
                            )
                        }
                    }
                } else {
                    Button(
                        onClick = { showStatusDialog = true },
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(50.dp)
                            .testTag("update_status_button"),
                        shape = RoundedCornerShape(12.dp),
                        colors = ButtonDefaults.buttonColors(containerColor = NavyPrimary)
                    ) {
                        Icon(Icons.Default.SyncAlt, contentDescription = null)
                        Spacer(modifier = Modifier.width(8.dp))
                        Text("Update Item Status", fontWeight = FontWeight.Bold, fontSize = 15.sp)
                    }

                    Spacer(modifier = Modifier.height(10.dp))

                    OutlinedButton(
                        onClick = {
                            onShowMessage("Direct message initiated with reporter ${currentItem.reportedByName ?: "campus member"}")
                        },
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(50.dp)
                            .testTag("contact_reporter_button"),
                        shape = RoundedCornerShape(12.dp),
                        border = BorderStroke(1.dp, NavyPrimary)
                    ) {
                        Icon(Icons.Default.Email, contentDescription = null, tint = NavyPrimary)
                        Spacer(modifier = Modifier.width(8.dp))
                        Text("Contact Reporter", fontWeight = FontWeight.Bold, color = NavyPrimary, fontSize = 15.sp)
                    }
                }
            }
        }
    }
}
