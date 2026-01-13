package ai.n42.www

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.WebSocket
import java.util.concurrent.TimeUnit

class WebSocketService : Service() {

    companion object {
        private const val CHANNEL_ID = "ws_foreground_channel"
        private const val NOTIFICATION_ID = 1001
    }

    private var ws: WebSocket? = null
    private var wsUrl: String? = null
    private var validatorPubkey: String? = null
    private var validatorPrivateKey: String? = null

    private val reconnectDelay = 5000L
    private val handler = Handler()

    private val client by lazy {
        OkHttpClient.Builder()
            .pingInterval(15, TimeUnit.SECONDS)
            .build()
    }

    private val reconnectRunnable = object : Runnable {
        override fun run() {
            if (ws == null) {
                val url = wsUrl
                val pubkey = validatorPubkey
                val privateKey = validatorPrivateKey

                if (url != null && pubkey != null && privateKey != null) {
                    Log.i("WebSocketService", "Reconnecting...")
                    startWebSocket(url, pubkey, privateKey)
                }
            }
        }
    }

    override fun onCreate() {
        super.onCreate()

        // ⭐ 核心：立刻进入前台
        startForeground(NOTIFICATION_ID, createNotification())
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        wsUrl = intent?.getStringExtra("wsUrl")
        validatorPubkey = intent?.getStringExtra("validatorPubkey")
        validatorPrivateKey = intent?.getStringExtra("validatorPrivateKey")

        if (wsUrl != null && validatorPubkey != null && validatorPrivateKey != null) {
            startWebSocket(wsUrl!!, validatorPubkey!!, validatorPrivateKey!!)
        }

        return START_STICKY
    }

    private fun startWebSocket(url: String, pubkey: String, privateKey: String) {
        Log.i("WebSocketService", "Connecting to $url")
        val request = Request.Builder().url(url).build()
        ws = client.newWebSocket(
            request,
            MyWebSocketListener(pubkey, privateKey) {
                ws = null
                handler.postDelayed(reconnectRunnable, reconnectDelay)
            }
        )
    }

    private fun stopWebSocket() {
        ws?.close(1000, "Manual disconnect")
        ws = null
        handler.removeCallbacks(reconnectRunnable)
    }

    override fun onDestroy() {
        super.onDestroy()
        stopWebSocket()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    // ================= Notification =================

    private fun createNotification(): Notification {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "N42 WebSocket Node",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("N42 Node Running")
            .setContentText("Listening for verification requests")
            .setSmallIcon(android.R.drawable.stat_sys_upload)
            .setOngoing(true)
            .build()
    }
}
