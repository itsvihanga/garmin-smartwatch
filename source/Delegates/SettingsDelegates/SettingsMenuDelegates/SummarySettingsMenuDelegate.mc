import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;

class SummarySettingsMenuDelegate extends WatchUi.BehaviorDelegate { 

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onBack() {
        System.println("Back pressed: Returning to main view");

        WatchUi.pushView(
            new SimpleView(),
            new SimpleViewDelegate(),
            WatchUi.SLIDE_DOWN
        );

        return true;
    }

    function onSelect() {
        System.println("Select/Tap pressed: toggle summary on/off");

        // Future summary ON/OFF logic can go here.
        return true;
    }

    // DOWN button: Summary Settings -> Reset Settings
    function onNextPage() {
        System.println("Down button pressed: Opening Reset Settings");

        var resetView = new ResetSettingsView();

        WatchUi.pushView(
            resetView,
            new ResetSettingsDelegate(resetView),
            WatchUi.SLIDE_UP
        );

        return true;
    }

    // UP button: Summary Settings -> Bar Chart Settings
    function onPreviousPage() {
        System.println("Up button pressed: Back to Bar Chart Settings");

        WatchUi.pushView(
            new BarChartSettingsMenuView(),
            new BarChartSettingsMenuDelegate(),
            WatchUi.SLIDE_DOWN
        );

        return true;
    }
}
