package ai.n42.www

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.graphics.ImageFormat
import android.graphics.Rect
import android.graphics.YuvImage
import android.util.Log
import com.cloudwebrtc.webrtc.video.LocalVideoTrack
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.segmentation.Segmentation
import com.google.mlkit.vision.segmentation.SegmentationMask
import com.google.mlkit.vision.segmentation.selfie.SelfieSegmenterOptions
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.util.concurrent.atomic.AtomicBoolean
import kotlin.math.max
import kotlin.math.roundToInt
import org.webrtc.JavaI420Buffer
import org.webrtc.VideoFrame

class N42VirtualBackgroundProcessor : LocalVideoTrack.ExternalVideoFrameProcessing {
    companion object {
        private const val TAG = "N42VirtualBg"
        private const val MODE_NONE = "none"
        private const val MODE_BLUR = "blur"
        private const val MODE_VIRTUAL = "virtualBackground"
        private const val MODE_SOLID = "solidColor"
        private const val FOREGROUND_THRESHOLD = 0.5f
        private const val SEGMENTATION_INTERVAL_MS = 100L
    }

    @Volatile private var mode: String = MODE_NONE
    @Volatile private var blurRadius: Float = 0.5f
    @Volatile private var solidColor: Int = Color.rgb(0x07, 0xC1, 0x60)
    @Volatile private var backgroundBitmap: Bitmap? = null
    @Volatile private var latestMask: MaskData? = null

    private val processingMask = AtomicBoolean(false)
    @Volatile private var lastSegmentationAtMs = 0L

    private val segmenter = Segmentation.getClient(
        SelfieSegmenterOptions.Builder()
            .setDetectorMode(SelfieSegmenterOptions.STREAM_MODE)
            .enableRawSizeMask()
            .build()
    )

    fun updateConfig(
        mode: String,
        blurRadius: Float,
        solidColor: String?,
        backgroundImageBytes: ByteArray?,
    ) {
        this.mode = mode
        this.blurRadius = blurRadius.coerceIn(0f, 1f)
        this.solidColor = parseColor(solidColor) ?: Color.rgb(0x07, 0xC1, 0x60)
        this.backgroundBitmap = backgroundImageBytes
            ?.takeIf { it.isNotEmpty() }
            ?.let { bytes -> BitmapFactory.decodeByteArray(bytes, 0, bytes.size) }
        if (mode == MODE_NONE) {
            latestMask = null
        }
    }

    fun clear() {
        mode = MODE_NONE
        latestMask = null
        backgroundBitmap = null
    }

    override fun onFrame(frame: VideoFrame): VideoFrame {
        val currentMode = mode
        if (currentMode == MODE_NONE) return frame

        val bitmap = frameToBitmap(frame) ?: return frame
        requestMask(bitmap)

        val mask = latestMask ?: return frame
        val composed = compose(bitmap, mask, currentMode)
        val buffer = bitmapToI420(composed) ?: return frame
        return VideoFrame(buffer, frame.rotation, frame.timestampNs)
    }

    private fun requestMask(bitmap: Bitmap) {
        val now = System.currentTimeMillis()
        if (now - lastSegmentationAtMs < SEGMENTATION_INTERVAL_MS) return
        if (!processingMask.compareAndSet(false, true)) return

        lastSegmentationAtMs = now
        val image = InputImage.fromBitmap(bitmap, 0)
        segmenter.process(image)
            .addOnSuccessListener { mask ->
                latestMask = mask.toMaskData()
            }
            .addOnFailureListener { error ->
                Log.w(TAG, "Selfie segmentation failed: ${error.message}")
            }
            .addOnCompleteListener {
                processingMask.set(false)
            }
    }

    private fun compose(originalBitmap: Bitmap, mask: MaskData, currentMode: String): Bitmap {
        val original = originalBitmap.copy(Bitmap.Config.ARGB_8888, true)
        val width = original.width
        val height = original.height
        val background = when (currentMode) {
            MODE_SOLID -> solidBackground(width, height)
            MODE_VIRTUAL -> coverBackground(width, height) ?: blurBackground(original)
            MODE_BLUR -> blurBackground(original)
            else -> return original
        }

        val originalPixels = IntArray(width * height)
        val backgroundPixels = IntArray(width * height)
        original.getPixels(originalPixels, 0, width, 0, 0, width, height)
        background.getPixels(backgroundPixels, 0, width, 0, 0, width, height)

        val scaleX = mask.width.toFloat() / width.toFloat()
        val scaleY = mask.height.toFloat() / height.toFloat()
        for (y in 0 until height) {
            val maskY = (y * scaleY).toInt().coerceIn(0, mask.height - 1)
            val maskRow = maskY * mask.width
            val row = y * width
            for (x in 0 until width) {
                val maskX = (x * scaleX).toInt().coerceIn(0, mask.width - 1)
                if (mask.confidences[maskRow + maskX] < FOREGROUND_THRESHOLD) {
                    originalPixels[row + x] = backgroundPixels[row + x]
                }
            }
        }
        original.setPixels(originalPixels, 0, width, 0, 0, width, height)
        return original
    }

