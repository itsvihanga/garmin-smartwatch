import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def read(relative_path):
    return (ROOT / relative_path).read_text(encoding="utf-8")


class FeedbackModeTests(unittest.TestCase):
    def test_schedule_uses_active_recording_ticks_and_resets_per_activity(self):
        app = read("source/GarminApp.mc")
        self.assertIn("const FEEDBACK_INITIAL_VISIBLE_SECONDS = 60", app)
        self.assertIn("const FEEDBACK_HIDDEN_SECONDS = 30", app)
        self.assertRegex(
            app,
            r"function updateCadenceBarAvg\(\)[\s\S]*?"
            r"if \(_sessionState != RECORDING\)[\s\S]*?return;[\s\S]*?"
            r"updateFeedbackSession\(info\)",
        )
        self.assertGreaterEqual(app.count("resetFeedbackSession();"), 2)
        self.assertIn("if (_feedbackModeEnabled)", app)

    def test_long_back_toggles_feedback_only_before_a_run(self):
        app = read("source/GarminApp.mc")
        delegate = read("source/Delegates/SimpleViewDelegate.mc")
        status_view = read("source/Views/FeedbackModeView.mc")
        self.assertIn("function toggleFeedbackMode()", app)
        self.assertIn("if (!isIdle())", app)
        self.assertIn("app.toggleFeedbackMode()", delegate)
        self.assertIn("if (!app.isIdle())", delegate)
        self.assertIn('"ON - ready for next run"', status_view)
        self.assertIn('"OFF - normal feedback"', status_view)

    def test_hidden_samples_are_scored_and_live_cues_are_suppressed(self):
        app = read("source/GarminApp.mc")
        view = read("source/Views/SimpleView.mc")
        self.assertRegex(
            app,
            r"if \(_feedbackHiddenActive && cadence != null\) \{[\s\S]*?"
            r"_feedbackHiddenSampleCount\+\+",
        )
        self.assertIn("_feedbackHiddenInRangeCount++", app)
        self.assertRegex(
            app,
            r"if \(isFeedbackHidden\(\)\)[\s\S]*?"
            r"_secondsSinceLastAlert = 0;[\s\S]*?return;",
        )
        self.assertIn("drawFeedbackHiddenIndicator", view)
        self.assertIn('"FEEDBACK"', view)
        self.assertIn('"HIDDEN"', view)
        self.assertIn("_pendingSecondVibe = false", view)

    def test_feedback_summary_precedes_existing_workout_summary(self):
        delegate = read("source/Delegates/SimpleViewDelegate.mc")
        feedback_delegate = read("source/Delegates/FeedbackSummaryDelegate.mc")
        feedback_view = read("source/Views/FeedbackSummaryView.mc")
        self.assertIn("app.hasFeedbackSummaryData()", delegate)
        self.assertIn("new FeedbackSummaryView()", delegate)
        self.assertIn("new SummaryView()", feedback_delegate)
        self.assertIn('"When hidden"', feedback_view)
        self.assertIn('"in target range"', feedback_view)
        self.assertIn('"Shaded = feedback hidden"', feedback_view)
        self.assertIn("didHoldCadenceWhenHidden", feedback_view)

    def test_feedback_summary_has_compact_round_watch_layout(self):
        feedback_view = read("source/Views/FeedbackSummaryView.mc")
        self.assertIn("width <= 450", feedback_view)
        self.assertIn("Graphics.FONT_MEDIUM", feedback_view)
        self.assertIn("compactLayout ? 0.63 : 0.66", feedback_view)
        self.assertIn("compactLayout ? 0.76 : 0.79", feedback_view)


if __name__ == "__main__":
    unittest.main()
