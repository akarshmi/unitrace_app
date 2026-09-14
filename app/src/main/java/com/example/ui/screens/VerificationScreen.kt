package com.example.ui.screens

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.LockReset
import androidx.compose.material.icons.outlined.MarkEmailRead
import androidx.compose.material.icons.outlined.Timer
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.AppRepository
import com.example.ui.theme.*
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun VerificationScreen(
    email: String,
    token: String,
    otpTtlMinutes: Long = 10L,
    repository: AppRepository,
    onVerifySuccess: (email: String) -> Unit,
    onBack: () -> Unit,
    onShowMessage: (String) -> Unit
) {
    var otp by remember { mutableStateOf("") }
    var isLoading by remember { mutableStateOf(false) }
    var isVerified by remember { mutableStateOf(false) }
    var serverMessage by remember { mutableStateOf("") }

    val scope = rememberCoroutineScope()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Email Verification", fontWeight = FontWeight.Bold) },
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
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            // Icon
            Surface(
                modifier = Modifier.size(72.dp),
                shape = RoundedCornerShape(20.dp),
                color = if (isVerified) Color(0xFFDCFCE7) else NavyPrimary.copy(alpha = 0.1f)
            ) {
                Box(contentAlignment = Alignment.Center) {
                    Icon(
                        if (isVerified) Icons.Default.CheckCircle else Icons.Outlined.MarkEmailRead,
                        contentDescription = null,
                        tint = if (isVerified) Color(0xFF166534) else NavyPrimary,
                        modifier = Modifier.size(38.dp)
                    )
                }
            }

            Spacer(modifier = Modifier.height(20.dp))

            Text(
                text = if (isVerified) "Account Verified!" else "Verify Your University Email",
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold,
                color = TextPrimary
            )

            Spacer(modifier = Modifier.height(8.dp))

            Text(
                text = if (isVerified)
                    serverMessage.ifEmpty { "Your email has been successfully verified. You can now log in." }
                else
                    "We have sent a verification code to:",
                fontSize = 13.sp,
                color = SlateMuted,
                textAlign = TextAlign.Center
            )

            if (!isVerified) {
                Text(
                    text = email,
                    fontSize = 15.sp,
                    fontWeight = FontWeight.Bold,
                    color = NavyPrimary,
                    textAlign = TextAlign.Center
                )

                Spacer(modifier = Modifier.height(8.dp))

                // TTL info & Token badge
                Surface(
                    shape = RoundedCornerShape(20.dp),
                    color = SlateSubtle
                ) {
                    Row(
                        modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(Icons.Outlined.Timer, contentDescription = null, tint = SlateMuted, modifier = Modifier.size(14.dp))
                        Spacer(modifier = Modifier.width(6.dp))
                        Text(
                            text = "Code expires in $otpTtlMinutes minutes",
                            fontSize = 12.sp,
                            color = SlateMuted,
                            fontWeight = FontWeight.Medium
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(28.dp))

            if (!isVerified) {
                // OTP Input Field (6 Digits)
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(16.dp),
                    colors = CardDefaults.cardColors(containerColor = SurfaceLight),
                    border = BorderStroke(1.dp, SlateBorder)
                ) {
                    Column(
                        modifier = Modifier.padding(20.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Text(
                            "Enter 6-Digit OTP",
                            fontSize = 13.sp,
                            fontWeight = FontWeight.SemiBold,
                            color = SlateMuted
                        )

                        Spacer(modifier = Modifier.height(16.dp))

                        // 6 Digit boxes
                        Row(
                            horizontalArrangement = Arrangement.spacedBy(8.dp),
                            modifier = Modifier.fillMaxWidth(),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            for (i in 0 until 6) {
                                val char = otp.getOrNull(i)?.toString() ?: ""
                                val isFocused = otp.length == i
                                Box(
                                    modifier = Modifier
                                        .weight(1f)
                                        .height(56.dp)
                                        .background(
                                            if (char.isNotEmpty()) Color(0xFFEFF6FF) else SlateSubtle,
                                            shape = RoundedCornerShape(10.dp)
                                        )
                                        .border(
                                            width = if (isFocused) 2.dp else 1.dp,
                                            color = if (isFocused) NavyPrimary else if (char.isNotEmpty()) NavyPrimary.copy(alpha = 0.4f) else SlateBorder,
                                            shape = RoundedCornerShape(10.dp)
                                        ),
                                    contentAlignment = Alignment.Center
                                ) {
                                    Text(
                                        text = char,
                                        fontSize = 22.sp,
                                        fontWeight = FontWeight.Bold,
                                        color = NavyPrimary
                                    )
                                }
                            }
                        }

                        // Invisible actual text field on top
                        BasicTextField(
                            value = otp,
                            onValueChange = {
                                if (it.length <= 6 && it.all { ch -> ch.isDigit() }) {
                                    otp = it
                                }
                            },
                            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(0.dp)
                                .testTag("otp_hidden_input")
                        )

                        Spacer(modifier = Modifier.height(16.dp))

                        // Visible fallback text field for accessibility & ease
                        OutlinedTextField(
                            value = otp,
                            onValueChange = {
                                if (it.length <= 6 && it.all { ch -> ch.isDigit() }) {
                                    otp = it
                                }
                            },
                            label = { Text("Or type code here") },
                            placeholder = { Text("123456") },
                            singleLine = true,
                            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                            modifier = Modifier
                                .fillMaxWidth()
                                .testTag("otp_input")
                        )

                        Spacer(modifier = Modifier.height(20.dp))

                        // Verify Button
                        Button(
                            onClick = {
                                if (otp.length < 6) {
                                    onShowMessage("Please enter the complete 6-digit OTP code")
                                    return@Button
                                }
                                isLoading = true
                                scope.launch {
                                    val result = repository.registerVerification(
                                        uniEmail = email,
                                        token = token,
                                        otp = otp
                                    )
                                    isLoading = false
                                    if (result.isSuccess) {
                                        val resp = result.getOrNull()!!
                                        serverMessage = resp.message
                                        isVerified = true
                                        onShowMessage(resp.message.ifEmpty { "Verification successful!" })
                                    } else {
                                        onShowMessage("Verification failed: ${result.exceptionOrNull()?.message ?: "Invalid OTP"}")
                                    }
                                }
                            },
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(50.dp)
                                .testTag("verify_otp_button"),
                            shape = RoundedCornerShape(12.dp),
                            colors = ButtonDefaults.buttonColors(containerColor = NavyPrimary),
                            enabled = !isLoading && otp.length >= 6
                        ) {
                            if (isLoading) {
                                CircularProgressIndicator(color = Color.White, modifier = Modifier.size(22.dp))
                            } else {
                                Text("Verify & Activate", fontWeight = FontWeight.Bold, fontSize = 16.sp)
                            }
                        }
                    }
                }
            } else {
                // Verified State: Proceed to Login
                Button(
                    onClick = { onVerifySuccess(email) },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(50.dp)
                        .testTag("continue_to_login_button"),
                    shape = RoundedCornerShape(12.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = NavyPrimary)
                ) {
                    Text("Proceed to Sign In", fontWeight = FontWeight.Bold, fontSize = 16.sp)
                }
            }

            Spacer(modifier = Modifier.height(20.dp))

            if (!isVerified) {
                TextButton(onClick = onBack) {
                    Text("Change email / Back to registration", color = SlateMuted, fontSize = 13.sp)
                }
            }
        }
    }
}
