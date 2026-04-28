import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;

class CadenceSettingsMenuDelegate extends WatchUi.BehaviorDelegate { 

    function initialize() {
        BehaviorDelegate.initialize();
    }

    // Handles the BACK button
    function onBack() as Boolean {
        System.println("Back pressed: Returning to main view");

        WatchUi.pushView(new SimpleView(), new SimpleViewDelegate(), WatchUi.SLIDE_DOWN);
        return true;
    }

    // Handles the SELECT/START button (or screen tap)
    function onSelect() as Boolean {
        System.println("Select pressed: Opening CadenceMinView");
        WatchUi.switchToView(
            new CadenceMinView(),
            new CadenceMinDelegate(),
            WatchUi.SLIDE_UP
        );
        return true;
    }

    // Handles the DOWN button (or swipe up)
    function onNextPage() as Boolean {
        System.println("Down button pressed");
        
        // Push the bar chart settings view
        WatchUi.pushView(new BarChartSettingsMenuView(), new BarChartSettingsMenuDelegate(), WatchUi.SLIDE_UP);
        
        return true; 
    }

    // Handles the UP button (or swipe down)
    function onPreviousPage() as Boolean {
        System.println("Up button pressed");
        
        // Push the profile settings view
        WatchUi.pushView(new SummarySettingsMenuView(), new SummarySettingsMenuDelegate(), WatchUi.SLIDE_DOWN);
        
        return true; 
    }


    function pushCadenceMenu() as Void {

        //sets the cadence variables to the global app variable to be used within the title
        var app = Application.getApp() as GarminApp;
        var minCadence = app.getMinCadence();
        var maxCadence = app.getMaxCadence();

        var menu = new WatchUi.Menu2({
            :title => Lang.format("Cadence: $1$ - $2$", [minCadence, maxCadence])
        });

        menu.addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.menu_set_min), null, :item_set_min, null));
        menu.addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.menu_set_max), null, :item_set_max, null));

        WatchUi.pushView(menu, new SelectCadenceDelegate(menu), WatchUi.SLIDE_LEFT);

    }
}