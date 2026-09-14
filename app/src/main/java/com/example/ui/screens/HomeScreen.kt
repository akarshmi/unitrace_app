package com.example.ui.screens

import androidx.compose.animation.*
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.material3.pulltorefresh.PullToRefreshBox
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
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
fun HomeScreen(
    repository: AppRepository,
    onCreateItem: (type: String) -> Unit,
    onItemClick: (ItemResponse) -> Unit,
    onNavigateToProfile: () -> Unit,
    onLogout: () -> Unit,
    onShowMessage: (String) -> Unit
) {
    var selectedType by remember { mutableStateOf("LOST") } // LOST or FOUND
    var selectedStatus by remember { mutableStateOf("ALL") } // ALL, OPEN, MATCHED, CLAIMED, CLOSED
    var searchQuery by remember { mutableStateOf("") }
    var itemsList by remember { mutableStateOf<List<ItemResponse>>(emptyList()) }
    var isRefreshing by remember { mutableStateOf(false) }
    var isLoading by remember { mutableStateOf(true) }

    val scope = rememberCoroutineScope()

    fun loadData() {
        scope.launch {
            isLoading = true
            val statusParam = if (selectedStatus == "ALL") null else selectedStatus
            val result = repository.getItems(type = selectedType, status = statusParam)
            isLoading = false
            isRefreshing = false
            if (result.isSuccess) {
                itemsList = result.getOrNull() ?: emptyList()
            } else {
                onShowMessage("Unable to load items from server")
            }
        }
    }

    LaunchedEffect(selectedType, selectedStatus) {
        loadData()
    }

    val filteredItems = itemsList.filter { item ->
        if (searchQuery.isBlank()) true
        else item.title.contains(searchQuery, ignoreCase = true) ||
                item.description.contains(searchQuery, ignoreCase = true) ||
                item.location.contains(searchQuery, ignoreCase = true)
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Surface(
                            shape = RoundedCornerShape(8.dp),
                            color = AmberAccent,
                            modifier = Modifier.size(32.dp)
                        ) {
                            Box(contentAlignment = Alignment.Center) {
                                Icon(Icons.Default.Search, contentDescription = null, tint = NavyPrimary, modifier = Modifier.size(20.dp))
                            }
                        }
                        Spacer(modifier = Modifier.width(10.dp))
                        Column {
                            Text("UniTrace", fontWeight = FontWeight.Bold, fontSize = 18.sp, color = Color.White)
                            Text("Campus Registry", fontSize = 11.sp, color = AmberAccent)
                        }
                    }
                },
                actions = {
                    IconButton(
                        onClick = {
                            isRefreshing = true
                            loadData()
                        },
                        modifier = Modifier.testTag("refresh_button")
                    ) {
                        Icon(Icons.Default.Refresh, contentDescription = "Refresh", tint = Color.White)
                    }

                    IconButton(
                        onClick = onNavigateToProfile,
                        modifier = Modifier.testTag("profile_button")
                    ) {
                        Icon(Icons.Outlined.AccountCircle, contentDescription = "Account Profile", tint = Color.White)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = NavyPrimary,
                    titleContentColor = Color.White,
                    actionIconContentColor = Color.White
                )
            )
        },
        floatingActionButton = {
            ExtendedFloatingActionButton(
                onClick = { onCreateItem(selectedType) },
                icon = { Icon(Icons.Default.Add, contentDescription = null, tint = NavyPrimary) },
                text = {
                    Text(
                        if (selectedType == "LOST") "Report Lost Item" else "Report Found Item",
                        fontWeight = FontWeight.Bold,
                        color = NavyPrimary
                    )
                },
                containerColor = AmberAccent,
                elevation = FloatingActionButtonDefaults.elevation(6.dp),
                modifier = Modifier.testTag("report_item_fab")
            )
        },
        containerColor = SlateBackground
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
        ) {
            // Search Bar
            Surface(
                color = SurfaceLight,
                shadowElevation = 1.dp
            ) {
                Column(modifier = Modifier.padding(horizontal = 16.dp, vertical = 10.dp)) {
                    OutlinedTextField(
                        value = searchQuery,
                        onValueChange = { searchQuery = it },
                        placeholder = { Text("Search by title, description or location...") },
                        leadingIcon = { Icon(Icons.Default.Search, contentDescription = null, tint = SlateMuted) },
                        trailingIcon = {
                            if (searchQuery.isNotEmpty()) {
                                IconButton(onClick = { searchQuery = "" }) {
                                    Icon(Icons.Default.Close, contentDescription = "Clear", tint = SlateMuted)
                                }
                            }
                        },
                        singleLine = true,
                        shape = RoundedCornerShape(12.dp),
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedContainerColor = SlateSubtle,
                            unfocusedContainerColor = SlateSubtle,
                            unfocusedBorderColor = Color.Transparent,
                            focusedBorderColor = NavyPrimary
                        ),
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(50.dp)
                            .testTag("search_field")
                    )

                    Spacer(modifier = Modifier.height(10.dp))

                    // Type Segmented Toggle: LOST vs FOUND
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .background(SlateSubtle, shape = RoundedCornerShape(10.dp))
                            .padding(4.dp)
                    ) {
                        val lostActive = selectedType == "LOST"
                        Surface(
                            modifier = Modifier
                                .weight(1f)
                                .height(38.dp)
                                .clickable { selectedType = "LOST" }
                                .testTag("type_tab_lost"),
                            shape = RoundedCornerShape(8.dp),
                            color = if (lostActive) NavyPrimary else Color.Transparent,
                            shadowElevation = if (lostActive) 2.dp else 0.dp
                        ) {
                            Box(contentAlignment = Alignment.Center) {
                                Row(verticalAlignment = Alignment.CenterVertically) {
                                    Icon(
                                        Icons.Default.Search,
                                        contentDescription = null,
                                        tint = if (lostActive) AmberAccent else SlateMuted,
                                        modifier = Modifier.size(16.dp)
                                    )
                                    Spacer(modifier = Modifier.width(6.dp))
                                    Text(
                                        "LOST ITEMS",
                                        fontWeight = FontWeight.Bold,
                                        fontSize = 13.sp,
                                        color = if (lostActive) Color.White else SlateMuted
                                    )
                                }
                            }
                        }

                        val foundActive = selectedType == "FOUND"
                        Surface(
                            modifier = Modifier
                                .weight(1f)
                                .height(38.dp)
                                .clickable { selectedType = "FOUND" }
                                .testTag("type_tab_found"),
                            shape = RoundedCornerShape(8.dp),
                            color = if (foundActive) NavyPrimary else Color.Transparent,
                            shadowElevation = if (foundActive) 2.dp else 0.dp
                        ) {
                            Box(contentAlignment = Alignment.Center) {
                                Row(verticalAlignment = Alignment.CenterVertically) {
                                    Icon(
                                        Icons.Outlined.Inventory2,
                                        contentDescription = null,
                                        tint = if (foundActive) AmberAccent else SlateMuted,
                                        modifier = Modifier.size(16.dp)
                                    )
                                    Spacer(modifier = Modifier.width(6.dp))
                                    Text(
                                        "FOUND ITEMS",
                                        fontWeight = FontWeight.Bold,
                                        fontSize = 13.sp,
                                        color = if (foundActive) Color.White else SlateMuted
                                    )
                                }
                            }
                        }
                    }

                    Spacer(modifier = Modifier.height(10.dp))

                    // OAS 3.1 Status Filter Row: ALL, OPEN, MATCHED, CLAIMED, CLOSED
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .horizontalScroll(rememberScrollState()),
                        horizontalArrangement = Arrangement.spacedBy(8.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            "Status:",
                            fontSize = 12.sp,
                            fontWeight = FontWeight.SemiBold,
                            color = SlateMuted
                        )

                        val statuses = listOf("ALL", "OPEN", "MATCHED", "CLAIMED", "CLOSED")
                        statuses.forEach { statusKey ->
                            val isSelected = selectedStatus == statusKey
                            FilterChip(
                                selected = isSelected,
                                onClick = { selectedStatus = statusKey },
                                label = { Text(statusKey, fontSize = 11.sp, fontWeight = FontWeight.Bold) },
                                colors = FilterChipDefaults.filterChipColors(
                                    selectedContainerColor = NavyPrimary,
                                    selectedLabelColor = Color.White,
                                    containerColor = SlateSubtle,
                                    labelColor = SlateMuted
                                ),
                                shape = RoundedCornerShape(16.dp),
                                modifier = Modifier.testTag("status_filter_$statusKey")
                            )
                        }
                    }
                }
            }

            // Items List
            PullToRefreshBox(
                isRefreshing = isRefreshing,
                onRefresh = {
                    isRefreshing = true
                    loadData()
                },
                modifier = Modifier.fillMaxSize()
            ) {
                if (isLoading && !isRefreshing) {
                    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                        CircularProgressIndicator(color = NavyPrimary)
                    }
                } else if (filteredItems.isEmpty()) {
                    Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(32.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.Center
                    ) {
                        Surface(
                            shape = CircleShape,
                            color = SlateSubtle,
                            modifier = Modifier.size(72.dp)
                        ) {
                            Box(contentAlignment = Alignment.Center) {
                                Icon(Icons.Outlined.SearchOff, contentDescription = null, tint = SlateMuted, modifier = Modifier.size(36.dp))
                            }
                        }
                        Spacer(modifier = Modifier.height(16.dp))
                        Text(
                            "No ${selectedType.lowercase()} items found",
                            fontSize = 17.sp,
                            fontWeight = FontWeight.Bold,
                            color = TextPrimary
                        )
                        Spacer(modifier = Modifier.height(6.dp))
                        Text(
                            if (selectedStatus != "ALL") "No items with status '$selectedStatus'. Try selecting 'ALL'."
                            else "Be the first to report a ${selectedType.lowercase()} item on campus.",
                            fontSize = 13.sp,
                            color = SlateMuted,
                            textAlign = androidx.compose.ui.text.style.TextAlign.Center
                        )
                    }
                } else {
                    LazyColumn(
                        modifier = Modifier.fillMaxSize(),
                        contentPadding = PaddingValues(start = 16.dp, end = 16.dp, top = 12.dp, bottom = 88.dp),
                        verticalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        items(filteredItems, key = { it.id }) { item ->
                            ItemCard(
                                item = item,
                                onClick = { onItemClick(item) }
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun ItemCard(
    item: ItemResponse,
    onClick: () -> Unit
) {
    val isLost = item.type.equals("LOST", ignoreCase = true)

    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() }
            .testTag("item_card_${item.id}"),
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = SurfaceLight),
        border = BorderStroke(1.dp, SlateBorder)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Image Thumbnail or Icon
            Surface(
                modifier = Modifier.size(76.dp),
                shape = RoundedCornerShape(8.dp),
                color = SlateSubtle
            ) {
                if (!item.imageUrl.isNullOrEmpty()) {
                    AsyncImage(
                        model = item.imageUrl,
                        contentDescription = item.title,
                        contentScale = ContentScale.Crop,
                        modifier = Modifier.fillMaxSize()
                    )
                } else {
                    Box(contentAlignment = Alignment.Center) {
                        Icon(
                            if (isLost) Icons.Default.Search else Icons.Outlined.Inventory2,
                            contentDescription = null,
                            tint = SlateMuted,
                            modifier = Modifier.size(32.dp)
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.width(14.dp))

            // Details
            Column(modifier = Modifier.weight(1f)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    TypeBadge(type = item.type)

                    if (item.status.isNotEmpty()) {
                        Spacer(modifier = Modifier.width(6.dp))
                        StatusPill(status = item.status)
                    }

                    Spacer(modifier = Modifier.weight(1f))

                    item.createdAt?.let { dateStr ->
                        val displayDate = if (dateStr.length >= 10) dateStr.substring(0, 10) else dateStr
                        Text(
                            text = displayDate,
                            fontSize = 11.sp,
                            color = SlateMuted
                        )
                    }
                }

                Spacer(modifier = Modifier.height(6.dp))

                Text(
                    text = item.title,
                    fontWeight = FontWeight.Bold,
                    fontSize = 15.sp,
                    color = TextPrimary,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )

                Spacer(modifier = Modifier.height(4.dp))

                Text(
                    text = item.description,
                    fontSize = 12.sp,
                    color = SlateMuted,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis,
                    lineHeight = 16.sp
                )

                Spacer(modifier = Modifier.height(6.dp))

                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        Icons.Default.LocationOn,
                        contentDescription = null,
                        tint = SlateMuted,
                        modifier = Modifier.size(13.dp)
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(
                        text = item.location.ifEmpty { "Campus Grounds" },
                        fontSize = 11.sp,
                        color = SlateMuted,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }
            }

            Icon(
                Icons.Default.ChevronRight,
                contentDescription = "View Details",
                tint = SlateMuted,
                modifier = Modifier.size(20.dp)
            )
        }
    }
}
