package com.example.data

import com.squareup.moshi.Json
import com.squareup.moshi.JsonClass

@JsonClass(generateAdapter = true)
data class GeoLocation(
    val latitude: Double = 0.0,
    val longitude: Double = 0.0
)

@JsonClass(generateAdapter = true)
data class ItemResponse(
    val id: String = "",
    val type: String = "LOST", // LOST or FOUND
    val title: String = "",
    val description: String = "",
    val status: String = "OPEN", // OPEN, CLOSED, MATCHED, CLAIMED
    val location: String = "",
    val imageUrl: String? = null,
    val reportedByName: String? = null,
    val createdAt: String? = null,
    val eventFrom: String? = null,
    val eventTo: String? = null,
    val geoLocation: GeoLocation? = null
)

@JsonClass(generateAdapter = true)
data class UserSummary(
    val id: String = "",
    val uniEmail: String = "",
    val role: String = "STUDENT"
)

@JsonClass(generateAdapter = true)
data class TokenResponse(
    val accessToken: String = "",
    val tokenType: String = "Bearer",
    val expiresIn: Long = 3600L,
    val user: UserSummary? = null,
    val timestamp: String? = null
)

// Legacy alias for compatibility
typealias AuthResponse = TokenResponse

@JsonClass(generateAdapter = true)
data class RegisterRequest(
    val firstName: String,
    val lastName: String = "",
    val personalEmail: String = "",
    val registrationNumber: Long = 0L,
    val uniEmail: String,
    val phoneNumber: String,
    val password: String,
    val department: String = ""
)

@JsonClass(generateAdapter = true)
data class RegisterResponse(
    val uniEmail: String = "",
    val token: String = "",
    val otpTtlMinutes: Long = 10L
)

@JsonClass(generateAdapter = true)
data class VerifyRegistrationRequest(
    val uniEmail: String,
    val token: String,
    val otp: String
)

@JsonClass(generateAdapter = true)
data class RegistrationVerifyResponse(
    val uniEmail: String = "",
    val message: String = ""
)

@JsonClass(generateAdapter = true)
data class LoginRequest(
    val uniEmail: String,
    val password: String
)

@JsonClass(generateAdapter = true)
data class UpdateItemStatusRequest(
    val status: String // OPEN, CLOSED, MATCHED, CLAIMED
)

// Legacy alias
typealias StatusUpdateRequest = UpdateItemStatusRequest

@JsonClass(generateAdapter = true)
data class PageItemResponse(
    val content: List<ItemResponse> = emptyList(),
    val totalElements: Long = 0L,
    val totalPages: Int = 0,
    val size: Int = 20,
    val number: Int = 0,
    val first: Boolean = true,
    val last: Boolean = true,
    val empty: Boolean = false
)

// Legacy alias
typealias PageResponse = PageItemResponse
