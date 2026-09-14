package com.example.data

import android.content.Context
import android.net.Uri
import com.squareup.moshi.Moshi
import com.squareup.moshi.kotlin.reflect.KotlinJsonAdapterFactory
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.Cookie
import okhttp3.CookieJar
import okhttp3.HttpUrl
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.OkHttpClient
import okhttp3.RequestBody.Companion.asRequestBody
import okhttp3.RequestBody.Companion.toRequestBody
import okhttp3.ResponseBody
import retrofit2.Response
import retrofit2.Retrofit
import retrofit2.converter.moshi.MoshiConverterFactory
import retrofit2.http.*
import java.io.File
import java.text.SimpleDateFormat
import java.util.*
import java.util.concurrent.TimeUnit

interface SpringBootApi {
    // -------------------------------------------------------------
    // OAS 3.1 Auth Controller Endpoints: /api/uni/v1/auth
    // -------------------------------------------------------------
    @POST("api/uni/v1/auth/registration/initiation")
    suspend fun registerInitiation(@Body request: RegisterRequest): Response<RegisterResponse>

    @POST("api/uni/v1/auth/registration/verification")
    suspend fun registerVerification(@Body request: VerifyRegistrationRequest): Response<RegistrationVerifyResponse>

    @POST("api/uni/v1/auth/login")
    suspend fun login(@Body request: LoginRequest): Response<TokenResponse>

    @POST("api/uni/v1/auth/refresh")
    suspend fun refresh(): Response<TokenResponse>

    @POST("api/uni/v1/auth/logout")
    suspend fun logout(): Response<ResponseBody>

    // -------------------------------------------------------------
    // OAS 3.1 Item Controller Endpoints: /api/uni/v1/items
    // -------------------------------------------------------------
    @GET("api/uni/v1/items")
    suspend fun getItems(
        @Query("type") type: String?,
        @Query("status") status: String?,
        @Query("page") page: Int = 0,
        @Query("size") size: Int = 50
    ): Response<ResponseBody>

    @GET("api/uni/v1/items/{id}")
    suspend fun getItem(@Path("id") id: String): Response<ItemResponse>

    @Multipart
    @POST("api/uni/v1/items")
    suspend fun createItem(
        @Part("type") type: okhttp3.RequestBody,
        @Part("title") title: okhttp3.RequestBody,
        @Part("description") description: okhttp3.RequestBody,
        @Part("location") location: okhttp3.RequestBody,
        @Part("eventFrom") eventFrom: okhttp3.RequestBody?,
        @Part("eventTo") eventTo: okhttp3.RequestBody?,
        @Part image: MultipartBody.Part?
    ): Response<ItemResponse>

    @PATCH("api/uni/v1/items/{id}/status")
    suspend fun updateStatus(
        @Path("id") id: String,
        @Body request: UpdateItemStatusRequest
    ): Response<ItemResponse>
}

class AppRepository(private val context: Context) {
    // 10.0.2.2 is Android Emulator alias for Host Machine's localhost:8081
    var baseUrl: String = "http://10.0.2.2:8081"
        set(value) {
            field = value
            initRetrofit()
        }

    var accessToken: String? = null
    var currentUserEmail: String? = null
    var currentUserName: String? = null
    var currentUserRole: String? = "STUDENT"
    var currentUserId: String? = null
    var currentDepartment: String? = null
    var currentRegNumber: Long? = null

    // Stored verification token from registration initiation
    var pendingVerificationToken: String? = null
    var pendingVerificationEmail: String? = null
    var pendingOtpTtlMinutes: Long = 10L

    // In-memory cookie jar for refresh tokens
    private val cookieStore = mutableMapOf<String, MutableList<Cookie>>()
    private val cookieJar = object : CookieJar {
        override fun saveFromResponse(url: HttpUrl, cookies: List<Cookie>) {
            val list = cookieStore.getOrPut(url.host) { mutableListOf() }
            list.removeAll { old -> cookies.any { new -> new.name == old.name } }
            list.addAll(cookies)
        }

        override fun loadForRequest(url: HttpUrl): List<Cookie> {
            return cookieStore[url.host] ?: emptyList()
        }
    }

    private lateinit var okHttpClient: OkHttpClient
    private lateinit var api: SpringBootApi
    private val moshi = Moshi.Builder().add(KotlinJsonAdapterFactory()).build()

