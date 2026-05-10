import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Application;

class CadenceTargetView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onUpdate(dc as Dc) as Void {

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();

        var app = Application.getApp() as GarminApp;
        var targetCadence = app.getTargetCadence();
       //var targetCadence = 160;

        // Title
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        dc.drawText(
            width / 2,
            height / 3,
            Graphics.FONT_MEDIUM,
            "Target Cadence",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // Cadence Number
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);

        dc.drawText(
            width / 2,
            height / 2,
            Graphics.FONT_NUMBER_HOT,
            targetCadence.toString(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // Unit
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);

        dc.drawText(
            width / 2,
            (height / 2) + 50,
            Graphics.FONT_SMALL,
            "spm",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}