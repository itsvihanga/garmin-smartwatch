import Toybox.Graphics;
import Toybox.WatchUi;

class CadenceSettingsMenuView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onUpdate(dc as Dc) as Void {

        // Makes screen black and clears it
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var centerX = dc.getWidth() / 2;
        var centerY = dc.getHeight() / 2;

        var icon = WatchUi.loadResource(Rez.Drawables.SetCadenceIcon);
        dc.drawBitmap(centerX - (icon.getWidth() / 2), centerY - icon.getHeight(), icon);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, centerY + 10, Graphics.FONT_MEDIUM, "Set Cadence", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, centerY + 50, Graphics.FONT_XTINY, "tap to open", Graphics.TEXT_JUSTIFY_CENTER);
    }
}