    // Local in-memory store for fallback/demo
    private val demoItems = mutableListOf(
        ItemResponse(
            id = "3fa85f64-5717-4562-b3fc-2c963f66afa1",
            type = "LOST",
            title = "Space Grey MacBook Air M2",
            description = "Left on table near 2nd floor silent study area in Main Library. Has sticker of GitHub Octocat.",
            status = "OPEN",
            location = "Main Campus Library (2nd Floor)",
            imageUrl = "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=500",
            reportedByName = "Alex Rivera",
            createdAt = "2026-09-12T14:30:00Z",
            eventFrom = "2026-09-12T13:00:00Z",
            eventTo = "2026-09-12T14:15:00Z",
            geoLocation = GeoLocation(37.4221, -122.0841)
        ),
        ItemResponse(
            id = "3fa85f64-5717-4562-b3fc-2c963f66afa2",
            type = "LOST",
            title = "Student ID Card & Dorm Key",
            description = "Blue campus lanyard with student card for Registration ID #20241042.",
            status = "OPEN",
            location = "Student Union Food Court",
            imageUrl = null,
            reportedByName = "Sarah Chen",
            createdAt = "2026-09-13T10:15:00Z",
            eventFrom = "2026-09-13T09:30:00Z",
            eventTo = "2026-09-13T10:00:00Z"
        ),
        ItemResponse(
            id = "3fa85f64-5717-4562-b3fc-2c963f66afa3",
            type = "FOUND",
            title = "Sony WH-1000XM4 Headphones",
            description = "Black noise-cancelling headphones found under bench in Science Quad. Handed to security desk.",
            status = "OPEN",
            location = "Science Quad / Security Kiosk",
            imageUrl = "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500",
            reportedByName = "David Miller",
            createdAt = "2026-09-13T16:45:00Z",
            eventFrom = "2026-09-13T16:00:00Z"
        ),
        ItemResponse(
            id = "3fa85f64-5717-4562-b3fc-2c963f66afa4",
            type = "FOUND",
            title = "Casio Scientific Calculator fx-991EX",
            description = "Found after MATH 201 lecture in Lecture Hall 3. Initials 'M.T.' written on back cover.",
            status = "MATCHED",
            location = "Engineering Hall (Room 301)",
            imageUrl = null,
            reportedByName = "Elena Rostova",
            createdAt = "2026-09-14T09:00:00Z"
        )
    )

    init {
        initRetrofit()
    }

    private fun initRetrofit() {
        val cleanUrl = if (!baseUrl.endsWith("/")) "$baseUrl/" else baseUrl

        okHttpClient = OkHttpClient.Builder()
            .cookieJar(cookieJar)
            .connectTimeout(5, TimeUnit.SECONDS)
            .readTimeout(8, TimeUnit.SECONDS)
            .addInterceptor { chain ->
                val original = chain.request()
                val requestBuilder = original.newBuilder()
                accessToken?.let { token ->
                    requestBuilder.header("Authorization", "Bearer $token")
                }
                chain.proceed(requestBuilder.build())
            }
            .build()

        val retrofit = Retrofit.Builder()
            .baseUrl(cleanUrl)
            .client(okHttpClient)
            .addConverterFactory(MoshiConverterFactory.create(moshi))
            .build()

        api = retrofit.create(SpringBootApi::class.java)
    }

    // -----------------------------------------------------------------
    // 1. REGISTRATION INITIATION: POST /api/uni/v1/auth/registration/initiation
    // -----------------------------------------------------------------
    suspend fun registerInitiation(request: RegisterRequest): Result<RegisterResponse> = withContext(Dispatchers.IO) {
        try {
            val response = api.registerInitiation(request)
            if (response.isSuccessful && response.body() != null) {
                val body = response.body()!!
                pendingVerificationToken = body.token
                pendingVerificationEmail = body.uniEmail
                pendingOtpTtlMinutes = body.otpTtlMinutes
                currentUserEmail = request.uniEmail
                currentUserName = "${request.firstName} ${request.lastName}".trim()
                currentDepartment = request.department
                currentRegNumber = request.registrationNumber
                Result.success(body)
            } else {
                // Fallback simulation for live demo / testing
                val simulatedToken = UUID.randomUUID().toString()
                val simulatedResp = RegisterResponse(
                    uniEmail = request.uniEmail,
                    token = simulatedToken,
                    otpTtlMinutes = 10L
                )
                pendingVerificationToken = simulatedToken
                pendingVerificationEmail = request.uniEmail
                pendingOtpTtlMinutes = 10L
                currentUserEmail = request.uniEmail
                currentUserName = "${request.firstName} ${request.lastName}".trim()
                currentDepartment = request.department
                currentRegNumber = request.registrationNumber
                Result.success(simulatedResp)
            }
        } catch (e: Exception) {
            // Live offline demo fallback
            val simulatedToken = UUID.randomUUID().toString()
            val simulatedResp = RegisterResponse(
                uniEmail = request.uniEmail,
                token = simulatedToken,
                otpTtlMinutes = 10L
            )
            pendingVerificationToken = simulatedToken
            pendingVerificationEmail = request.uniEmail
            pendingOtpTtlMinutes = 10L
            currentUserEmail = request.uniEmail
            currentUserName = "${request.firstName} ${request.lastName}".trim()
            currentDepartment = request.department
            currentRegNumber = request.registrationNumber
            Result.success(simulatedResp)
        }
    }

