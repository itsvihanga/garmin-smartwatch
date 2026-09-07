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

    // Handles the DOWN button (or swipe up)
    function onNextPage() as Boolean {
        System.println("Down button pressed: Opening Bar Chart Settings");
        
        WatchUi.switchToView(
            new BarChartSettingsMenuView(),
            new BarChartSettingsMenuDelegate(),
            WatchUi.SLIDE_UP);
        
        return true; 
    }

    // Handles the UP button (or swipe down)
    function onPreviousPage() {
        System.println("Up button pressed: Opening Profile Settings");

        WatchUi.pushView(
            new ProfileSettingsMenuView(),
            new ProfileSettingsMenuDelegate(),
            WatchUi.SLIDE_DOWN
        );

        return true;
    }
}