    private fun solidBackground(width: Int, height: Int): Bitmap {
        return Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888).apply {
            eraseColor(solidColor)
        }
    }

    private fun coverBackground(width: Int, height: Int): Bitmap? {
        val source = backgroundBitmap ?: return null
        val scale = max(
            width.toFloat() / source.width.toFloat(),
            height.toFloat() / source.height.toFloat(),
        )
        val scaledWidth = (source.width * scale).roundToInt().coerceAtLeast(width)
        val scaledHeight = (source.height * scale).roundToInt().coerceAtLeast(height)
        val scaled = Bitmap.createScaledBitmap(source, scaledWidth, scaledHeight, true)
        val left = ((scaledWidth - width) / 2).coerceAtLeast(0)
        val top = ((scaledHeight - height) / 2).coerceAtLeast(0)
        return Bitmap.createBitmap(scaled, left, top, width, height)
    }

    private fun blurBackground(source: Bitmap): Bitmap {
        val width = source.width
        val height = source.height
        val downscale = (4 + blurRadius * 20).roundToInt().coerceIn(4, 24)
        val smallWidth = (width / downscale).coerceAtLeast(1)
        val smallHeight = (height / downscale).coerceAtLeast(1)
        val small = Bitmap.createScaledBitmap(source, smallWidth, smallHeight, true)
        return Bitmap.createScaledBitmap(small, width, height, true)
    }

    private fun frameToBitmap(frame: VideoFrame): Bitmap? {
        val i420 = frame.buffer.toI420() ?: return null
        return try {
            val width = i420.width
            val height = i420.height
            val nv21 = i420ToNv21(i420)
            val yuvImage = YuvImage(nv21, ImageFormat.NV21, width, height, null)
            val out = ByteArrayOutputStream()
            if (!yuvImage.compressToJpeg(Rect(0, 0, width, height), 88, out)) {
                null
            } else {
                val bytes = out.toByteArray()
                BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
            }
        } catch (e: Exception) {
            Log.w(TAG, "frameToBitmap failed: ${e.message}")
            null
        } finally {
            i420.release()
        }
    }

    private fun i420ToNv21(i420: VideoFrame.I420Buffer): ByteArray {
        val width = i420.width
        val height = i420.height
        val chromaWidth = (width + 1) / 2
        val chromaHeight = (height + 1) / 2
        val output = ByteArray(width * height + chromaWidth * chromaHeight * 2)

        copyPlane(i420.dataY, i420.strideY, output, 0, width, height)

        val u = i420.dataU.duplicate()
        val v = i420.dataV.duplicate()
        var offset = width * height
        for (row in 0 until chromaHeight) {
            val uRow = row * i420.strideU
            val vRow = row * i420.strideV
            for (col in 0 until chromaWidth) {
                output[offset++] = v.get(vRow + col)
                output[offset++] = u.get(uRow + col)
            }
        }
        return output
    }

    private fun copyPlane(
        source: ByteBuffer,
        sourceStride: Int,
        target: ByteArray,
        targetOffset: Int,
        width: Int,
        height: Int,
    ) {
        val data = source.duplicate()
        var offset = targetOffset
        for (row in 0 until height) {
            val sourceRow = row * sourceStride
            for (col in 0 until width) {
                target[offset++] = data.get(sourceRow + col)
            }
        }
    }

    private fun bitmapToI420(bitmap: Bitmap): VideoFrame.Buffer? {
        return try {
            val width = bitmap.width
            val height = bitmap.height
            val chromaWidth = (width + 1) / 2
            val chromaHeight = (height + 1) / 2
            val y = ByteBuffer.allocateDirect(width * height)
            val u = ByteBuffer.allocateDirect(chromaWidth * chromaHeight)
            val v = ByteBuffer.allocateDirect(chromaWidth * chromaHeight)
            val pixels = IntArray(width * height)
            bitmap.getPixels(pixels, 0, width, 0, 0, width, height)

            for (row in 0 until height) {
                for (col in 0 until width) {
                    val pixel = pixels[row * width + col]
                    val red = Color.red(pixel)
                    val green = Color.green(pixel)
                    val blue = Color.blue(pixel)
                    val yValue = ((66 * red + 129 * green + 25 * blue + 128) shr 8) + 16
                    val uValue = ((-38 * red - 74 * green + 112 * blue + 128) shr 8) + 128
                    val vValue = ((112 * red - 94 * green - 18 * blue + 128) shr 8) + 128
                    y.put(row * width + col, yValue.coerceIn(0, 255).toByte())
                    if (row % 2 == 0 && col % 2 == 0) {
                        val chromaIndex = (row / 2) * chromaWidth + (col / 2)
                        u.put(chromaIndex, uValue.coerceIn(0, 255).toByte())
                        v.put(chromaIndex, vValue.coerceIn(0, 255).toByte())
                    }
                }
            }
            JavaI420Buffer.wrap(width, height, y, width, u, chromaWidth, v, chromaWidth) {}
        } catch (e: Exception) {
            Log.w(TAG, "bitmapToI420 failed: ${e.message}")
            null
        }
    }

    private fun SegmentationMask.toMaskData(): MaskData {
        val buffer = this.buffer.duplicate().order(ByteOrder.nativeOrder()).asFloatBuffer()
        val values = FloatArray(width * height)
        buffer.get(values, 0, values.size.coerceAtMost(buffer.remaining()))
        return MaskData(width, height, values)
    }

    private fun parseColor(value: String?): Int? {
        val text = value?.trim().orEmpty()
        if (text.isEmpty()) return null
        return try {
            Color.parseColor(if (text.startsWith("#")) text else "#$text")
        } catch (_: IllegalArgumentException) {
            null
        }
    }

    private data class MaskData(
        val width: Int,
        val height: Int,
        val confidences: FloatArray,
    )
}