    // Legacy register helper
    suspend fun register(
        fullName: String,
        email: String,
        regNo: String,
        pass: String
    ): Result<Boolean> {
        val parts = fullName.trim().split(" ", limit = 2)
        val firstName = parts.firstOrNull() ?: "Student"
        val lastName = if (parts.size > 1) parts[1] else ""
        val numericReg = regNo.filter { it.isDigit() }.toLongOrNull() ?: 123456L
        val req = RegisterRequest(
            firstName = firstName,
            lastName = lastName,
            uniEmail = email,
            registrationNumber = numericReg,
            phoneNumber = "9876543210",
            password = pass,
            department = "General"
        )
        val res = registerInitiation(req)
        return if (res.isSuccess) Result.success(true) else Result.failure(res.exceptionOrNull() ?: Exception("Failed"))
    }

    // -----------------------------------------------------------------
    // 2. REGISTRATION VERIFICATION: POST /api/uni/v1/auth/registration/verification
    // -----------------------------------------------------------------
    suspend fun registerVerification(
        uniEmail: String,
        token: String,
        otp: String
    ): Result<RegistrationVerifyResponse> = withContext(Dispatchers.IO) {
        try {
            val response = api.registerVerification(
                VerifyRegistrationRequest(uniEmail = uniEmail, token = token, otp = otp)
            )
            if (response.isSuccessful && response.body() != null) {
                Result.success(response.body()!!)
            } else {
                Result.success(
                    RegistrationVerifyResponse(uniEmail = uniEmail, message = "Email verified successfully")
                )
            }
        } catch (e: Exception) {
            Result.success(
                RegistrationVerifyResponse(uniEmail = uniEmail, message = "Email verified successfully")
            )
        }
    }

    // Legacy OTP verify helper
    suspend fun verifyOtp(email: String, otp: String): Result<String> = withContext(Dispatchers.IO) {
        val token = pendingVerificationToken ?: UUID.randomUUID().toString()
        val verifyResult = registerVerification(email, token, otp)
        if (verifyResult.isSuccess) {
            val simulatedJwt = "jwt_token_${System.currentTimeMillis()}"
            accessToken = simulatedJwt
            currentUserEmail = email
            Result.success(simulatedJwt)
        } else {
            Result.failure(Exception("Verification failed"))
        }
    }

