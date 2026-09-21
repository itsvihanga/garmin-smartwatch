import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

class FeedbackSummaryDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onSelect() as Boolean {
        showWorkoutSummary();
        return true;
    }

    function onBack() as Boolean {
        showWorkoutSummary();
        return true;
    }

    function onSwipe(event as WatchUi.SwipeEvent) as Boolean {
        var direction = event.getDirection();
        if (direction == WatchUi.SWIPE_LEFT || direction == WatchUi.SWIPE_DOWN) {
            showWorkoutSummary();
            return true;
        }
        return false;
    }

    function showWorkoutSummary() as Void {
        var app = getApp();
        if (app.getSummaryEnabled()) {
            System.println("[FEEDBACK] Opening workout summary");
            WatchUi.switchToView(
                new SummaryView(),
                new SummaryViewDelegate(),
                WatchUi.SLIDE_UP
            );
        } else {
            System.println("[FEEDBACK] Workout summary disabled; returning to main view");
            app.resetSession();
            WatchUi.switchToView(
                new SimpleView(),
                new SimpleViewDelegate(),
                WatchUi.SLIDE_DOWN
            );
        }
    }
}
