import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Application;

class CadenceTargetDelegate extends WatchUi.BehaviorDelegate {

    private var _target as Number;

    function initialize() {
        BehaviorDelegate.initialize();

        var app = Application.getApp() as GarminApp;

        _target = app.getTargetCadence();
    }

    function onBack() as Boolean {

        WatchUi.popView(WatchUi.SLIDE_DOWN);

        return true;
    }

    function onSelect() as Boolean {

        var app = Application.getApp() as GarminApp;

        app.setTargetCadence(_target);

        WatchUi.popView(WatchUi.SLIDE_UP);

        return true;
    }

    function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {

        var key = keyEvent.getKey();

        var app = Application.getApp() as GarminApp;

        if (key == WatchUi.KEY_UP) {

            _target = _target + 1;

            app.setTargetCadence(_target);

            WatchUi.requestUpdate();

            return true;
        }

        if (key == WatchUi.KEY_DOWN) {

            _target = _target - 1;

            app.setTargetCadence(_target);

            WatchUi.requestUpdate();

            return true;
        }

        return false;
    }
}
