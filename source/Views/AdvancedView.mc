import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Activity;
import Toybox.Lang;
import Toybox.System;
import Toybox.Application;

class AdvancedView extends WatchUi.View {
    const MAX_BARS = 280;
    const MAX_CADENCE_DISPLAY = 200;

    const COLOR_BELOW = 0xFF0000; // red
    const COLOR_IN_ZONE = 0x00BF63; // green
    const COLOR_TEXT_MUTED = 0x969696;
    const COLOR_CHART_BORDER = 0x969696;

    function initialize() {
        View.initialize();
    }

    function onShow() as Void {
        var app = Application.getApp() as GarminApp;
        app.startRefreshTimer(self, "advanced_view", method(:refreshScreen));
        System.println("[AdvancedView] screen opened");
    }

    function onHide() as Void {
        var app = Application.getApp() as GarminApp;
        app.stopRefreshTimer(self, "advanced_view");
    }

    // THIS IS THE MAIN LOGIC LOOP (Runs every 1 second)
    function refreshScreen() as Void {
        // Cadence sampling and zone alerts are handled centrally by
        // GarminApp.handleRefreshTick(), so they keep running even when this
        // view isn't the one currently visible.
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Dc) as Void {
        // Only Drawing here
        View.onUpdate(dc);
        drawElements(dc);
    }

    function drawElements(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var info = Activity.getActivityInfo();
        var app = Application.getApp();
        
        // 1. Draw elapsed time
        if (info != null && info.timerTime != null) {
            var seconds = info.timerTime / 1000;
            var timeStr = (seconds / 3600).format("%01d") + ":" + ((seconds % 3600) / 60).format("%02d") + ":" + (seconds % 60).format("%02d");
            dc.setColor(0xFFF813, Graphics.COLOR_TRANSPARENT);
            dc.drawText(width / 2, 3, Graphics.FONT_MEDIUM, timeStr, Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        // 2. Draw heart rate circle
        var hrX = width / 4;
        var hrY = (height * 2) / 7;
        var circleRadius = 42;
        dc.setColor(0x9D0000, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(hrX, hrY, circleRadius);
        
        if (info != null && info.currentHeartRate != null) {
            dc.setColor(0xFFFFFF, Graphics.COLOR_TRANSPARENT);
            dc.drawText(hrX, hrY - 25, Graphics.FONT_TINY, info.currentHeartRate.toString(), Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(hrX, hrY + 8, Graphics.FONT_XTINY, "bpm", Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        // 3. Draw Pace circle
        var distX = (width * 3) / 4;
        var distY = hrY;
        dc.setColor(0x1D5E11, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(distX, distY, circleRadius);
        
        if (info != null && info.currentSpeed != null && info.currentSpeed > 0) {
            var paceSec = (1000.0 / info.currentSpeed).toNumber();
            var paceStr = (paceSec / 60).format("%d") + ":" + (paceSec % 60).format("%02d");
            dc.setColor(0xFFFFFF, Graphics.COLOR_TRANSPARENT);
            dc.drawText(distX, distY - 25, Graphics.FONT_TINY, paceStr, Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(distX, distY + 8, Graphics.FONT_XTINY, "/km", Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            dc.setColor(0xFFFFFF, Graphics.COLOR_TRANSPARENT);
            dc.drawText(distX, distY - 25, Graphics.FONT_TINY, "--:--", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(distX, distY + 8, Graphics.FONT_XTINY, "/km", Graphics.TEXT_JUSTIFY_CENTER);
        }

        // 4. Draw Cadence Info
        var idealMinCadence = app.getCalculatedMinCadence();
        var idealMaxCadence = app.getCalculatedMaxCadence();
        var cadenceY = height * 0.37;
        var cadenceRangeY = height * 0.43;

        if (info != null && info.currentCadence != null) {
            dc.setColor(getCadenceZoneColor(info.currentCadence, idealMinCadence, idealMaxCadence), Graphics.COLOR_TRANSPARENT);
            dc.drawText(width / 2, cadenceY, Graphics.FONT_XTINY, info.currentCadence.toString() + " spm", Graphics.TEXT_JUSTIFY_CENTER);
        }

        dc.setColor(0x969696, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, cadenceRangeY, Graphics.FONT_XTINY, "Target: " + idealMinCadence + "-" + idealMaxCadence, Graphics.TEXT_JUSTIFY_CENTER);

        // 5. Draw Chart
        drawChart(dc);
        
        dc.setColor(0x969696, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, height * 0.85, Graphics.FONT_XTINY, "Last " + app.getChartDuration(), Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawChart(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var chartLeft = width * 0.138;
        var chartRight = width - chartLeft;
        var chartTop = height * 0.5;
        var chartBottom = height - (dc.getHeight() * 0.1 * 1.6);
        var chartWidth = chartRight - chartLeft;
        var chartHeight = chartBottom - chartTop;

        dc.setColor(0x969696, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(chartLeft, chartTop, chartWidth, chartHeight);
        
        var app = Application.getApp();
        var cadenceHistory = app.getCadenceHistory();
        var cadenceCount = app.getCadenceCount();
        if (cadenceCount == 0) { return; }

        var selectedBars = app.getChartBarCount();
        var numBars = (cadenceCount < selectedBars) ? cadenceCount : selectedBars;
        var barWidth = (chartWidth / numBars).toNumber();
        if (barWidth < 2) { barWidth = 2; }

        var startIndex = (app.getCadenceIndex() - numBars + MAX_BARS) % MAX_BARS;
        var minZ = app.getCalculatedMinCadence();
        var maxZ = app.getCalculatedMaxCadence();

        for (var i = 0; i < numBars; i++) {
            var cadence = cadenceHistory[(startIndex + i) % MAX_BARS];
            if (cadence == null) { cadence = 0; }

            var bHeight = ((cadence / MAX_CADENCE_DISPLAY) * chartHeight).toNumber();
            var x = (chartLeft + 1) + i * barWidth;
            var y = (chartBottom - 1) - bHeight;

            dc.setColor(getCadenceZoneColor(cadence, minZ, maxZ), Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(x, y, barWidth - 1, bHeight);
        }
    }

    function getCadenceZoneColor(cadence, min, max) {
        return (cadence < min) ? COLOR_BELOW : COLOR_IN_ZONE;
    }
}
