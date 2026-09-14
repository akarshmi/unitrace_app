package com.example.ui.screens

import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.PickVisualMediaRequest
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
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
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import com.example.data.AppRepository
import com.example.ui.theme.*
import kotlinx.coroutines.launch
import java.io.File
import java.io.FileOutputStream
import java.text.SimpleDateFormat
import java.util.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CreateItemScreen(
    initialType: String = "LOST",
    repository: AppRepository,
    onItemCreated: () -> Unit,
    onBack: () -> Unit,
    onShowMessage: (String) -> Unit
) {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()

    var type by remember { mutableStateOf(initialType) }
    var title by remember { mutableStateOf("") }
    var description by remember { mutableStateOf("") }
    var location by remember { mutableStateOf("") }
    var eventFrom by remember {
        mutableStateOf(SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.getDefault()).format(Date()))
    }
    var eventTo by remember { mutableStateOf("") }
    var includeGps by remember { mutableStateOf(false) }
    var latitude by remember { mutableStateOf("37.4275") }
    var longitude by remember { mutableStateOf("-122.1697") }

    var selectedImageUri by remember { mutableStateOf<Uri?>(null) }
    var isLoading by remember { mutableStateOf(false) }

    val photoPickerLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.PickVisualMedia()
    ) { uri: Uri? ->
        selectedImageUri = uri
    }

    val campusPresets = listOf(
        "Main Library 2nd Fl",
        "Student Union Kiosk",
        "Science Quad",
        "Engineering Hall 301",
        "Dining Commons",
        "Athletics Center"
    )

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        if (type == "LOST") "Report Lost Property" else "Report Found Item",
                        fontWeight = FontWeight.Bold
                    )
                },
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
            // Type Toggle
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp),
                colors = CardDefaults.cardColors(containerColor = SurfaceLight),
                border = BorderStroke(1.dp, SlateBorder)
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(8.dp)
                ) {
                    val lostActive = type == "LOST"
                    Surface(
                        modifier = Modifier
                            .weight(1f)
                            .height(44.dp)
                            .clickable { type = "LOST" }
                            .testTag("create_type_lost"),
                        shape = RoundedCornerShape(8.dp),
                        color = if (lostActive) StatusLostText else Color.Transparent
                    ) {
                        Box(contentAlignment = Alignment.Center) {
                            Text(
                                "I LOST AN ITEM",
                                fontWeight = FontWeight.Bold,
                                color = if (lostActive) Color.White else SlateMuted,
                                fontSize = 13.sp
                            )
                        }
                    }

                    val foundActive = type == "FOUND"
                    Surface(
                        modifier = Modifier
                            .weight(1f)
                            .height(44.dp)
                            .clickable { type = "FOUND" }
                            .testTag("create_type_found"),
                        shape = RoundedCornerShape(8.dp),
                        color = if (foundActive) StatusOpenText else Color.Transparent
                    ) {
                        Box(contentAlignment = Alignment.Center) {
                            Text(
                                "I FOUND AN ITEM",
                                fontWeight = FontWeight.Bold,
                                color = if (foundActive) Color.White else SlateMuted,
                                fontSize = 13.sp
                            )
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Photo Attachment Section
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(14.dp),
                colors = CardDefaults.cardColors(containerColor = SurfaceLight),
                border = BorderStroke(1.dp, SlateBorder)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Outlined.PhotoCamera, contentDescription = null, tint = NavyPrimary)
                        Spacer(modifier = Modifier.width(8.dp))
                        Text("Item Photo (image * binary)", fontWeight = FontWeight.SemiBold, fontSize = 15.sp)
                    }

                    Spacer(modifier = Modifier.height(12.dp))

                    if (selectedImageUri != null) {
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(160.dp)
                                .clip(RoundedCornerShape(10.dp))
                        ) {
                            AsyncImage(
                                model = selectedImageUri,
                                contentDescription = "Item Photo",
                                contentScale = ContentScale.Crop,
                                modifier = Modifier.fillMaxSize()
                            )

                            IconButton(
                                onClick = { selectedImageUri = null },
                                modifier = Modifier
                                    .align(Alignment.TopEnd)
                                    .padding(8.dp)
                                    .background(Color.Black.copy(alpha = 0.6f), shape = CircleShape)
                                    .size(32.dp)
                            ) {
                                Icon(Icons.Default.Close, contentDescription = "Remove Photo", tint = Color.White, modifier = Modifier.size(18.dp))
                            }
                        }
                    } else {
                        Surface(
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(110.dp)
                                .clickable {
                                    photoPickerLauncher.launch(
                                        PickVisualMediaRequest(ActivityResultContracts.PickVisualMedia.ImageOnly)
                                    )
                                }
                                .testTag("pick_image_button"),
                            shape = RoundedCornerShape(10.dp),
                            color = SlateSubtle,
                            border = BorderStroke(1.dp, SlateBorder)
                        ) {
                            Column(
                                modifier = Modifier.fillMaxSize(),
                                horizontalAlignment = Alignment.CenterHorizontally,
                                verticalArrangement = Arrangement.Center
                            ) {
                                Icon(Icons.Outlined.AddPhotoAlternate, contentDescription = null, tint = NavyPrimary, modifier = Modifier.size(32.dp))
                                Spacer(modifier = Modifier.height(6.dp))
                                Text("Attach photo from gallery or camera", fontSize = 12.sp, color = NavyPrimary, fontWeight = FontWeight.SemiBold)
                                Text("Helps verify and match items quickly", fontSize = 11.sp, color = SlateMuted)
                            }
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Details Card
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(14.dp),
                colors = CardDefaults.cardColors(containerColor = SurfaceLight),
                border = BorderStroke(1.dp, SlateBorder)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    // Title (0-150 chars)
                    OutlinedTextField(
                        value = title,
                        onValueChange = { if (it.length <= 150) title = it },
                        label = { Text("Title * (0 - 150 chars)") },
                        placeholder = { Text("e.g. MacBook Pro, Blue Hydro Flask, Student ID") },
                        supportingText = { Text("${title.length}/150 characters", color = SlateMuted) },
                        modifier = Modifier
                            .fillMaxWidth()
                            .testTag("item_title_input"),
                        singleLine = true
                    )

                    Spacer(modifier = Modifier.height(10.dp))

                    // Location (0-255 chars)
                    OutlinedTextField(
                        value = location,
                        onValueChange = { if (it.length <= 255) location = it },
                        label = { Text("Location * (0 - 255 chars)") },
                        placeholder = { Text("e.g. Main Library 2nd Floor Silent Study") },
                        leadingIcon = { Icon(Icons.Default.LocationOn, contentDescription = null, tint = NavyPrimary) },
                        supportingText = { Text("${location.length}/255 characters", color = SlateMuted) },
                        modifier = Modifier
                            .fillMaxWidth()
                            .testTag("item_location_input"),
                        singleLine = true
                    )

                    Spacer(modifier = Modifier.height(6.dp))

                    // Campus Location Quick Presets
                    Text("Quick Campus Presets:", fontSize = 11.sp, color = SlateMuted, fontWeight = FontWeight.SemiBold)
                    Spacer(modifier = Modifier.height(4.dp))
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .horizontalScroll(rememberScrollState()),
                        horizontalArrangement = Arrangement.spacedBy(6.dp)
                    ) {
                        campusPresets.forEach { preset ->
                            SuggestionChip(
                                onClick = { location = preset },
                                label = { Text(preset, fontSize = 11.sp) }
                            )
                        }
                    }

                    Spacer(modifier = Modifier.height(12.dp))

                    // Description (0-1000 chars)
                    OutlinedTextField(
                        value = description,
                        onValueChange = { if (it.length <= 1000) description = it },
                        label = { Text("Detailed Description * (0 - 1000 chars)") },
                        placeholder = { Text("Describe physical features, stickers, brand, color, distinguishing marks...") },
                        supportingText = { Text("${description.length}/1000 characters", color = SlateMuted) },
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(120.dp)
                            .testTag("item_description_input")
                    )
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            // OAS 3.1 Timing & GPS Card
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(14.dp),
                colors = CardDefaults.cardColors(containerColor = SurfaceLight),
                border = BorderStroke(1.dp, SlateBorder)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Outlined.AccessTime, contentDescription = null, tint = NavyPrimary)
                        Spacer(modifier = Modifier.width(8.dp))
                        Text("Incident Timing & Geo-Coordinates", fontWeight = FontWeight.SemiBold, fontSize = 15.sp)
                    }

                    Spacer(modifier = Modifier.height(12.dp))

                    // Event From (ISO date-time)
                    OutlinedTextField(
                        value = eventFrom,
                        onValueChange = { eventFrom = it },
                        label = { Text("Event From (eventFrom ISO-8601)") },
                        leadingIcon = { Icon(Icons.Outlined.CalendarToday, contentDescription = null, tint = SlateMuted) },
                        modifier = Modifier.fillMaxWidth(),
                        singleLine = true
                    )

                    Spacer(modifier = Modifier.height(10.dp))

                    // Event To (optional)
                    OutlinedTextField(
                        value = eventTo,
                        onValueChange = { eventTo = it },
                        label = { Text("Event To (eventTo optional)") },
                        placeholder = { Text("Optional end of time window") },
                        leadingIcon = { Icon(Icons.Outlined.EventAvailable, contentDescription = null, tint = SlateMuted) },
                        modifier = Modifier.fillMaxWidth(),
                        singleLine = true
                    )

                    Spacer(modifier = Modifier.height(14.dp))

                    // GeoLocation coordinates toggle
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Column {
                            Text("Include Campus GPS Coordinates", fontSize = 13.sp, fontWeight = FontWeight.SemiBold)
                            Text("Adds latitude & longitude to geoLocation object", fontSize = 11.sp, color = SlateMuted)
                        }
                        Switch(
                            checked = includeGps,
                            onCheckedChange = { includeGps = it },
                            colors = SwitchDefaults.colors(checkedThumbColor = NavyPrimary)
                        )
                    }

                    if (includeGps) {
                        Spacer(modifier = Modifier.height(10.dp))
                        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                            OutlinedTextField(
                                value = latitude,
                                onValueChange = { latitude = it },
                                label = { Text("Latitude [-90, 90]") },
                                modifier = Modifier.weight(1f),
                                singleLine = true
                            )
                            OutlinedTextField(
                                value = longitude,
                                onValueChange = { longitude = it },
                                label = { Text("Longitude [-180, 180]") },
                                modifier = Modifier.weight(1f),
                                singleLine = true
                            )
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            // Submit Button
            Button(
                onClick = {
                    if (title.isBlank()) {
                        onShowMessage("Please enter a title for the item")
                        return@Button
                    }
                    if (location.isBlank()) {
                        onShowMessage("Please enter where the item was lost or found")
                        return@Button
                    }
                    if (description.isBlank()) {
                        onShowMessage("Please provide a brief description")
                        return@Button
                    }

                    isLoading = true
                    scope.launch {
                        // Prepare file if image chosen
                        var tempFile: File? = null
                        if (selectedImageUri != null) {
                            try {
                                val inputStream = context.contentResolver.openInputStream(selectedImageUri!!)
                                val file = File(context.cacheDir, "upload_${System.currentTimeMillis()}.jpg")
                                val outputStream = FileOutputStream(file)
                                inputStream?.copyTo(outputStream)
                                inputStream?.close()
                                outputStream.close()
                                tempFile = file
                            } catch (_: Exception) {}
                        }

                        val latDouble = if (includeGps) latitude.toDoubleOrNull() else null
                        val lngDouble = if (includeGps) longitude.toDoubleOrNull() else null

                        val result = repository.createItem(
                            type = type,
                            title = title.trim(),
                            description = description.trim(),
                            location = location.trim(),
                            eventFrom = eventFrom.ifBlank { null },
                            eventTo = eventTo.ifBlank { null },
                            latitude = latDouble,
                            longitude = lngDouble,
                            imageFile = tempFile
                        )

                        isLoading = false
                        if (result.isSuccess) {
                            onShowMessage("Item posted successfully to UniTrace registry!")
                            onItemCreated()
                        } else {
                            onShowMessage("Error: ${result.exceptionOrNull()?.message ?: "Unable to post item"}")
                        }
                    }
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(52.dp)
                    .testTag("submit_item_button"),
                shape = RoundedCornerShape(12.dp),
                colors = ButtonDefaults.buttonColors(containerColor = NavyPrimary),
                enabled = !isLoading
            ) {
                if (isLoading) {
                    CircularProgressIndicator(color = Color.White, modifier = Modifier.size(24.dp))
                } else {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.CloudUpload, contentDescription = null, modifier = Modifier.size(20.dp))
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(
                            if (type == "LOST") "Publish Lost Item Notice" else "Publish Found Item Report",
                            fontWeight = FontWeight.Bold,
                            fontSize = 15.sp
                        )
                    }
                }
            }
        }
    }
}
