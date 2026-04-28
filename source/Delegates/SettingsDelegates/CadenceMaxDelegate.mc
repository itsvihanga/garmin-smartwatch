import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Application;

class CadenceMaxDelegate extends WatchUi.BehaviorDelegate {

    // _max stores the current maximum cadence value locally
    private var _max as Number;

    function initialize() {
        BehaviorDelegate.initialize();
        // Get the current max cadence from the app when screen opens
        var app = Application.getApp() as GarminApp;
        _max = app.getMaxCadence();
    }

    // BACK → go back to CadenceMinView
    function onBack() as Boolean {
        System.println("[SETTINGS] CadenceMax: Back - returning to CadenceMinView");
        WatchUi.switchToView(
            new CadenceMinView(),
            new CadenceMinDelegate(),
            WatchUi.SLIDE_DOWN
        );
        return true;
    }

    // SELECT → save current value and go back to CadenceSettingsMenuView
    function onSelect() as Boolean {
        System.println("[SETTINGS] CadenceMax: Select - saving max and returning to CadenceSettingsMenu");
        var app = Application.getApp() as GarminApp;
        app.setMaxCadence(_max);
        WatchUi.switchToView(
            new CadenceSettingsMenuView(),
            new CadenceSettingsMenuDelegate(),
            WatchUi.SLIDE_UP
        );
        return true;
    }

    function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {
        var key = keyEvent.getKey();
        var app = Application.getApp() as GarminApp;

        // UP → increase max cadence by 1 and save immediately
        if (key == WatchUi.KEY_UP) {
            _max = _max + 1;
            app.setMaxCadence(_max);
            System.println("[SETTINGS] CadenceMax: UP - max is now " + _max);
            WatchUi.requestUpdate();
            return true;
        }

        // DOWN → decrease max cadence by 1 and save immediately
        if (key == WatchUi.KEY_DOWN) {
            _max = _max - 1;
            app.setMaxCadence(_max);
            System.println("[SETTINGS] CadenceMax: DOWN - max is now " + _max);
            WatchUi.requestUpdate();
            return true;
        }

        return false;
    }
}