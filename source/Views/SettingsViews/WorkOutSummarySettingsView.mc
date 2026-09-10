import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class WorkOutSummarySettingsView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        // Clear background to black
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;

        // Dynamic spacing calculations
        var titleY = (height * 0.20).toNumber();
        var startY = (height * 0.40).toNumber();
        var gap = (height * 0.12).toNumber(); 
        var leftMargin = (width * 0.15).toNumber();
        var rightMargin = (width * 0.85).toNumber();

        // 1. Draw Title
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX, 
            titleY, 
            Graphics.FONT_MEDIUM, 
            "Workout Summary", 
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // Mock variables - replace these with your app.get...() calls
        var avgCadence = "171 spm";
        var duration = "45:00";
        var cadenceScore = "92%";
        var calories = "320 kcal";

        // 2. Draw Metric Rows
        drawMetricRow(dc, leftMargin, rightMargin, startY, "Avg Cadence", avgCadence, Graphics.COLOR_GREEN);
        drawMetricRow(dc, leftMargin, rightMargin, startY + gap, "Duration", duration, Graphics.COLOR_WHITE);
        drawMetricRow(dc, leftMargin, rightMargin, startY + (gap * 2), "Cadence Score", cadenceScore, Graphics.COLOR_GREEN);
        drawMetricRow(dc, leftMargin, rightMargin, startY + (gap * 3), "Calories", calories, Graphics.COLOR_GREEN);
    }

    // Helper function to draw consistent left-aligned labels and right-aligned values
    function drawMetricRow(dc as Dc, leftX as Number, rightX as Number, y as Number, label as String, value as String, valueColor as Number) as Void {
        
        // Label (Always White)
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            leftX, 
            y, 
            Graphics.FONT_SMALL, 
            label, 
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // Value (Dynamic Color)
        dc.setColor(valueColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            rightX, 
            y, 
            Graphics.FONT_SMALL, 
            value, 
            Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}