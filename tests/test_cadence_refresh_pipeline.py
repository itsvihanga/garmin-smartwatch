"""Regression tests for the once-per-second cadence refresh pipeline."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]


class CadenceRefreshPipelineTests(unittest.TestCase):
    def source(self, relative_path):
        return (ROOT / relative_path).read_text()

    def app_function(self, name, next_name):
        app = self.source("source/GarminApp.mc")
        return app.split(f"function {name}", 1)[1].split(
            f"function {next_name}", 1
        )[0]

    def test_refresh_frequency_is_explicitly_one_second(self):
        app = self.source("source/GarminApp.mc")

        self.assertIn("const CADENCE_REFRESH_INTERVAL_MS = 1000;", app)
        self.assertIn(
            "method(:handleRefreshTick), CADENCE_REFRESH_INTERVAL_MS, true",
            app,
        )

    def test_tick_uses_one_ordered_cadence_pipeline(self):
        tick = self.app_function("handleRefreshTick", "handleOneShotTimer")

        self.assertEqual(1, tick.count("Activity.getActivityInfo()"))
        self.assertIn("if (_sessionState == RECORDING)", tick)
        stages = [
            "Activity.getActivityInfo()",
            "updateCadenceState(info)",
            "pollCadence(info)",
            "checkCadenceAlerts(info)",
            "_refreshCallback.invoke()",
        ]
        positions = [tick.index(stage) for stage in stages]
        self.assertEqual(sorted(positions), positions)

    def test_state_calculations_reuse_the_tick_snapshot(self):
        poll = self.app_function("pollCadence", "updateCadenceState")
        alerts = self.app_function("checkCadenceAlerts", "fireCadenceAlertIfDue")

        self.assertNotIn("Activity.getActivityInfo()", poll)
        self.assertNotIn("Activity.getActivityInfo()", alerts)
        self.assertIn("function pollCadence(info)", self.source("source/GarminApp.mc"))
        self.assertIn("function checkCadenceAlerts(info)", self.source("source/GarminApp.mc"))

    def test_views_render_cached_cadence(self):
        simple = self.source("source/Views/SimpleView.mc")
        advanced = self.source("source/Views/AdvancedView.mc")

        self.assertIn("var cadence = app.getCurrentCadence();", simple)
        self.assertIn("var cadence = app.getCurrentCadence();", advanced)

    def test_per_tick_diagnostics_are_throttled(self):
        app = self.source("source/GarminApp.mc")

        self.assertIn("const DIAGNOSTIC_LOG_INTERVAL_TICKS = 60;", app)
        self.assertIn(
            "_refreshTickCount % DIAGNOSTIC_LOG_INTERVAL_TICKS == 0",
            app,
        )


if __name__ == "__main__":
    unittest.main(verbosity=2)
