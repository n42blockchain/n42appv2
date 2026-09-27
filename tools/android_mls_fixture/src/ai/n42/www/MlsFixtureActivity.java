package ai.n42.www;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;

/** Hosts the same synthetic JNI checks in an installed, signed fixture APK. */
public final class MlsFixtureActivity extends Activity {
    @Override public void onCreate(Bundle state) {
        super.onCreate(state);
        new Thread(() -> {
            try {
                MlsFixture.main(new String[0]);
                Log.i("N42_MLS_FIXTURE", "MLS_APK_FIXTURE_PASS");
            } catch (Throwable error) {
                Log.e("N42_MLS_FIXTURE", "MLS_APK_FIXTURE_FAIL", error);
            }
        }, "synthetic-mls-fixture").start();
    }
}
