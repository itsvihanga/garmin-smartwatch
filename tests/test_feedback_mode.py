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
        self.assertNotIn("checkAndTriggerAlerts()", view)

    def test_hidden_feedback_stays_concealed_while_paused(self):
        app = read("source/GarminApp.mc")
        view = read("source/Views/SimpleView.mc")
        self.assertRegex(
            app,
            r"function isFeedbackHidden\(\)[\s\S]*?"
            r"isActivityRecording\(\)[\s\S]*?_feedbackHiddenActive",
        )
        self.assertIn('"Paused - feedback stays hidden"', view)

    def test_feedback_run_uses_frozen_target_range(self):
        app = read("source/GarminApp.mc")
        feedback_view = read("source/Views/FeedbackSummaryView.mc")
        self.assertIn("_feedbackTargetMin = getCalculatedMinCadence()", app)
        self.assertIn("_feedbackTargetMax = getCalculatedMaxCadence()", app)
        self.assertIn("cadence >= getFeedbackTargetMinCadence()", app)
        self.assertIn("cadence <= getFeedbackTargetMaxCadence()", app)
        self.assertIn("app.getFeedbackTargetMinCadence()", feedback_view)
        self.assertIn("app.getFeedbackTargetMaxCadence()", feedback_view)

    def test_feedback_summary_precedes_existing_workout_summary(self):
        delegate = read("source/Delegates/SimpleViewDelegate.mc")
        feedback_delegate = read("source/Delegates/FeedbackSummaryDelegate.mc")
        feedback_view = read("source/Views/FeedbackSummaryView.mc")
        self.assertIn("app.hasFeedbackSummaryData()", delegate)
        self.assertIn("new FeedbackSummaryView()", delegate)
        self.assertIn("new SummaryView()", feedback_delegate)
        self.assertIn('"When hidden"', feedback_view)
        self.assertIn('"in target range"', feedback_view)
        self.assertIn('"Shaded = Feedback hidden"', feedback_view)
        self.assertIn("didHoldCadenceWhenHidden", feedback_view)

    def test_feedback_result_is_independent_of_workout_summary_preference(self):
        delegate = read("source/Delegates/SimpleViewDelegate.mc")
        feedback_delegate = read("source/Delegates/FeedbackSummaryDelegate.mc")
        feedback_check = delegate.index("if (app.hasFeedbackSummaryData())")
        summary_check = delegate.index("else if (app.getSummaryEnabled())", feedback_check)
        self.assertLess(feedback_check, summary_check)
        self.assertIn("if (app.getSummaryEnabled())", feedback_delegate)
        self.assertIn("app.resetSession()", feedback_delegate)

    def test_cadence_alerts_have_one_owner_and_match_documented_interval(self):
        app = read("source/GarminApp.mc")
        view = read("source/Views/SimpleView.mc")
        advanced_view = read("source/Views/AdvancedView.mc")
        self.assertIn("const CADENCE_ALERT_SECONDS = 30", app)
        self.assertIn("triggerCadenceHapticFeedback(current > maxZone)", app)
        self.assertNotIn("new CadenceAlertView", view)
        self.assertNotIn("triggerSingleVibration", view)
        self.assertNotIn("new CadenceAlertView", advanced_view)
        self.assertNotIn("triggerSingleVibration", advanced_view)

    def test_feedback_summary_has_compact_round_watch_layout(self):
        feedback_view = read("source/Views/FeedbackSummaryView.mc")
        self.assertIn("width < 300", feedback_view)
        self.assertIn("Graphics.FONT_NUMBER_MILD", feedback_view)
        self.assertIn("Graphics.FONT_MEDIUM", feedback_view)
        self.assertIn("dc.fillRoundedRectangle", feedback_view)
        self.assertIn("Rez.Drawables.FeedbackHeartRateIcon", feedback_view)
        self.assertIn("smallScreen ? 0.76 : 0.77", feedback_view)

    def test_feedback_graph_uses_recorded_time_and_clear_visual_layers(self):
        feedback_view = read("source/Views/FeedbackSummaryView.mc")
        self.assertIn("timeLog[i] - firstSecond", feedback_view)
        self.assertIn("Hidden-period strips sit behind", feedback_view)
        self.assertLess(
            feedback_view.index("dc.setColor(0x202020"),
            feedback_view.index("dc.setColor(0x174A2A"),
        )
        self.assertIn("dc.setPenWidth(smallScreen ? 2 : 3)", feedback_view)


if __name__ == "__main__":
    unittest.main()
