package com.scpdocs.app

import android.annotation.SuppressLint
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.ChevronRight
import androidx.compose.material3.Button
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import kotlinx.coroutines.launch

private val ScpDarkColorScheme = darkColorScheme(
    primary = Color(0xFFBDBDBD),
    onPrimary = Color.Black,
    background = Color.Black,
    onBackground = Color.White,
    surface = Color.Black,
    onSurface = Color.White,
    surfaceVariant = Color(0xFF1C1C1C),
    onSurfaceVariant = Color(0xFFB3B3B3),
)

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme(colorScheme = ScpDarkColorScheme) {
                ScpDocsRoot()
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun ScpDocsRoot() {
    var sheetItem by remember { mutableStateOf<ScpJpSeriesItem?>(null) }
    var webItem by remember { mutableStateOf<ScpJpSeriesItem?>(null) }
    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)
    val scope = rememberCoroutineScope()
    val context = LocalContext.current

    if (webItem != null) {
        val item = webItem!!
        SeriesWebScreen(
            item = item,
            onBack = { webItem = null },
        )
    } else {
        Scaffold(
            topBar = {
                TopAppBar(
                    title = { Text("SCP Docs") },
                    colors = TopAppBarDefaults.topAppBarColors(
                        containerColor = Color.Black,
                        titleContentColor = Color.White,
                    ),
                )
            },
            containerColor = Color.Black,
        ) { inner ->
            LazyColumn(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(inner)
                    .padding(horizontal = 16.dp, vertical = 12.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp),
            ) {
                items(ScpJpSeriesCatalog.items) { item ->
                    SeriesRow(item = item, onClick = { sheetItem = item })
                }
            }
        }
    }

    if (sheetItem != null) {
        val item = sheetItem!!
        ModalBottomSheet(
            onDismissRequest = { sheetItem = null },
            sheetState = sheetState,
            containerColor = Color(0xFF1A1A1A),
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp, vertical = 8.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp),
            ) {
                Text(
                    text = item.label,
                    style = MaterialTheme.typography.titleMedium,
                    color = Color.White,
                )
                Text(
                    text = item.rangeDescription,
                    style = MaterialTheme.typography.bodySmall,
                    color = Color.White.copy(alpha = 0.7f),
                )
                Text(
                    text = item.url,
                    style = MaterialTheme.typography.bodySmall,
                    color = Color.White.copy(alpha = 0.5f),
                    fontFamily = FontFamily.Monospace,
                )
                Button(
                    onClick = {
                        scope.launch {
                            sheetState.hide()
                            sheetItem = null
                            webItem = item
                        }
                    },
                    modifier = Modifier.fillMaxWidth(),
                ) {
                    Text("アプリ内の WebView で開く")
                }
                OutlinedButton(
                    onClick = {
                        context.startActivity(
                            Intent(Intent.ACTION_VIEW, Uri.parse(item.url)),
                        )
                        scope.launch {
                            sheetState.hide()
                            sheetItem = null
                        }
                    },
                    modifier = Modifier.fillMaxWidth(),
                ) {
                    Text("外部ブラウザで開く")
                }
                Spacer(modifier = Modifier.height(16.dp))
            }
        }
    }
}

@Composable
private fun SeriesRow(item: ScpJpSeriesItem, onClick: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(Color(0xFF1C1C1C), RoundedCornerShape(12.dp))
            .clickable(onClick = onClick)
            .padding(18.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = item.label,
                style = MaterialTheme.typography.titleMedium,
                color = Color.White,
            )
            Spacer(modifier = Modifier.height(6.dp))
            Text(
                text = item.rangeDescription,
                style = MaterialTheme.typography.bodySmall,
                color = Color.White.copy(alpha = 0.7f),
            )
        }
        Icon(
            imageVector = Icons.Default.ChevronRight,
            contentDescription = null,
            tint = Color(0xFF737373),
        )
    }
}

@SuppressLint("SetJavaScriptEnabled")
@Composable
private fun SeriesWebScreen(item: ScpJpSeriesItem, onBack: () -> Unit) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = item.label,
                        maxLines = 1,
                    )
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(
                            imageVector = Icons.Filled.ArrowBack,
                            contentDescription = "戻る",
                        )
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = Color.Black,
                    titleContentColor = Color.White,
                    navigationIconContentColor = Color.White,
                ),
            )
        },
        containerColor = Color.Black,
    ) { inner ->
        AndroidView(
            modifier = Modifier
                .fillMaxSize()
                .padding(inner),
            factory = { ctx ->
                WebView(ctx).apply {
                    settings.javaScriptEnabled = true
                    webViewClient = WebViewClient()
                    loadUrl(item.url)
                }
            },
            update = { webView ->
                if (webView.url != item.url) {
                    webView.loadUrl(item.url)
                }
            },
        )
    }
}
