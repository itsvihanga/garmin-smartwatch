"""Regression tests for the missing-cadence waiting state."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]


def has_current_cadence(value):
    return value is not None and value > 0


class CadenceWaitingStateTests(unittest.TestCase):
    def source(self, relative_path):
        return (ROOT / relative_path).read_text()

    def test_only_positive_cadence_is_a_valid_reading(self):
        self.assertFalse(has_current_cadence(None))
        self.assertFalse(has_current_cadence(0))
        self.assertTrue(has_current_cadence(1))
        self.assertTrue(has_current_cadence(172))

    def test_main_screen_displays_waiting_for_missing_cadence(self):
        view = self.source("source/Views/SimpleView.mc")

        self.assertIn("var hasCadence = app.hasCurrentCadence(info);", view)
        self.assertIn('hasCadence ? info.currentCadence.toString() : "--"', view)
        self.assertIn('_cadenceZoneDisplay.setText("waiting")', view)

    def test_zero_cadence_cannot_enter_alert_zone_logic(self):
        app = self.source("source/GarminApp.mc")
        alert_logic = app.split("function checkCadenceAlerts", 1)[1].split(
            "function fireCadenceAlertIfDue", 1
        )[0]

        self.assertIn("if (!hasCurrentCadence(info))", alert_logic)
        self.assertIn("info.currentCadence > 0", app)

    def test_advanced_screen_does_not_draw_missing_samples_as_slow(self):
        view = self.source("source/Views/AdvancedView.mc")

        self.assertIn('"-- spm"', view)
        self.assertIn("if (cadence == null) { continue; }", view)


if __name__ == "__main__":
    unittest.main(verbosity=2)
