package ai.n42.www
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.Log
import androidx.core.app.NotificationCompat
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.WebSocket
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicBoolean

class WebSocketService : Service() {

    companion object {
        private const val CHANNEL_ID = "ws_foreground_channel"
        private const val NOTIFICATION_ID = 1001
    }
    private var ws: WebSocket? = null

    private var wsUrl: String? = null
    private var validatorPubkey: String? = null
    private var validatorPrivateKey: String? = null

    /** Service 级主动关闭 */
    @Volatile
    private var manualClose = false

    /** 给 WebSocketListener 用的线程安全标记 */
    private val manuallyClosed = AtomicBoolean(false)

    @Volatile
    private var connectionId = 0

    private val reconnectDelay = 5000L
    private val handler = Handler(Looper.getMainLooper())

    private val client by lazy {
        OkHttpClient.Builder()
            .pingInterval(15, TimeUnit.SECONDS)
            .build()
    }

    private val reconnectRunnable = Runnable {
        if (manualClose) {
            Log.i("WebSocketService", "Manual close, skip reconnect")
            return@Runnable
        }

        if (ws == null && wsUrl != null) {
            Log.i("WebSocketService", "Reconnecting...")
            startWebSocket(wsUrl!!, validatorPubkey!!, validatorPrivateKey!!)
        }
    }

    override fun onCreate() {
        super.onCreate()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                NOTIFICATION_ID,
                createNotification(),
                ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC
            )
        } else {
            startForeground(NOTIFICATION_ID, createNotification())
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val newUrl = intent?.getStringExtra("wsUrl")
        val newPubkey = intent?.getStringExtra("validatorPubkey")
        val newPrivKey = intent?.getStringExtra("validatorPrivateKey")

        if (newUrl == null || newPubkey == null || newPrivKey == null) {
            return START_NOT_STICKY
        }

        // pubkey 为空时仅用于显示前台通知（MiningRunClient 场景），不启动 WebSocket
        if (newPubkey.isEmpty()) {
            return START_NOT_STICKY
        }

        val walletChanged =
            newUrl != wsUrl ||
                    newPubkey != validatorPubkey ||
                    newPrivKey != validatorPrivateKey

        if (walletChanged) {
            stopWebSocket(manual = true)
        }

        wsUrl = newUrl
        validatorPubkey = newPubkey
        validatorPrivateKey = newPrivKey

        startWebSocket(newUrl, newPubkey, newPrivKey)

        return START_NOT_STICKY
    }

    @Synchronized
    private fun startWebSocket(url: String, pubkey: String, privateKey: String) {
        if (ws != null) return

        manualClose = false
        manuallyClosed.set(false)

        val currentId = ++connectionId
        val request = Request.Builder().url(url).build()

        ws = client.newWebSocket(
            request,
            MyWebSocketListener(
                pubkey,
                privateKey,
                manuallyClosed
            ) {
                if (currentId != connectionId) return@MyWebSocketListener

                ws = null
                if (!manualClose) {
                    handler.postDelayed(reconnectRunnable, reconnectDelay)
                }
            }
        )
    }

    private fun stopWebSocket(manual: Boolean) {
        manualClose = manual
        manuallyClosed.set(manual)

        handler.removeCallbacks(reconnectRunnable)

        ws?.close(1000, "Service stop")
        ws = null
    }

    override fun onDestroy() {
        stopWebSocket(manual = true)
        super.onDestroy()
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

        val pubkey = validatorPubkey
        val contentText = if (pubkey.isNullOrEmpty())
            "Mining node is running"
        else
            "Listening for verification requests"

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("N42 Node Running")
            .setContentText(contentText)
            .setSmallIcon(android.R.drawable.stat_sys_upload)
            .setOngoing(true)
            .build()
    }
}
