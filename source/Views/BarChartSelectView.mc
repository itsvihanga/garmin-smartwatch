import Toybox.Graphics;
import Toybox.WatchUi;

class BarChartSelectView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();
        var app = getApp();

        //Title
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2, 
            height / 3, 
            Graphics.FONT_MEDIUM, "Bar Chart Length", 
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        
        //Value
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2, 
            height / 2, 
            Graphics.FONT_NUMBER_MILD, 
            app.getChartDuration(), 
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // Up arrow
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon([
            [width / 8, height / 2 - 25],
            [width / 8 - 9, height / 2 - 10],
            [width / 8 + 9, height / 2 - 10]
        ]);

        // Down arrow
        dc.fillPolygon([
            [width / 8, height / 2 + 25],
            [width / 8 - 9, height / 2 + 10],
            [width / 8 + 9, height / 2 + 10]
        ]);

        // Confirm hint
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2, 
            height * 4 / 5, 
            Graphics.FONT_GLANCE, "START to confirm", 
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}