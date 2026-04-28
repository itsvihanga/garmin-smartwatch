import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Application;

class CadenceMinDelegate extends WatchUi.BehaviorDelegate {

    // _min stores the current minimum cadence value locally
    // so we can change it with UP/DOWN before saving
    private var _min as Number;

    function initialize() {
        BehaviorDelegate.initialize();
        // Get the current min cadence from the app when screen opens
        var app = Application.getApp() as GarminApp;
        _min = app.getMinCadence();
    }

    // BACK → go back to CadenceSettingsMenuView
    function onBack() as Boolean {
        System.println("[SETTINGS] CadenceMin: Back - returning to CadenceSettingsMenu");
        WatchUi.switchToView(
            new CadenceSettingsMenuView(),
            new CadenceSettingsMenuDelegate(),
            WatchUi.SLIDE_DOWN
        );
        return true;
    }

    // SELECT → save current value and go to CadenceMaxView
    function onSelect() as Boolean {
        System.println("[SETTINGS] CadenceMin: Select - saving min and going to CadenceMaxView");
        var app = Application.getApp() as GarminApp;
        app.setMinCadence(_min);
        WatchUi.switchToView(
            new CadenceMaxView(),
            new CadenceMaxDelegate(),
            WatchUi.SLIDE_UP
        );
        return true;
    }

    function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {
        var key = keyEvent.getKey();
        var app = Application.getApp() as GarminApp;

        // UP → increase min cadence by 1 and save immediately
        if (key == WatchUi.KEY_UP) {
            _min = _min + 1;
            app.setMinCadence(_min);
            System.println("[SETTINGS] CadenceMin: UP - min is now " + _min);
            WatchUi.requestUpdate(); // refreshes screen to show new value
            return true;
        }

        // DOWN → decrease min cadence by 1 and save immediately
        if (key == WatchUi.KEY_DOWN) {
            _min = _min - 1;
            app.setMinCadence(_min);
            System.println("[SETTINGS] CadenceMin: DOWN - min is now " + _min);
            WatchUi.requestUpdate(); // refreshes screen to show new value
            return true;
        }

        return false;
    }
}