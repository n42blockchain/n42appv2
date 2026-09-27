"""Check the real Cargokit launcher command without running Dart or Cargo."""

import os
from pathlib import Path
import subprocess
import tempfile
import unittest


LAUNCHER = Path(__file__).resolve().parents[2] / "run_build_tool.sh"


class RunBuildToolOfflineTest(unittest.TestCase):
    def test_controlled_build_uses_offline_pub_resolution(self):
        with tempfile.TemporaryDirectory(prefix="vodo-cargokit-") as temporary:
            root = Path(temporary)
            dart = root / "flutter/bin/cache/dart-sdk/bin/dart"
            dart.parent.mkdir(parents=True)
            dart.write_text(
                "#!/bin/sh\n"
                "printf '%s\\n' \"$*\" >> \"$VODO_DART_LOG\"\n"
                "if [ \"$1 $2\" = 'compile kernel' ]; then\n"
                "  touch bin/build_tool_runner.dill\n"
                "fi\n"
            )
            dart.chmod(0o755)
            log = root / "dart-args.log"
            env = dict(os.environ)
            env.update(
                FLUTTER_ROOT=str(root / "flutter"),
                CARGOKIT_TOOL_TEMP_DIR=str(root / "runner"),
                CARGOKIT_PUB_OFFLINE="1",
                VODO_DART_LOG=str(log),
            )
            result = subprocess.run(
                ["bash", str(LAUNCHER), "build-gradle"],
                env=env,
                capture_output=True,
                text=True,
                check=False,
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn("pub get --no-precompile --offline", log.read_text())


if __name__ == "__main__":
    unittest.main()
