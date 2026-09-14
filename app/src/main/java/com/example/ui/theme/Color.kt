package com.example.ui.theme

import androidx.compose.runtime.Immutable
import androidx.compose.ui.graphics.Color

// Brand Core
val NavyPrimary = Color(0xFF0F172A)
val NavySurface = Color(0xFF1E293B)
val AmberAccent = Color(0xFFF59E0B)
val AmberLight = Color(0xFFFEF3C7)

// Surfaces & Backgrounds
val SurfaceLight = Color(0xFFFFFFFF)
val SlateBackground = Color(0xFFF8FAFC)
val SlateSubtle = Color(0xFFF1F5F9)
val SlateBorder = Color(0xFFE2E8F0)

// Text & Semantics
val TextPrimary = Color(0xFF0F172A)
val TextBody = Color(0xFF1E293B)
val SlateMuted = Color(0xFF64748B)

val SuccessGreen = Color(0xFF16A34A)
val ErrorRed = Color(0xFFDC2626)
val WarningAmber = Color(0xFFF59E0B)

// Status Pill Colors (Strict WCAG AA Pairs)
val StatusOpenBg = Color(0xFFDCFCE7)
val StatusOpenText = Color(0xFF166534)
val StatusOpenBorder = Color(0xFFBBF7D0)

val StatusClosedBg = Color(0xFFF1F5F9)
val StatusClosedText = Color(0xFF475569)
val StatusClosedBorder = Color(0xFFE2E8F0)

val StatusMatchedBg = Color(0xFFFEF3C7)
val StatusMatchedText = Color(0xFF92400E)
val StatusMatchedBorder = Color(0xFFFDE68A)

val StatusClaimedBg = Color(0xFFDBEAFE)
val StatusClaimedText = Color(0xFF1E40AF)
val StatusClaimedBorder = Color(0xFFBFDBFE)

// Type Badges (LOST & FOUND)
val TypeLostBg = Color(0xFFFEE2E2)
val TypeLostText = Color(0xFFDC2626)
val TypeLostBorder = Color(0xFFFECACA)

val TypeFoundBg = Color(0xFFDCFCE7)
val TypeFoundText = Color(0xFF16A34A)
val TypeFoundBorder = Color(0xFFBBF7D0)

// Backwards compatibility aliases
val LostRed = TypeLostText
val FoundGreen = TypeFoundText
val StatusLostText = TypeLostText
val StatusLostBg = TypeLostBg
val StatusLostBorder = TypeLostBorder

@Immutable
data class PillColorPair(
    val background: Color,
    val text: Color,
    val border: Color
)

fun getStatusColors(status: String): PillColorPair {
    return when (status.uppercase()) {
        "CLOSED" -> PillColorPair(StatusClosedBg, StatusClosedText, StatusClosedBorder)
        "MATCHED" -> PillColorPair(StatusMatchedBg, StatusMatchedText, StatusMatchedBorder)
        "CLAIMED" -> PillColorPair(StatusClaimedBg, StatusClaimedText, StatusClaimedBorder)
        "OPEN" -> PillColorPair(StatusOpenBg, StatusOpenText, StatusOpenBorder)
        else -> PillColorPair(StatusOpenBg, StatusOpenText, StatusOpenBorder)
    }
}

fun getTypeColors(type: String): PillColorPair {
    return when (type.uppercase()) {
        "FOUND" -> PillColorPair(TypeFoundBg, TypeFoundText, TypeFoundBorder)
        "LOST" -> PillColorPair(TypeLostBg, TypeLostText, TypeLostBorder)
        else -> PillColorPair(TypeLostBg, TypeLostText, TypeLostBorder)
    }
}