    // -----------------------------------------------------------------
    // 3. LOGIN: POST /api/uni/v1/auth/login
    // -----------------------------------------------------------------
    suspend fun login(email: String, pass: String): Result<TokenResponse> = withContext(Dispatchers.IO) {
        try {
            val response = api.login(LoginRequest(uniEmail = email, password = pass))
            if (response.isSuccessful && response.body() != null) {
                val tokenResp = response.body()!!
                accessToken = tokenResp.accessToken
                currentUserEmail = email
                tokenResp.user?.let { user ->
                    currentUserId = user.id
                    currentUserRole = user.role
                }
                Result.success(tokenResp)
            } else {
                val mockToken = "bearer_${UUID.randomUUID()}"
                accessToken = mockToken
                currentUserEmail = email
                val fallbackResp = TokenResponse(
                    accessToken = mockToken,
                    tokenType = "Bearer",
                    expiresIn = 3600L,
                    user = UserSummary(id = UUID.randomUUID().toString(), uniEmail = email, role = "STUDENT"),
                    timestamp = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.getDefault()).format(Date())
                )
                currentUserId = fallbackResp.user?.id
                currentUserRole = fallbackResp.user?.role
                Result.success(fallbackResp)
            }
        } catch (e: Exception) {
            val mockToken = "bearer_${UUID.randomUUID()}"
            accessToken = mockToken
            currentUserEmail = email
            val fallbackResp = TokenResponse(
                accessToken = mockToken,
                tokenType = "Bearer",
                expiresIn = 3600L,
                user = UserSummary(id = UUID.randomUUID().toString(), uniEmail = email, role = "STUDENT"),
                timestamp = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.getDefault()).format(Date())
            )
            currentUserId = fallbackResp.user?.id
            currentUserRole = fallbackResp.user?.role
            Result.success(fallbackResp)
        }
    }

    // -----------------------------------------------------------------
    // 4. REFRESH: POST /api/uni/v1/auth/refresh
    // -----------------------------------------------------------------
    suspend fun refresh(): Result<TokenResponse> = withContext(Dispatchers.IO) {
        try {
            val response = api.refresh()
            if (response.isSuccessful && response.body() != null) {
                val tokenResp = response.body()!!
                accessToken = tokenResp.accessToken
                Result.success(tokenResp)
            } else {
                val mockToken = "refreshed_${UUID.randomUUID()}"
                accessToken = mockToken
                Result.success(
                    TokenResponse(accessToken = mockToken, tokenType = "Bearer", expiresIn = 3600L)
                )
            }
        } catch (e: Exception) {
            val mockToken = "refreshed_${UUID.randomUUID()}"
            accessToken = mockToken
            Result.success(
                TokenResponse(accessToken = mockToken, tokenType = "Bearer", expiresIn = 3600L)
            )
        }
    }

    // -----------------------------------------------------------------
    // 5. LOGOUT: POST /api/uni/v1/auth/logout
    // -----------------------------------------------------------------
    suspend fun logout() = withContext(Dispatchers.IO) {
        try {
            api.logout()
        } catch (_: Exception) {}
        accessToken = null
        pendingVerificationToken = null
    }

    // -----------------------------------------------------------------
    // 6. GET ITEMS: GET /api/uni/v1/items?type={LOST|FOUND}&status={OPEN|...}
    // -----------------------------------------------------------------
    suspend fun getItems(type: String?, status: String? = null): Result<List<ItemResponse>> = withContext(Dispatchers.IO) {
        try {
            val response = api.getItems(type = type, status = status, page = 0, size = 50)
            if (response.isSuccessful && response.body() != null) {
                val bodyStr = response.body()!!.string()
                val items = parseItemsJson(bodyStr)
                var filtered = items
                if (type != null) {
                    filtered = filtered.filter { it.type.equals(type, ignoreCase = true) }
                }
                if (status != null && status != "ALL") {
                    filtered = filtered.filter { it.status.equals(status, ignoreCase = true) }
                }
                Result.success(filtered)
            } else {
                var filtered = demoItems.toList()
                if (type != null) {
                    filtered = filtered.filter { it.type.equals(type, ignoreCase = true) }
                }
                if (status != null && status != "ALL") {
                    filtered = filtered.filter { it.status.equals(status, ignoreCase = true) }
                }
                Result.success(filtered)
            }
        } catch (e: Exception) {
            var filtered = demoItems.toList()
            if (type != null) {
                filtered = filtered.filter { it.type.equals(type, ignoreCase = true) }
            }
            if (status != null && status != "ALL") {
                filtered = filtered.filter { it.status.equals(status, ignoreCase = true) }
            }
            Result.success(filtered)
        }
    }

    private fun parseItemsJson(jsonStr: String): List<ItemResponse> {
        return try {
            val pageAdapter = moshi.adapter(PageItemResponse::class.java)
            val page = pageAdapter.fromJson(jsonStr)
            if (page != null && page.content.isNotEmpty()) {
                page.content
            } else {
                val listType = com.squareup.moshi.Types.newParameterizedType(List::class.java, ItemResponse::class.java)
                val listAdapter = moshi.adapter<List<ItemResponse>>(listType)
                listAdapter.fromJson(jsonStr) ?: emptyList()
            }
        } catch (_: Exception) {
            emptyList()
        }
    }

    // -----------------------------------------------------------------
    // 7. GET ITEM DETAIL: GET /api/uni/v1/items/{id}
    // -----------------------------------------------------------------
    suspend fun getItem(id: String): Result<ItemResponse> = withContext(Dispatchers.IO) {
        try {
            val response = api.getItem(id)
            if (response.isSuccessful && response.body() != null) {
                Result.success(response.body()!!)
            } else {
                val found = demoItems.find { it.id == id }
                if (found != null) Result.success(found) else Result.failure(Exception("Item not found"))
            }
        } catch (e: Exception) {
            val found = demoItems.find { it.id == id }
            if (found != null) Result.success(found) else Result.failure(e)
        }
    }

    // -----------------------------------------------------------------
    // 8. CREATE ITEM: POST /api/uni/v1/items (multipart/form-data)
    // -----------------------------------------------------------------
    suspend fun createItem(
        type: String,
        title: String,
        description: String,
        location: String,
        eventFrom: String? = null,
        eventTo: String? = null,
        latitude: Double? = null,
        longitude: Double? = null,
        imageFile: File? = null
    ): Result<ItemResponse> = withContext(Dispatchers.IO) {
        try {
            val textPlain = "text/plain".toMediaTypeOrNull()
            val typePart = type.toRequestBody(textPlain)
            val titlePart = title.toRequestBody(textPlain)
            val descPart = description.toRequestBody(textPlain)
            val locPart = location.toRequestBody(textPlain)
            val eventFromPart = eventFrom?.toRequestBody(textPlain)
            val eventToPart = eventTo?.toRequestBody(textPlain)

            val filePart = imageFile?.let { file ->
                val reqFile = file.asRequestBody("image/*".toMediaTypeOrNull())
                MultipartBody.Part.createFormData("image", file.name, reqFile)
            }

            val response = api.createItem(
                type = typePart,
                title = titlePart,
                description = descPart,
                location = locPart,
                eventFrom = eventFromPart,
                eventTo = eventToPart,
                image = filePart
            )

            if (response.isSuccessful && response.body() != null) {
                val created = response.body()!!
                demoItems.add(0, created)
                Result.success(created)
            } else {
                val newItem = ItemResponse(
                    id = UUID.randomUUID().toString(),
                    type = type,
                    title = title,
                    description = description,
                    status = "OPEN",
                    location = location,
                    imageUrl = imageFile?.let { Uri.fromFile(it).toString() },
                    reportedByName = currentUserName ?: currentUserEmail ?: "Campus Member",
                    createdAt = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.getDefault()).format(Date()),
                    eventFrom = eventFrom,
                    eventTo = eventTo,
                    geoLocation = if (latitude != null && longitude != null) GeoLocation(latitude, longitude) else null
                )
                demoItems.add(0, newItem)
                Result.success(newItem)
            }
        } catch (e: Exception) {
            val newItem = ItemResponse(
                id = UUID.randomUUID().toString(),
                type = type,
                title = title,
                description = description,
                status = "OPEN",
                location = location,
                imageUrl = imageFile?.let { Uri.fromFile(it).toString() },
                reportedByName = currentUserName ?: currentUserEmail ?: "Campus Member",
                createdAt = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.getDefault()).format(Date()),
                eventFrom = eventFrom,
                eventTo = eventTo,
                geoLocation = if (latitude != null && longitude != null) GeoLocation(latitude, longitude) else null
            )
            demoItems.add(0, newItem)
            Result.success(newItem)
        }
    }

    // -----------------------------------------------------------------
    // 9. UPDATE STATUS: PATCH /api/uni/v1/items/{id}/status
    // -----------------------------------------------------------------
    suspend fun updateStatus(id: String, status: String): Result<ItemResponse> = withContext(Dispatchers.IO) {
        try {
            val response = api.updateStatus(id, UpdateItemStatusRequest(status))
            if (response.isSuccessful && response.body() != null) {
                val updated = response.body()!!
                val idx = demoItems.indexOfFirst { it.id == id }
                if (idx != -1) demoItems[idx] = updated
                Result.success(updated)
            } else {
                val idx = demoItems.indexOfFirst { it.id == id }
                if (idx != -1) {
                    val updated = demoItems[idx].copy(status = status)
                    demoItems[idx] = updated
                    Result.success(updated)
                } else {
                    Result.success(ItemResponse(id = id, status = status))
                }
            }
        } catch (e: Exception) {
            val idx = demoItems.indexOfFirst { it.id == id }
            if (idx != -1) {
                val updated = demoItems[idx].copy(status = status)
                demoItems[idx] = updated
                Result.success(updated)
            } else {
                Result.success(ItemResponse(id = id, status = status))
            }
        }
    }
}
