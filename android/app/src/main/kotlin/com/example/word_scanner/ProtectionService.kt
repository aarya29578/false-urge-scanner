package com.example.word_scanner

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat

class ProtectionService : Service() {
    companion object {
        private const val CHANNEL_ID = "word_scanner_protection_channel"
        private const val NOTIFICATION_ID = 1101
        private const val ACTION_START = "com.example.word_scanner.START_PROTECTION"
        private const val ACTION_STOP = "com.example.word_scanner.STOP_PROTECTION"
        private const val ACTION_TEST_ALERT = "com.example.word_scanner.TEST_ALERT"

        fun start(context: Context) {
            val intent = Intent(context, ProtectionService::class.java).apply {
                action = ACTION_START
            }
            ContextCompat.startForegroundService(context, intent)
        }

        fun stop(context: Context) {
            val intent = Intent(context, ProtectionService::class.java).apply {
                action = ACTION_STOP
            }
            ContextCompat.startForegroundService(context, intent)
        }

        fun triggerTestAlert(context: Context, metadata: Map<String, Any?> = emptyMap()) {
            val intent = Intent(context, ProtectionService::class.java).apply {
                action = ACTION_TEST_ALERT
                metadata.forEach { (key, value) ->
                    when (value) {
                        is String -> putExtra(key, value)
                        is Int -> putExtra(key, value)
                        is Boolean -> putExtra(key, value)
                        is ArrayList<*> -> putStringArrayListExtra(key, ArrayList(value.filterIsInstance<String>()))
                    }
                }
            }
            ContextCompat.startForegroundService(context, intent)
        }
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> {
                startForegroundService()
                return START_STICKY
            }
            ACTION_STOP -> {
                OverlayManager(this).dismissAll()
                stopForeground(STOP_FOREGROUND_REMOVE)
                stopSelf()
                return START_NOT_STICKY
            }
            ACTION_TEST_ALERT -> {
                startForegroundService()
                val data = mapOf(
                    "title" to intent.getStringExtra("title") ?: "Protection Alert",
                    "summary" to intent.getStringExtra("summary") ?: "Potentially suspicious\ncontent detected",
                    "confidence" to intent.getIntExtra("confidence", 78),
                    "indicators" to intent.getStringArrayListExtra("indicators") ?: arrayListOf(
                        "Example indicator detected",
                        "Example warning signal",
                        "Verification required"
                    )
                )
                OverlayManager(this).showWarningCard(data)
                return START_NOT_STICKY
            }
            else -> {
                startForegroundService()
                return START_STICKY
            }
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Word Scanner Protection",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "This service keeps Protection Mode active in the background."
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun startForegroundService() {
        val notification: Notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Word Scanner")
            .setContentText("Protection Mode is active")
            .setSmallIcon(android.R.drawable.stat_sys_warning)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setOnlyAlertOnce(true)
            .build()

        startForeground(NOTIFICATION_ID, notification)
    }
}
