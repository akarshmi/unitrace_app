package com.example.ui.screens

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
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
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.AppRepository
import com.example.data.RegisterRequest
import com.example.ui.theme.*
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RegisterScreen(
    repository: AppRepository,
    onRegisterSuccess: (email: String, token: String, ttlMinutes: Long) -> Unit,
    onBackToLogin: () -> Unit,
    onShowMessage: (String) -> Unit
) {
    // OAS 3.1 RegisterRequest fields
    var firstName by remember { mutableStateOf("") }
    var lastName by remember { mutableStateOf("") }
    var department by remember { mutableStateOf("Computer Science") }
    var registrationNumber by remember { mutableStateOf("") }
    var uniEmail by remember { mutableStateOf("") }
    var personalEmail by remember { mutableStateOf("") }
    var phoneNumber by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var confirmPassword by remember { mutableStateOf("") }
    var passwordVisible by remember { mutableStateOf(false) }

    var isLoading by remember { mutableStateOf(false) }
    val scope = rememberCoroutineScope()

    // Real-time validations according to OpenAPI OAS 3.1
    val isPhoneValid = phoneNumber.matches(Regex("^[0-9]{10}$"))
    val hasMinLength = password.length in 8..64
    val hasLower = password.any { it.isLowerCase() }
    val hasUpper = password.any { it.isUpperCase() }
    val hasDigit = password.any { it.isDigit() }
    val isPasswordValid = hasMinLength && hasLower && hasUpper && hasDigit
    val isPasswordMatching = password.isNotEmpty() && password == confirmPassword

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("University Registration", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = onBackToLogin) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back to Login")
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
                .padding(horizontal = 20.dp, vertical = 16.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Header Description
            Text(
                text = "Step 1 of 2: Registration Initiation",
                fontSize = 12.sp,
                color = NavyPrimary,
                fontWeight = FontWeight.Bold,
                modifier = Modifier
                    .background(NavyPrimary.copy(alpha = 0.1f), shape = RoundedCornerShape(20.dp))
                    .padding(horizontal = 12.dp, vertical = 6.dp)
            )

            Spacer(modifier = Modifier.height(8.dp))

            Text(
                text = "Create your UniTrace campus account to report or claim lost property.",
                fontSize = 13.sp,
                color = SlateMuted,
                lineHeight = 18.sp
            )

            Spacer(modifier = Modifier.height(16.dp))

            // Card 1: Academic & Personal Info
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(14.dp),
                colors = CardDefaults.cardColors(containerColor = SurfaceLight),
                border = BorderStroke(1.dp, SlateBorder)
            ) {
                Column(modifier = Modifier.padding(18.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Outlined.School, contentDescription = null, tint = NavyPrimary, modifier = Modifier.size(20.dp))
                        Spacer(modifier = Modifier.width(8.dp))
                        Text("Academic Identity", fontWeight = FontWeight.SemiBold, fontSize = 15.sp, color = TextPrimary)
                    }

                    Spacer(modifier = Modifier.height(14.dp))

                    // First & Last Name
                    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                        OutlinedTextField(
                            value = firstName,
                            onValueChange = { firstName = it },
                            label = { Text("First Name *") },
                            placeholder = { Text("Alex") },
                            modifier = Modifier
                                .weight(1f)
                                .testTag("first_name_input"),
                            singleLine = true
                        )

                        OutlinedTextField(
                            value = lastName,
                            onValueChange = { lastName = it },
                            label = { Text("Last Name") },
                            placeholder = { Text("Rivera") },
                            modifier = Modifier
                                .weight(1f)
                                .testTag("last_name_input"),
                            singleLine = true
                        )
                    }

                    Spacer(modifier = Modifier.height(12.dp))

                    // Department
                    OutlinedTextField(
                        value = department,
                        onValueChange = { department = it },
                        label = { Text("Department") },
                        placeholder = { Text("e.g. Computer Science, Mechanical Eng.") },
                        leadingIcon = { Icon(Icons.Outlined.Apartment, contentDescription = null, tint = SlateMuted) },
                        modifier = Modifier
                            .fillMaxWidth()
                            .testTag("department_input"),
                        singleLine = true
                    )

                    Spacer(modifier = Modifier.height(12.dp))

                    // Registration Number (Numeric int64)
                    OutlinedTextField(
                        value = registrationNumber,
                        onValueChange = { if (it.all { ch -> ch.isDigit() }) registrationNumber = it },
                        label = { Text("Registration Number (Numeric ID) *") },
                        placeholder = { Text("20241042") },
                        leadingIcon = { Icon(Icons.Outlined.Badge, contentDescription = null, tint = SlateMuted) },
                        modifier = Modifier
                            .fillMaxWidth()
                            .testTag("reg_number_input"),
                        singleLine = true,
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number)
                    )
                }
            }

            Spacer(modifier = Modifier.height(14.dp))

            // Card 2: Contact Information
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(14.dp),
                colors = CardDefaults.cardColors(containerColor = SurfaceLight),
                border = BorderStroke(1.dp, SlateBorder)
            ) {
                Column(modifier = Modifier.padding(18.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Outlined.ContactMail, contentDescription = null, tint = NavyPrimary, modifier = Modifier.size(20.dp))
                        Spacer(modifier = Modifier.width(8.dp))
                        Text("Contact Details", fontWeight = FontWeight.SemiBold, fontSize = 15.sp, color = TextPrimary)
                    }

                    Spacer(modifier = Modifier.height(14.dp))

                    // University Email (uniEmail)
                    OutlinedTextField(
                        value = uniEmail,
                        onValueChange = { uniEmail = it },
                        label = { Text("University Email (uniEmail) *") },
                        placeholder = { Text("student@university.edu") },
                        leadingIcon = { Icon(Icons.Default.Email, contentDescription = null, tint = NavyPrimary) },
                        modifier = Modifier
                            .fillMaxWidth()
                            .testTag("uni_email_input"),
                        singleLine = true,
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email)
                    )

                    Spacer(modifier = Modifier.height(12.dp))

                    // Personal Email (personalEmail)
                    OutlinedTextField(
                        value = personalEmail,
                        onValueChange = { personalEmail = it },
                        label = { Text("Personal Recovery Email") },
                        placeholder = { Text("alex.personal@gmail.com") },
                        leadingIcon = { Icon(Icons.Outlined.AlternateEmail, contentDescription = null, tint = SlateMuted) },
                        modifier = Modifier
                            .fillMaxWidth()
                            .testTag("personal_email_input"),
                        singleLine = true,
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email)
                    )

                    Spacer(modifier = Modifier.height(12.dp))

                    // Phone Number (10 Digits)
                    OutlinedTextField(
                        value = phoneNumber,
                        onValueChange = {
                            if (it.length <= 10 && it.all { ch -> ch.isDigit() }) {
                                phoneNumber = it
                            }
                        },
                        label = { Text("Phone Number (10 digits) *") },
                        placeholder = { Text("9876543210") },
                        leadingIcon = { Icon(Icons.Default.Phone, contentDescription = null, tint = SlateMuted) },
                        supportingText = {
                            Text(
                                if (phoneNumber.isEmpty()) "Required: 10-digit mobile number"
                                else if (isPhoneValid) "Valid 10-digit phone"
                                else "${phoneNumber.length}/10 digits entered",
                                color = if (isPhoneValid) Color(0xFF166534) else SlateMuted
                            )
                        },
                        isError = phoneNumber.isNotEmpty() && !isPhoneValid,
                        modifier = Modifier
                            .fillMaxWidth()
                            .testTag("phone_input"),
                        singleLine = true,
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Phone)
                    )
                }
            }

            Spacer(modifier = Modifier.height(14.dp))

            // Card 3: Security & Password
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(14.dp),
                colors = CardDefaults.cardColors(containerColor = SurfaceLight),
                border = BorderStroke(1.dp, SlateBorder)
            ) {
                Column(modifier = Modifier.padding(18.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Outlined.Lock, contentDescription = null, tint = NavyPrimary, modifier = Modifier.size(20.dp))
                        Spacer(modifier = Modifier.width(8.dp))
                        Text("Security", fontWeight = FontWeight.SemiBold, fontSize = 15.sp, color = TextPrimary)
                    }

                    Spacer(modifier = Modifier.height(14.dp))

                    // Password
                    OutlinedTextField(
                        value = password,
                        onValueChange = { password = it },
                        label = { Text("Password *") },
                        leadingIcon = { Icon(Icons.Default.Lock, contentDescription = null, tint = NavyPrimary) },
                        trailingIcon = {
                            IconButton(onClick = { passwordVisible = !passwordVisible }) {
                                Icon(
                                    if (passwordVisible) Icons.Default.Visibility else Icons.Default.VisibilityOff,
                                    contentDescription = "Toggle Password"
                                )
                            }
                        },
                        visualTransformation = if (passwordVisible) VisualTransformation.None else PasswordVisualTransformation(),
                        modifier = Modifier
                            .fillMaxWidth()
                            .testTag("register_password_input"),
                        singleLine = true,
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password)
                    )

                    Spacer(modifier = Modifier.height(8.dp))

                    // Password Requirements checklist (OpenAPI regex rule)
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .background(SlateSubtle, shape = RoundedCornerShape(8.dp))
                            .padding(10.dp)
                    ) {
                        Text("Password must contain:", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = SlateMuted)
                        Spacer(modifier = Modifier.height(4.dp))
                        RequirementRow(text = "8 to 64 characters", satisfied = hasMinLength)
                        RequirementRow(text = "At least one uppercase letter (A-Z)", satisfied = hasUpper)
                        RequirementRow(text = "At least one lowercase letter (a-z)", satisfied = hasLower)
                        RequirementRow(text = "At least one number (0-9)", satisfied = hasDigit)
                    }

                    Spacer(modifier = Modifier.height(12.dp))

                    // Confirm Password
                    OutlinedTextField(
                        value = confirmPassword,
                        onValueChange = { confirmPassword = it },
                        label = { Text("Confirm Password *") },
                        leadingIcon = { Icon(Icons.Outlined.CheckCircle, contentDescription = null, tint = SlateMuted) },
                        visualTransformation = PasswordVisualTransformation(),
                        supportingText = {
                            if (confirmPassword.isNotEmpty()) {
                                Text(
                                    if (isPasswordMatching) "Passwords match" else "Passwords do not match",
                                    color = if (isPasswordMatching) Color(0xFF166534) else StatusLostText
                                )
                            }
                        },
                        isError = confirmPassword.isNotEmpty() && !isPasswordMatching,
                        modifier = Modifier
                            .fillMaxWidth()
                            .testTag("confirm_password_input"),
                        singleLine = true,
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password)
                    )
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            // Submit Button: Initiate Registration
            Button(
                onClick = {
                    if (firstName.isBlank()) {
                        onShowMessage("Please enter your first name")
                        return@Button
                    }
                    if (uniEmail.isBlank() || !uniEmail.contains("@")) {
                        onShowMessage("Please enter a valid university email")
                        return@Button
                    }
                    val regNumLong = registrationNumber.toLongOrNull()
                    if (regNumLong == null) {
                        onShowMessage("Registration number must be a valid numeric ID")
                        return@Button
                    }
                    if (!isPhoneValid) {
                        onShowMessage("Phone number must be exactly 10 digits")
                        return@Button
                    }
                    if (!isPasswordValid) {
                        onShowMessage("Password does not meet requirements (8+ chars, upper, lower, digit)")
                        return@Button
                    }
                    if (!isPasswordMatching) {
                        onShowMessage("Passwords do not match")
                        return@Button
                    }

                    isLoading = true
                    scope.launch {
                        val request = RegisterRequest(
                            firstName = firstName.trim(),
                            lastName = lastName.trim(),
                            department = department.trim(),
                            registrationNumber = regNumLong,
                            uniEmail = uniEmail.trim(),
                            personalEmail = personalEmail.trim(),
                            phoneNumber = phoneNumber.trim(),
                            password = password
                        )

                        val result = repository.registerInitiation(request)
                        isLoading = false

                        if (result.isSuccess) {
                            val response = result.getOrNull()!!
                            onShowMessage("Registration initiated! OTP sent to ${response.uniEmail}")
                            onRegisterSuccess(response.uniEmail, response.token, response.otpTtlMinutes)
                        } else {
                            onShowMessage("Failed: ${result.exceptionOrNull()?.message ?: "Unable to initiate registration"}")
                        }
                    }
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(52.dp)
                    .testTag("initiate_registration_button"),
                shape = RoundedCornerShape(12.dp),
                colors = ButtonDefaults.buttonColors(containerColor = NavyPrimary),
                enabled = !isLoading
            ) {
                if (isLoading) {
                    CircularProgressIndicator(color = Color.White, modifier = Modifier.size(24.dp))
                } else {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text("Initiate Registration & Send OTP", fontWeight = FontWeight.Bold, fontSize = 15.sp)
                        Spacer(modifier = Modifier.width(8.dp))
                        Icon(Icons.Default.ArrowForward, contentDescription = null, modifier = Modifier.size(18.dp))
                    }
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            TextButton(
                onClick = onBackToLogin,
                modifier = Modifier.padding(bottom = 16.dp)
            ) {
                Text("Already have an account? Sign In", color = NavyPrimary, fontWeight = FontWeight.SemiBold)
            }
        }
    }
}

@Composable
private fun RequirementRow(text: String, satisfied: Boolean) {
    Row(
        verticalAlignment = Alignment.CenterVertically,
        modifier = Modifier.padding(vertical = 2.dp)
    ) {
        Icon(
            imageVector = if (satisfied) Icons.Default.CheckCircle else Icons.Outlined.Circle,
            contentDescription = null,
            tint = if (satisfied) Color(0xFF166534) else SlateMuted,
            modifier = Modifier.size(14.dp)
        )
        Spacer(modifier = Modifier.width(6.dp))
        Text(
            text = text,
            fontSize = 11.sp,
            color = if (satisfied) Color(0xFF166534) else SlateMuted,
            fontWeight = if (satisfied) FontWeight.SemiBold else FontWeight.Normal
        )
    }
}
