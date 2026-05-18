import Toybox.System;
import Toybox.WatchUi;

class SummaryPromptDelegate extends WatchUi.BehaviorDelegate {

    private var _promptView;

    function initialize(promptView) {
        BehaviorDelegate.initialize();
        _promptView = promptView;
    }

    function onKey(keyEvent) {
        var key = keyEvent.getKey();

        if (key == WatchUi.KEY_UP) {
            _promptView.setSelectedOption(0);
            WatchUi.requestUpdate();
            return true;
        }

        if (key == WatchUi.KEY_DOWN) {
            _promptView.setSelectedOption(1);
            WatchUi.requestUpdate();
            return true;
        }

        return false;
    }

    function onSwipe(event) {
        var direction = event.getDirection();

        if (direction == WatchUi.SWIPE_RIGHT || direction == WatchUi.SWIPE_DOWN) {
            _promptView.setSelectedOption(0);
            WatchUi.requestUpdate();
            return true;
        }

        if (direction == WatchUi.SWIPE_LEFT || direction == WatchUi.SWIPE_UP) {
            _promptView.setSelectedOption(1);
            WatchUi.requestUpdate();
            return true;
        }

        return false;
    }

    function onSelect() {
        var app = getApp();
        var enabled = _promptView.getSelectedOption() == 0;

        app.setSummaryEnabled(enabled);
        System.println("[SUMMARY SETTINGS] Summary view preference saved: " + enabled.toString());

        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }
}
