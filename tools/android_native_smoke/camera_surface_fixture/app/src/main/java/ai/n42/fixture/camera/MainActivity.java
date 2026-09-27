package ai.n42.fixture.camera;

import android.app.Activity;
import android.graphics.SurfaceTexture;
import android.os.Bundle;
import android.os.Process;
import android.util.Log;
import android.view.Surface;

import androidx.camera.core.impl.utils.SurfaceUtil;

import dalvik.system.BaseDexClassLoader;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.UUID;

public final class MainActivity extends Activity {
    private static final String TAG = "N42_CAMERA_FIXTURE";

    @Override
    protected void onCreate(Bundle state) {
        super.onCreate(state);
        JSONObject record = new JSONObject();
        SurfaceTexture texture = null;
        Surface surface = null;
        try {
            String phase = getIntent().getStringExtra("phase");
            if (!"baseline".equals(phase) && !"candidate".equals(phase)) {
                throw new IllegalArgumentException("Expected baseline or candidate phase");
            }
            texture = new SurfaceTexture(0);
            texture.setDefaultBufferSize(321, 247);
            surface = new Surface(texture);
            SurfaceUtil.SurfaceInfo info = SurfaceUtil.getSurfaceInfo(surface);
            if (info.width != 321 || info.height != 247 || info.format <= 0) {
                throw new IllegalStateException("Unexpected SurfaceInfo");
            }
            String apk = getApplicationInfo().sourceDir;
            String library = ((BaseDexClassLoader) getClassLoader())
                .findLibrary("surface_util_jni");
            JSONArray maps = new JSONArray();
            try (BufferedReader reader = new BufferedReader(new FileReader("/proc/self/maps"))) {
                for (String line; (line = reader.readLine()) != null;) {
                    if (line.contains(apk) && line.contains("r-xp")) {
                        maps.put(line);
                    }
                }
            }
            record.put("status", "PASS");
            record.put("phase", phase);
            record.put("format", info.format);
            record.put("width", info.width);
            record.put("height", info.height);
            record.put("pid", Process.myPid());
            record.put("nonce", UUID.randomUUID().toString());
            record.put("apkPath", apk);
            record.put("apkSha256", sha256(new File(apk)));
            record.put("libraryLookupPath", library);
            record.put("executableApkMaps", maps);
        } catch (Throwable error) {
            try {
                record.put("status", "FAIL");
                record.put("error", error.toString());
                record.put("pid", Process.myPid());
            } catch (Exception ignored) {
                Log.e(TAG, "Failed to record fixture exception", ignored);
            }
        } finally {
            if (surface != null) surface.release();
            if (texture != null) texture.release();
            try {
                byte[] data = record.toString().getBytes(StandardCharsets.UTF_8);
                try (FileOutputStream output = new FileOutputStream(new File(getFilesDir(), "result.json"))) {
                    output.write(data);
                }
            } catch (Exception error) {
                Log.e(TAG, "Failed to write fixture result", error);
            }
            Log.i(TAG, record.toString());
            finish();
        }
    }

    private static String sha256(File file) throws Exception {
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        byte[] buffer = new byte[64 * 1024];
        try (FileInputStream input = new FileInputStream(file)) {
            for (int size; (size = input.read(buffer)) != -1;) {
                digest.update(buffer, 0, size);
            }
        }
        StringBuilder text = new StringBuilder();
        for (byte value : digest.digest()) {
            text.append(String.format("%02x", value & 0xff));
        }
        return text.toString();
    }
}
