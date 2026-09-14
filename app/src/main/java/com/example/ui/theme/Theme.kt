package com.example.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.Immutable
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.graphics.Color

@Immutable
data class UniTraceCustomColors(
    val navyPrimary: Color = NavyPrimary,
    val navySurface: Color = NavySurface,
    val amberAccent: Color = AmberAccent,
    val amberLight: Color = AmberLight,
    val surfaceLight: Color = SurfaceLight,
    val backgroundLight: Color = SlateBackground,
    val slateSubtle: Color = SlateSubtle,
    val slateBorder: Color = SlateBorder,
    val textPrimary: Color = TextPrimary,
    val textBody: Color = TextBody,
    val textMuted: Color = SlateMuted,
    val successGreen: Color = SuccessGreen,
    val errorRed: Color = ErrorRed,
    val warningAmber: Color = WarningAmber,
)

val LocalUniTraceColors = staticCompositionLocalOf { UniTraceCustomColors() }

private val LightColorScheme = lightColorScheme(
    primary = NavyPrimary,
    onPrimary = Color.White,
    primaryContainer = NavySurface,
    onPrimaryContainer = Color.White,
    secondary = AmberAccent,
    onSecondary = NavyPrimary, // Contrast: 7.95:1 (Navy on Amber)
    secondaryContainer = AmberLight,
    onSecondaryContainer = StatusMatchedText,
    surface = SurfaceLight,
    onSurface = TextPrimary,
    surfaceVariant = SlateSubtle,
    onSurfaceVariant = SlateMuted,
    background = SlateBackground,
    onBackground = TextPrimary,
    outline = SlateBorder,
    outlineVariant = Color(0xFFCBD5E1),
    error = ErrorRed,
    onError = Color.White,
)

private val DarkColorScheme = darkColorScheme(
    primary = AmberAccent,
    onPrimary = NavyPrimary,
    secondary = AmberLight,
    onSecondary = NavyPrimary,
    surface = NavySurface,
    onSurface = Color.White,
    background = NavyPrimary,
    onBackground = Color.White,
    outline = SlateMuted,
    error = ErrorRed,
    onError = Color.White,
)

@Composable
fun MyApplicationTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    // Set dynamicColor to false so system wallpaper doesn't corrupt the UniTrace brand palette
    dynamicColor: Boolean = false,
    content: @Composable () -> Unit,
) {
    val colorScheme = if (darkTheme) DarkColorScheme else LightColorScheme
    val customColors = UniTraceCustomColors()

    CompositionLocalProvider(LocalUniTraceColors provides customColors) {
        MaterialTheme(
            colorScheme = colorScheme,
            typography = Typography,
            content = content
        )
    }
}
