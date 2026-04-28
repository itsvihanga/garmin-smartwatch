import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;

class SelectBarChartDelegate extends WatchUi.Menu2InputDelegate {

    private var _menu as WatchUi.Menu2; // Added to handle Title/Focus
    var app = Application.getApp() as GarminApp;

    function initialize(menu as WatchUi.Menu2) {
        Menu2InputDelegate.initialize();
        _menu = menu;

        // 1. Get the current value to set the Title and Focus
        var currentDur = app._chartDuration; 
        var label = "30 min";

        if (currentDur == 3) { 
            label = "15 min"; 
            _menu.setFocus(0);
        } else if (currentDur == 6) { 
            label = "30 min"; 
            _menu.setFocus(1);
        } else if (currentDur == 13) { 
            label = "1 hour"; 
            _menu.setFocus(2);
        } else if (currentDur == 26) { 
            label = "2 hour"; 
            _menu.setFocus(3);
        }

        _menu.setTitle("Duration: " + label);
    }

    function onSelect(item) as Void {
        var id = item.getId();

        // 2. Use your existing setter logic
        if (id == :chart_15m) {
            app.setChartDuration(3);
            System.println("Chart Duration: Fifteenmin");
        }
        else if (id == :chart_30m) {
            app.setChartDuration(6);
            System.println("Chart Duration: Thirtymin");
        }
        else if (id == :chart_1h) {
            app.setChartDuration(13);
            System.println("Chart Duration: OneHour");
        }
        else if (id == :chart_2h) {
            app.setChartDuration(26);
            System.println("Chart Duration: TwoHour");
        }
        else {
            System.println("ERROR");
        }

        WatchUi.requestUpdate();
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

    function onMenuItem(item as Symbol) as Void {}

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}