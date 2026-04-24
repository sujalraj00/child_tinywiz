package com.example.child_tinywiz

import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.provider.Settings
import java.util.*
import kotlin.collections.ArrayList


import android.os.Build
import android.os.Bundle
import android.view.KeyEvent
import android.view.View
import android.view.WindowInsetsController
import android.view.WindowManager
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    private val LOCK_CHANNEL = "com.example.child_tinywiz/lock"
    private val USAGE_STATS_CHANNEL = "app.usage.stats/channel"
    private var isLocked = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        
        // Set up method channel to receive lock status from Flutter
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LOCK_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setLocked" -> {
                    isLocked = call.arguments as Boolean
                    if (isLocked) {
                        // Make fullscreen and hide navigation bars when locked
                        makeFullscreen()
                    } else {
                        // Restore normal mode when unlocked
                        restoreNormalMode()
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        
        // Set up method channel for usage stats
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, USAGE_STATS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getUsageStats" -> {
                    try {
                        val usageStats = getUsageStats()
                        result.success(usageStats)
                    } catch (e: Exception) {
                        result.error("ERROR", "Failed to get usage stats: ${e.message}", null)
                    }
                }
                "hasUsagePermission" -> {
                    result.success(hasUsageStatsPermission())
                }
                "openUsageSettings" -> {
                    openUsageAccessSettings()
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Enable edge-to-edge display
        WindowCompat.setDecorFitsSystemWindows(window, false)
    }

    private fun makeFullscreen() {
        // Hide system UI bars (status bar and navigation bar)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            // Android 11+ (API 30+)
            window.insetsController?.let { controller ->
                controller.hide(WindowInsetsCompat.Type.systemBars())
                controller.systemBarsBehavior = WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
            }
        } else {
            // Android 10 and below
            @Suppress("DEPRECATION")
            window.decorView.systemUiVisibility = (
                View.SYSTEM_UI_FLAG_FULLSCREEN
                or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                or View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                or View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
            )
        }
        // Keep screen on
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        // Disable screenshot (optional, for security)
        window.setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE)
    }

    private fun restoreNormalMode() {
        // Restore normal system UI
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            // Android 11+ (API 30+)
            window.insetsController?.show(WindowInsetsCompat.Type.systemBars())
        } else {
            // Android 10 and below
            @Suppress("DEPRECATION")
            window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_VISIBLE
        }
        window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        // Block back button when locked
        if (isLocked && keyCode == KeyEvent.KEYCODE_BACK) {
            return true // Consume the event, don't allow back
        }
        return super.onKeyDown(keyCode, event)
    }
    
    /**
     * Check if usage stats permission is granted
     */
    private fun hasUsageStatsPermission(): Boolean {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val time = System.currentTimeMillis()
        val stats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            time - 1000 * 60,
            time
        )
        return stats != null && stats.isNotEmpty()
    }
    
    /**
     * Open usage access settings for the user to grant permission
     */
    private fun openUsageAccessSettings() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        startActivity(intent)
    }
    
    /**
     * Fetch usage statistics for installed apps
     */
    private fun getUsageStats(): List<Map<String, Any>> {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val packageManager = packageManager
        
        // Get usage stats for the last 24 hours
        val calendar = Calendar.getInstance()
        calendar.add(Calendar.DAY_OF_YEAR, -1)
        val startTime = calendar.timeInMillis
        val endTime = System.currentTimeMillis()
        
        val stats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            startTime,
            endTime
        )
        
        val usageList = ArrayList<Map<String, Any>>()
        
        stats?.let { statsList ->
            for (usageStats in statsList) {
                try {
                    // Skip system apps and apps with zero usage
                    if (usageStats.totalTimeInForeground <= 0) continue
                    
                    val packageName = usageStats.packageName
                    val appInfo = packageManager.getApplicationInfo(packageName, 0)
                    
                    // Skip system apps (optional)
                    if (appInfo.flags and ApplicationInfo.FLAG_SYSTEM != 0) continue
                    
                    val appName = packageManager.getApplicationLabel(appInfo).toString()
                    val totalTimeInMs = usageStats.totalTimeInForeground
                    val lastTimeUsed = usageStats.lastTimeUsed
                    
                    // Convert milliseconds to readable format
                    val hours = totalTimeInMs / (1000 * 60 * 60)
                    val minutes = (totalTimeInMs % (1000 * 60 * 60)) / (1000 * 60)
                    val seconds = (totalTimeInMs % (1000 * 60)) / 1000
                    
                    val usageMap = mapOf(
                        "packageName" to packageName,
                        "appName" to appName,
                        "totalTimeInForeground" to totalTimeInMs,
                        "lastTimeUsed" to lastTimeUsed,
                        "hours" to hours,
                        "minutes" to minutes,
                        "seconds" to seconds,
                        "formattedTime" to formatTime(hours, minutes, seconds)
                    )
                    
                    usageList.add(usageMap)
                } catch (e: PackageManager.NameNotFoundException) {
                    // App might be uninstalled, skip it
                    continue
                }
            }
        }
        
        // Sort by usage time (descending)
        return usageList.sortedByDescending { it["totalTimeInForeground"] as Long }
    }
    
    /**
     * Format time duration into readable string
     */
    private fun formatTime(hours: Long, minutes: Long, seconds: Long): String {
        return when {
            hours > 0 -> "${hours}h ${minutes}m"
            minutes > 0 -> "${minutes}m ${seconds}s"
            else -> "${seconds}s"
        }
    }
}
