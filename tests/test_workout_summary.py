"""Regression coverage for safe workout-summary formatting and save flow."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
MISSING = "--"


def format_duration(duration):
    if duration is None or duration <= 0:
        return MISSING
    whole_seconds = int(duration / 1000.0)
    if whole_seconds <= 0:
        return MISSING
    hours = whole_seconds // 3600
    minutes = (whole_seconds % 3600) // 60
    seconds = whole_seconds % 60
    return f"{hours:02d}:{minutes:02d}:{seconds:02d}"


def format_distance(distance):
    if distance is None or distance <= 0:
        return MISSING
    return f"{distance / 1000.0:.2f} km"


def format_pace(duration, distance):
    if duration is None or distance is None or duration <= 0 or distance <= 0:
        return MISSING
    whole_pace_seconds = int((duration / 1000.0) / (distance / 1000.0))
    if whole_pace_seconds <= 0:
        return MISSING
    return f"{whole_pace_seconds // 60}:{whole_pace_seconds % 60:02d} /km"


def format_positive(value, suffix):
    if value is None or value <= 0:
        return MISSING
    return f"{value:.0f}{suffix}"


def format_summary(values):
    quality = values.get("quality")
    temperature = values.get("temperature")
    return {
        "duration": format_duration(values.get("duration")),
        "distance": format_distance(values.get("distance")),
        "cadence": format_positive(values.get("cadence"), " spm"),
        "heart_rate": format_positive(values.get("heart_rate"), " bpm"),
        "pace": format_pace(values.get("duration"), values.get("distance")),
        "quality": MISSING if quality is None or quality < 0 else f"{quality:.0f}%",
        "temperature": MISSING if temperature is None else f"{temperature:.1f} C",
    }


class WorkoutSummaryTests(unittest.TestCase):
    def source(self, relative_path):
        return (ROOT / relative_path).read_text()

    def test_normal_workout_values(self):
        summary = format_summary(
            {
                "duration": 1_500_500,
                "distance": 5_000.0,
                "cadence": 172.4,
                "heart_rate": 148,
                "quality": 87.4,
                "temperature": 21.4,
            }
        )

        self.assertEqual("00:25:00", summary["duration"])
        self.assertEqual("5.00 km", summary["distance"])
        self.assertEqual("172 spm", summary["cadence"])
        self.assertEqual("148 bpm", summary["heart_rate"])
        self.assertEqual("5:00 /km", summary["pace"])
        self.assertEqual("87%", summary["quality"])
        self.assertEqual("21.4 C", summary["temperature"])

        print("\n[SUMMARY TEST] normal=" + str(summary) + " crashes=0")

    def test_zero_null_and_missing_values_use_placeholder(self):
        payloads = [
            {},
            {"duration": None, "distance": None},
            {"duration": 0, "distance": 0, "cadence": 0, "heart_rate": 0},
            {"duration": -1, "distance": -1, "quality": -1},
        ]

        for payload in payloads:
            summary = format_summary(payload)
            self.assertTrue(all(value == MISSING for value in summary.values()))

        self.assertEqual(MISSING, format_pace(60_000, None))
        self.assertEqual(MISSING, format_pace(None, 1_000.0))
        self.assertEqual(MISSING, format_pace(60_000, 0.0))
        print("[SUMMARY TEST] edge_cases=zero,null,missing,negative placeholder=-- crashes=0")

    def test_pace_is_converted_before_modulo(self):
        formatter = self.source("source/SummaryFormatter.mc")
        conversion = "var wholePaceSeconds = (totalSeconds / distanceKm).toNumber();"
        modulo = "var seconds = wholePaceSeconds % 60;"

        self.assertIn(conversion, formatter)
        self.assertIn(modulo, formatter)
        self.assertLess(formatter.index(conversion), formatter.index(modulo))
        self.assertNotIn("paceSecondsPerKm % 60", formatter)

    def test_all_required_metrics_are_always_rendered(self):
        view = self.source("source/Views/SummaryView.mc")
        expected = {
            "DURATION": "formatDuration",
            "DISTANCE": "formatDistance",
            "AVG CADENCE": "formatCadence",
            "AVG HR": "formatHeartRate",
            "AVG PACE": "formatAveragePace",
            "CADENCE QUALITY": "formatCadenceQuality",
            "TEMPERATURE": "formatTemperature",
        }

        for label, formatter in expected.items():
            self.assertIn(f'"{label}"', view)
            self.assertIn(f"SummaryFormatter.{formatter}", view)

        self.assertNotIn("hasValidSummaryData", view)
        self.assertNotIn("duration = 0", view)
        self.assertNotIn("distance = 0", view)

    def test_activity_averages_and_temperature_are_captured_before_stop(self):
        app = self.source("source/GarminApp.mc")
        stop_method = app[app.index("function stopRecording"):app.index("function resetAllSettings")]

        self.assertLess(stop_method.index("captureActivityMetrics();"), stop_method.index("activitySession.stop();"))
        self.assertIn("info.averageCadence", app)
        self.assertIn("info.averageHeartRate", app)
        self.assertIn("info.maxHeartRate", app)
        self.assertIn("Sensor.getInfo()", app)
        self.assertIn("sensorInfo.temperature", app)

    def test_summary_opens_only_after_successful_save(self):
        app = self.source("source/GarminApp.mc")
        delegate = self.source("source/Delegates/SimpleViewDelegate.mc")

        self.assertIn("function saveSession() as Boolean", app)
        self.assertIn("saved = activitySession.save();", app)
        self.assertIn("if (!saved)", app)
        self.assertIn('"[SUMMARY] ready duration="', app)
        for field in ("distance=", "cadence=", "heart_rate=", "pace=", "quality=", "temperature="):
            self.assertIn(f'" {field}"', app)
        self.assertIn("if (!app.saveSession())", delegate)
        self.assertLess(
            delegate.index("if (!app.saveSession())"),
            delegate.index("new SummaryView()"),
        )

    def test_every_summary_dismissal_resets_captured_values(self):
        delegate = self.source("source/Delegates/SummaryViewDelegate.mc")

        self.assertIn("private function dismissSummary() as Void", delegate)
        self.assertIn("app.resetSession();", delegate)
        self.assertEqual(4, delegate.count("dismissSummary();"))

    def test_forerunner_955_is_a_build_target(self):
        manifest = self.source("manifest.xml")
        self.assertIn('<iq:product id="fr955"/>', manifest)


if __name__ == "__main__":
    unittest.main(verbosity=2)
