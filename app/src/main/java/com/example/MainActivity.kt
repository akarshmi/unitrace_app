package com.example

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.BackHandler
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import com.example.data.AppRepository
import com.example.ui.screens.*
import com.example.ui.theme.*
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            MyApplicationTheme {
                UniTraceApp()
            }
        }
    }
}

@Composable
fun UniTraceApp() {
    val context = LocalContext.current
    val repository = remember { AppRepository(context) }
    val scope = rememberCoroutineScope()
    val snackbarHostState = remember { SnackbarHostState() }

    var currentScreen by remember { mutableStateOf<Screen>(Screen.Login) }
    var screenStack by remember { mutableStateOf(listOf<Screen>(Screen.Login)) }

    fun navigateTo(screen: Screen, clearStack: Boolean = false) {
        if (clearStack) {
            screenStack = listOf(screen)
        } else {
            screenStack = screenStack + screen
        }
        currentScreen = screen
    }

    fun popBack() {
        if (screenStack.size > 1) {
            screenStack = screenStack.dropLast(1)
            currentScreen = screenStack.last()
        }
    }

    BackHandler(enabled = screenStack.size > 1) {
        popBack()
    }

    Scaffold(
        modifier = Modifier.fillMaxSize(),
        snackbarHost = { SnackbarHost(snackbarHostState) },
        contentWindowInsets = WindowInsets.safeDrawing
    ) { innerPadding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .background(SlateBackground)
        ) {
            when (val screen = currentScreen) {
                is Screen.Login -> LoginScreen(
                    repository = repository,
                    onLoginSuccess = { navigateTo(Screen.Home, clearStack = true) },
                    onNavigateToRegister = { navigateTo(Screen.Register) },
                    onShowMessage = { msg -> scope.launch { snackbarHostState.showSnackbar(msg) } }
                )

                is Screen.Register -> RegisterScreen(
                    repository = repository,
                    onRegisterSuccess = { email, token, ttlMinutes ->
                        navigateTo(Screen.Verification(email, token, ttlMinutes))
                    },
                    onBackToLogin = { popBack() },
                    onShowMessage = { msg -> scope.launch { snackbarHostState.showSnackbar(msg) } }
                )

                is Screen.Verification -> VerificationScreen(
                    email = screen.email,
                    token = screen.token,
                    otpTtlMinutes = screen.otpTtlMinutes,
                    repository = repository,
                    onVerifySuccess = {
                        navigateTo(Screen.Login, clearStack = true)
                    },
                    onBack = { popBack() },
                    onShowMessage = { msg -> scope.launch { snackbarHostState.showSnackbar(msg) } }
                )

                is Screen.Home -> HomeScreen(
                    repository = repository,
                    onCreateItem = { type -> navigateTo(Screen.CreateItem(type)) },
                    onItemClick = { item -> navigateTo(Screen.ItemDetail(item)) },
                    onNavigateToProfile = { navigateTo(Screen.Profile) },
                    onLogout = {
                        scope.launch { repository.logout() }
                        navigateTo(Screen.Login, clearStack = true)
                    },
                    onShowMessage = { msg -> scope.launch { snackbarHostState.showSnackbar(msg) } }
                )

                is Screen.CreateItem -> CreateItemScreen(
                    initialType = screen.initialType,
                    repository = repository,
                    onItemCreated = { popBack() },
                    onBack = { popBack() },
                    onShowMessage = { msg -> scope.launch { snackbarHostState.showSnackbar(msg) } }
                )

                is Screen.ItemDetail -> ItemDetailScreen(
                    item = screen.item,
                    repository = repository,
                    onBack = { popBack() },
                    onStatusUpdated = { updatedItem ->
                        currentScreen = Screen.ItemDetail(updatedItem)
                    },
                    onShowMessage = { msg -> scope.launch { snackbarHostState.showSnackbar(msg) } }
                )

                is Screen.Profile -> ProfileScreen(
                    repository = repository,
                    onBack = { popBack() },
                    onLogout = {
                        navigateTo(Screen.Login, clearStack = true)
                    },
                    onShowMessage = { msg -> scope.launch { snackbarHostState.showSnackbar(msg) } }
                )
            }
        }
    }
}
