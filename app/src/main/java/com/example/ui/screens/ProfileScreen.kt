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
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.AppRepository
import com.example.ui.theme.*
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProfileScreen(
    repository: AppRepository,
    onBack: () -> Unit,
    onLogout: () -> Unit,
    onShowMessage: (String) -> Unit
) {
    val scope = rememberCoroutineScope()
    var isRefreshingToken by remember { mutableStateOf(false) }
    var showServerDialog by remember { mutableStateOf(false) }
    var tempBaseUrl by remember { mutableStateOf(repository.baseUrl) }

    if (showServerDialog) {
        AlertDialog(
            onDismissRequest = { showServerDialog = false },
            title = { Text("Server Endpoint Configuration", fontWeight = FontWeight.Bold) },
            text = {
                Column {
                    Text("Change OpenAPI OAS 3.1 backend URL:", fontSize = 13.sp, color = SlateMuted)
                    Spacer(modifier = Modifier.height(10.dp))
                    OutlinedTextField(
                        value = tempBaseUrl,
                        onValueChange = { tempBaseUrl = it },
                        label = { Text("Base URL") },
                        singleLine = true,
                        modifier = Modifier.fillMaxWidth()
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        FilterChip(
                            selected = tempBaseUrl == "http://10.0.2.2:8081",
                            onClick = { tempBaseUrl = "http://10.0.2.2:8081" },
                            label = { Text("10.0.2.2:8081") }
                        )
                        FilterChip(
                            selected = tempBaseUrl == "http://localhost:8081",
                            onClick = { tempBaseUrl = "http://localhost:8081" },
                            label = { Text("localhost:8081") }
                        )
                    }
                }
            },
            confirmButton = {
                Button(
                    onClick = {
                        repository.baseUrl = tempBaseUrl
                        showServerDialog = false
                        onShowMessage("Base URL updated to ${repository.baseUrl}")
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = NavyPrimary)
                ) {
                    Text("Save")
                }
            },
            dismissButton = {
                TextButton(onClick = { showServerDialog = false }) { Text("Cancel") }
            }
        )
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("University Account", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = NavyPrimary,
                    titleContentColor = Color.White,
                    navigationIconContentColor = Color.White
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
                .padding(20.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Profile Header
            Surface(
                shape = CircleShape,
                color = NavyPrimary,
                modifier = Modifier.size(80.dp)
            ) {
                Box(contentAlignment = Alignment.Center) {
                    Icon(
                        Icons.Default.Person,
                        contentDescription = "Avatar",
                        tint = AmberAccent,
                        modifier = Modifier.size(46.dp)
                    )
                }
            }

            Spacer(modifier = Modifier.height(14.dp))

            Text(
                text = repository.currentUserName ?: "Campus Student",
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold,
                color = TextPrimary
            )

            Text(
                text = repository.currentUserEmail ?: "student@university.edu",
                fontSize = 14.sp,
                color = SlateMuted
            )

            Spacer(modifier = Modifier.height(6.dp))

            Surface(
                shape = RoundedCornerShape(12.dp),
                color = AmberAccent.copy(alpha = 0.15f),
                border = BorderStroke(1.dp, AmberAccent.copy(alpha = 0.5f))
            ) {
                Text(
                    text = repository.currentUserRole ?: "STUDENT",
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color(0xFF92400E),
                    modifier = Modifier.padding(horizontal = 10.dp, vertical = 4.dp)
                )
            }

            Spacer(modifier = Modifier.height(24.dp))

            // Card 1: University Identity Details
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(14.dp),
                colors = CardDefaults.cardColors(containerColor = SurfaceLight),
                border = BorderStroke(1.dp, SlateBorder)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("University Credentials", fontWeight = FontWeight.Bold, fontSize = 15.sp, color = TextPrimary)
                    Spacer(modifier = Modifier.height(12.dp))

                    ProfileDetailRow(
                        icon = Icons.Outlined.Email,
                        label = "Uni Email",
                        value = repository.currentUserEmail ?: "student@university.edu"
                    )

                    HorizontalDivider(modifier = Modifier.padding(vertical = 8.dp), color = SlateSubtle)

                    ProfileDetailRow(
                        icon = Icons.Outlined.School,
                        label = "Department",
                        value = repository.currentDepartment ?: "Computer Science & Engineering"
                    )

                    HorizontalDivider(modifier = Modifier.padding(vertical = 8.dp), color = SlateSubtle)

                    ProfileDetailRow(
                        icon = Icons.Outlined.Badge,
                        label = "Registration ID",
                        value = repository.currentRegNumber?.toString() ?: "20241042"
                    )

                    HorizontalDivider(modifier = Modifier.padding(vertical = 8.dp), color = SlateSubtle)

                    ProfileDetailRow(
                        icon = Icons.Outlined.Fingerprint,
                        label = "User UUID",
                        value = repository.currentUserId?.take(18)?.let { "$it..." } ?: "3fa85f64-5717..."
                    )
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Card 2: OAS 3.1 Session & Token Card
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(14.dp),
                colors = CardDefaults.cardColors(containerColor = SurfaceLight),
                border = BorderStroke(1.dp, SlateBorder)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("API Session & Authentication", fontWeight = FontWeight.Bold, fontSize = 15.sp, color = TextPrimary)
                    Spacer(modifier = Modifier.height(12.dp))

                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Outlined.Key, contentDescription = null, tint = NavyPrimary, modifier = Modifier.size(20.dp))
                        Spacer(modifier = Modifier.width(10.dp))
                        Column(modifier = Modifier.weight(1f)) {
                            Text("Access Token", fontSize = 11.sp, color = SlateMuted)
                            Text(
                                if (repository.accessToken != null) "Bearer (Active session)" else "No active token",
                                fontSize = 13.sp,
                                fontWeight = FontWeight.Medium,
                                color = if (repository.accessToken != null) Color(0xFF166534) else StatusLostText
                            )
                        }

                        // Refresh Token Button: POST /api/uni/v1/auth/refresh
                        Button(
                            onClick = {
                                isRefreshingToken = true
                                scope.launch {
                                    val result = repository.refresh()
                                    isRefreshingToken = false
                                    if (result.isSuccess) {
                                        onShowMessage("Token refreshed via /api/uni/v1/auth/refresh!")
                                    } else {
                                        onShowMessage("Refresh failed")
                                    }
                                }
                            },
                            contentPadding = PaddingValues(horizontal = 10.dp, vertical = 2.dp),
                            modifier = Modifier.height(34.dp),
                            shape = RoundedCornerShape(8.dp),
                            colors = ButtonDefaults.buttonColors(containerColor = NavyPrimary),
                            enabled = !isRefreshingToken
                        ) {
                            if (isRefreshingToken) {
                                CircularProgressIndicator(color = Color.White, modifier = Modifier.size(16.dp))
                            } else {
                                Icon(Icons.Default.Refresh, contentDescription = null, modifier = Modifier.size(14.dp))
                                Spacer(modifier = Modifier.width(4.dp))
                                Text("Refresh", fontSize = 12.sp)
                            }
                        }
                    }

                    HorizontalDivider(modifier = Modifier.padding(vertical = 10.dp), color = SlateSubtle)

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Column {
                            Text("Backend Base URL", fontSize = 11.sp, color = SlateMuted)
                            Text(repository.baseUrl, fontSize = 13.sp, fontWeight = FontWeight.Medium)
                        }

                        TextButton(onClick = { showServerDialog = true }) {
                            Text("Edit", color = NavyPrimary, fontWeight = FontWeight.Bold)
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(28.dp))

            // Logout Button: POST /api/uni/v1/auth/logout
            OutlinedButton(
                onClick = {
                    scope.launch {
                        repository.logout()
                        onLogout()
                    }
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(50.dp)
                    .testTag("logout_button"),
                shape = RoundedCornerShape(12.dp),
                border = BorderStroke(1.dp, StatusLostText),
                colors = ButtonDefaults.outlinedButtonColors(contentColor = StatusLostText)
            ) {
                Icon(Icons.Default.ExitToApp, contentDescription = null, tint = StatusLostText)
                Spacer(modifier = Modifier.width(8.dp))
                Text("Sign Out of UniTrace", fontWeight = FontWeight.Bold, color = StatusLostText, fontSize = 15.sp)
            }
        }
    }
}

@Composable
private fun ProfileDetailRow(icon: androidx.compose.ui.graphics.vector.ImageVector, label: String, value: String) {
    Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.fillMaxWidth()) {
        Icon(icon, contentDescription = null, tint = NavyPrimary, modifier = Modifier.size(20.dp))
        Spacer(modifier = Modifier.width(10.dp))
        Column {
            Text(label, fontSize = 11.sp, color = SlateMuted)
            Text(value, fontSize = 13.sp, fontWeight = FontWeight.Medium, color = TextPrimary)
        }
    }
}
