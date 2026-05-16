
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Lang;


class CadenceSettingsMenuDelegate extends WatchUi.BehaviorDelegate { 

    function initialize() {
        BehaviorDelegate.initialize();
    }

    // Handles the BACK button
    function onBack() as Boolean {

        System.println("Back pressed: Returning to main view");

        WatchUi.switchToView(
            new SimpleView(),
            new SimpleViewDelegate(),
            WatchUi.SLIDE_DOWN
        );

        return true;
    }

    // Handles the SELECT/START button
    function onSelect() as Boolean {

        System.println("Select pressed: Opening CadenceTargetView");

        WatchUi.pushView(
            new CadenceTargetView(),
            new CadenceTargetDelegate(),
            WatchUi.SLIDE_UP
        );

        return true;
    }

    // Handles the DOWN button (or swipe up)
    function onNextPage() {
    System.println("Down button pressed: Opening Bar Chart Settings");

    WatchUi.pushView(
        new BarChartSettingsMenuView(),
        new BarChartSettingsMenuDelegate(),
        WatchUi.SLIDE_UP
    );

    return true;
}

    // Handles the UP button (or swipe down)
   function onPreviousPage() {
    System.println("Up button pressed: Opening Reset Settings");

    var resetView = new ResetSettingsView();

    WatchUi.pushView(
        resetView,
        new ResetSettingsDelegate(resetView),
        WatchUi.SLIDE_DOWN
    );

    return true;
}

    // Handles the UP button
    function onPreviousPage() as Boolean {

        System.println("Up button pressed");

        WatchUi.switchToView(
            new SummarySettingsMenuView(),
            new SummarySettingsMenuDelegate(),
            WatchUi.SLIDE_DOWN
        );

        return true; 
    }
}
