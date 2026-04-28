import Toybox.Graphics;
import Toybox.WatchUi;

// CadenceMinView
// This screen shows the user their current minimum cadence setting.
// It is a simple display screen - the user cannot edit the value here.
// Editing happens through the existing CadenceRangePickerDelegate.
class CadenceMinView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onUpdate(dc as Dc) as Void {

        // Step 1: Clear the screen with a black background
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // Step 2: Get screen dimensions so we can centre text
        var width = dc.getWidth();
        var height = dc.getHeight();

        // Step 3: Get the current minimum cadence value from the app
        var app = getApp();
        var minCadence = app.getMinCadence();

        // Step 4: Draw the screen title "Min Cadence" in the upper area
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            height / 3,
            Graphics.FONT_MEDIUM,
            "Min Cadence",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // Step 5: Draw the actual minimum cadence value in large text in the centre
        // This shows the user what their current minimum cadence is set to
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            height / 2,
            Graphics.FONT_NUMBER_HOT,
            minCadence.toString(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // Step 6: Draw "spm" label below the number so user knows the unit
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
