package com.example.ui.screens

import com.example.data.ItemResponse

sealed class Screen {
    object Login : Screen()
    object Register : Screen()
    data class Verification(
        val email: String,
        val token: String,
        val otpTtlMinutes: Long = 10L
    ) : Screen()
    object Home : Screen()
    data class CreateItem(val initialType: String = "LOST") : Screen()
    data class ItemDetail(val item: ItemResponse) : Screen()
    object Profile : Screen()
}
