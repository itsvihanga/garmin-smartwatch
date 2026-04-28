import Toybox.Graphics;
import Toybox.WatchUi;

class BarChartSettingsMenuView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        
        // Makes screen black and clears it
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        var centerX = dc.getWidth() / 2;
        var centerY = dc.getHeight() / 2;
        var lineSpacing = 50; // Adjust this based on font size
        // draws "Settings" text in the center of the screen
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, centerY - (lineSpacing/2), Graphics.FONT_MEDIUM, "Change", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(centerX, centerY + (lineSpacing/2), Graphics.FONT_MEDIUM, "Bar Chart Length", Graphics.TEXT_JUSTIFY_CENTER);
    }
}