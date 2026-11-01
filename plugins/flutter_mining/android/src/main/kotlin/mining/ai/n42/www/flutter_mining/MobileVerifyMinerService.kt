package mining.ai.n42.www.flutter_mining

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager
import android.util.Log
import evmsdk.Evmsdk
import evmsdk.MobileVerifyMiner
import org.json.JSONObject
import java.util.concurrent.Executors

/**
 * Mining v3 host: a foreground service that owns evmsdk.MobileVerifyMiner,
 * the whole mobile verification loop running in Go. The loop needs neither
 * the activity nor the Flutter engine, so it keeps verifying blocks while
 * the app is in the background or its UI is gone; the app only starts it,
 * stops it and reads its status.
 *
 * The service type is specialUse: a dataSync service is stopped after 6 h
 * a day on Android 15+, and verification runs for as long as the user
 * leaves it on. A partial wake lock keeps the CPU up for re-execution
 * while the screen is off.
 */
class MobileVerifyMinerService : Service() {
    private val main = Handler(Looper.getMainLooper())

    // Miner start and stop block (Stop waits for the loop to unwind), so
    // they run in order off the main thread.
    private val worker = Executors.newSingleThreadExecutor()
    private var wakeLock: PowerManager.WakeLock? = null
    private var lastText: String? = null

    private val refresh = object : Runnable {
        override fun run() {
            updateNotification()
            main.postDelayed(this, NOTIFICATION_REFRESH_MS)
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP) {
            shutdown()
            return START_NOT_STICKY
        }
        val baseUrl = intent?.getStringExtra(EXTRA_BASE_URL)
        val privHex = intent?.getStringExtra(EXTRA_PRIV_HEX)
        val chain = intent?.getStringExtra(EXTRA_CHAIN)
        if (baseUrl.isNullOrEmpty() || privHex.isNullOrEmpty() || chain.isNullOrEmpty()) {
            stopSelf()
            return START_NOT_STICKY
        }
        try {
            enterForeground()
        } catch (e: Exception) {
            // Android 12+ refuses a foreground start from the background,
            // e.g. a restart after the process was killed.
            Log.w(TAG, "cannot enter the foreground", e)
            stopSelf()
            return START_NOT_STICKY
        }
        acquireWakeLock()
        main.removeCallbacks(refresh)
        main.post(refresh)
        worker.execute { startMiner(baseUrl, privHex, chain) }
        // Redelivered after the process is killed, so mining resumes.
        return START_REDELIVER_INTENT
    }

    private fun startMiner(baseUrl: String, privHex: String, chain: String) {
        val pubkey = runCatching { Evmsdk.mobileBLSPublicKey(privHex) }.getOrNull()
        val running = miner
        if (running != null && running.running() && running.pubkeyHex() == pubkey &&
            endpoint == baseUrl.trimEnd('/') && minerChain == chain
        ) {
            return
        }
        running?.stop()
        try {
            val created = Evmsdk.newMobileVerifyMiner(baseUrl, privHex, chain)
            endpoint = baseUrl.trimEnd('/')
            minerChain = chain
            miner = created
            created.start()
        } catch (e: Exception) {
            Log.e(TAG, "cannot start the miner", e)
            miner = null
            startError = e.message ?: e.toString()
            main.post { shutdown() }
        }
    }

    private fun shutdown() {
        main.removeCallbacks(refresh)
        worker.execute {
            miner?.stop()
            main.post {
                releaseWakeLock()
                stopForegroundCompat()
                stopSelf()
            }
        }
    }

    override fun onDestroy() {
        main.removeCallbacks(refresh)
        val stopping = miner
        worker.execute { stopping?.stop() }
        worker.shutdown()
        releaseWakeLock()
        super.onDestroy()
    }

    private fun enterForeground() {
        val notification = buildNotification(statusText())
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE,
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    private fun stopForegroundCompat() = stopForeground(STOP_FOREGROUND_REMOVE)

    private fun acquireWakeLock() {
        if (wakeLock?.isHeld == true) return
        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "n42:mobileverify").apply {
            setReferenceCounted(false)
            acquire()
        }
    }

    private fun releaseWakeLock() {
        wakeLock?.let { if (it.isHeld) it.release() }
        wakeLock = null
    }

    private fun updateNotification() {
        val text = statusText()
        if (text == lastText) return
        lastText = text
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        nm.notify(NOTIFICATION_ID, buildNotification(text))
    }

    private fun statusText(): String {
        val st = runCatching { JSONObject(status()) }.getOrNull() ?: return "Starting"
        return when (st.optString("phase")) {
            "mining" -> "Verified ${st.optInt("verified")} · certified ${st.optInt("certified")}"
            "registering" -> "Waiting for registration"
            "retrying" -> "Reconnecting · verified ${st.optInt("verified")}"
            else -> "Starting"
        }
    }

    @Suppress("DEPRECATION")
    private fun buildNotification(text: String): Notification {
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.createNotificationChannel(
                NotificationChannel(CHANNEL_ID, "N42 verification", NotificationManager.IMPORTANCE_LOW),
            )
            Notification.Builder(this, CHANNEL_ID)
        } else {
            Notification.Builder(this).setPriority(Notification.PRIORITY_LOW)
        }
        packageManager.getLaunchIntentForPackage(packageName)?.let { launch ->
            builder.setContentIntent(
                PendingIntent.getActivity(this, 0, launch, PendingIntent.FLAG_IMMUTABLE),
            )
        }
        return builder
            .setContentTitle("N42 block verification")
            .setContentText(text)
            .setSmallIcon(applicationInfo.icon)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .build()
    }

    companion object {
        private const val TAG = "MobileVerifyMiner"
        private const val CHANNEL_ID = "n42_mobileverify"
        private const val NOTIFICATION_ID = 4242
        private const val NOTIFICATION_REFRESH_MS = 5_000L
        const val ACTION_START = "mining.ai.n42.www.flutter_mining.MOBILEVERIFY_START"
        const val ACTION_STOP = "mining.ai.n42.www.flutter_mining.MOBILEVERIFY_STOP"
        const val EXTRA_BASE_URL = "baseUrl"
        const val EXTRA_PRIV_HEX = "privHex"
        const val EXTRA_CHAIN = "chain"

        // One miner per process, shared with the channel handler that
        // reads its status.
        @Volatile
        private var miner: MobileVerifyMiner? = null

        @Volatile
        private var endpoint: String? = null

        @Volatile
        private var minerChain: String? = null

        @Volatile
        private var startError: String? = null

        /** The miner's status JSON, or an idle one when none runs. */
        fun status(): String {
            miner?.let { return it.status() }
            return JSONObject()
                .put("running", false)
                .put("phase", "idle")
                .put("log", org.json.JSONArray())
                .apply { startError?.let { put("lastError", it) } }
                .toString()
        }

        fun start(context: Context, baseUrl: String, privHex: String, chain: String) {
            startError = null
            val intent = Intent(context, MobileVerifyMinerService::class.java)
                .setAction(ACTION_START)
                .putExtra(EXTRA_BASE_URL, baseUrl)
                .putExtra(EXTRA_PRIV_HEX, privHex)
                .putExtra(EXTRA_CHAIN, chain)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        fun stop(context: Context) {
            if (miner == null) {
                context.stopService(Intent(context, MobileVerifyMinerService::class.java))
                return
            }
            context.startService(
                Intent(context, MobileVerifyMinerService::class.java).setAction(ACTION_STOP),
            )
        }
    }
}
