package com.example.ui.components

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.ui.theme.getStatusColors
import com.example.ui.theme.getTypeColors

@Composable
fun StatusPill(
    status: String,
    modifier: Modifier = Modifier,
    fontSize: TextUnit = 11.sp,
    horizontalPadding: Dp = 8.dp,
    verticalPadding: Dp = 2.dp
) {
    val pillColors = getStatusColors(status)

    Surface(
        modifier = modifier,
        shape = RoundedCornerShape(6.dp),
        color = pillColors.background,
        border = BorderStroke(1.dp, pillColors.border)
    ) {
        Text(
            text = status.uppercase(),
            fontSize = fontSize,
            fontWeight = FontWeight.Bold,
            color = pillColors.text,
            letterSpacing = 0.3.sp,
            modifier = Modifier.padding(horizontal = horizontalPadding, vertical = verticalPadding)
        )
    }
}

@Composable
fun TypeBadge(
    type: String,
    modifier: Modifier = Modifier,
    fontSize: TextUnit = 11.sp,
    horizontalPadding: Dp = 8.dp,
    verticalPadding: Dp = 2.dp
) {
    val pillColors = getTypeColors(type)

    Surface(
        modifier = modifier,
        shape = RoundedCornerShape(6.dp),
        color = pillColors.background,
        border = BorderStroke(1.dp, pillColors.border)
    ) {
        Text(
            text = type.uppercase(),
            fontSize = fontSize,
            fontWeight = FontWeight.Bold,
            color = pillColors.text,
            letterSpacing = 0.3.sp,
            modifier = Modifier.padding(horizontal = horizontalPadding, vertical = verticalPadding)
        )
    }
}
