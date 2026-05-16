import Toybox.Graphics;
import Toybox.WatchUi;

class SettingsView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onUpdate(dc as Dc) as Void {

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();

        var centerX = width / 2;
        var centerY = height / 2;

        var icon = WatchUi.loadResource(Rez.Drawables.SettingsIcon);

        var iconX = centerX - (icon.getWidth() / 2);
        var iconY = centerY - 70;

        dc.drawBitmap(iconX, iconY, icon);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        dc.drawText(centerX - 1, centerY + 20, Graphics.FONT_LARGE, "Settings", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(centerX + 1, centerY + 20, Graphics.FONT_LARGE, "Settings", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);

        dc.drawText(
            centerX,
            centerY + 90,
            Graphics.FONT_XTINY,
            "Tap to Open",
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }
}