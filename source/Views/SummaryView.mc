import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Activity;
import Toybox.WatchUi;

class SummaryView extends WatchUi.View {

    private var _iconDistance;
    private var _iconCadence;
    private var _iconHR;
    private var _iconSteps;
    private var _iconTime;

    function initialize() {
        View.initialize();

        // Load icons for summary view
        _iconDistance = Application.loadResource(Rez.Drawables.IconDistance);
        _iconCadence = Application.loadResource(Rez.Drawables.IconCadence);
        _iconHR = Application.loadResource(Rez.Drawables.IconHeartRate);
        _iconSteps = Application.loadResource(Rez.Drawables.IconSteps);
        _iconTime = Application.loadResource(Rez.Drawables.IconTime);
    }

function onUpdate(dc as Dc) as Void {

    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
    dc.clear();

    var app = getApp();
    var width = dc.getWidth();
    var height = dc.getHeight();

    // Only show summary if valid data exists
    if (!app.hasValidSummaryData()) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            height / 2,
            Graphics.FONT_MEDIUM,
            "No data available",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        return;
    }

    var centerX = width / 2;

    // ✅ PUSH EVERYTHING LOWER + MORE SPACE
    var titleY = 40;
    var startY = 60;
    var gap = 28;  

    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

    // TITLE (tiny)
    dc.drawText(centerX, titleY, Graphics.FONT_XTINY,
        "Workout Summary",
        Graphics.TEXT_JUSTIFY_CENTER
    );

    //add for other metrics such as steps
    var duration = app.getSessionDuration();
    var distance = app.getSessionDistance();
    var hr = app.getAvgHeartRate();
    var pace = app.getAveragePace();
    var qcScore = app.getfinalQC();
    var temperature = app.getLinkedTemperature();

    if (duration == null) { duration = 0; }
    if (distance == null) { distance = 0; }
    if (hr == null) { hr = 0; }

    // TIME FORMAT
    var seconds = duration / 1000;
    var h = seconds / 3600;
    var m = (seconds % 3600) / 60;
    var s = seconds % 60;

    var timeStr = h.format("%02d") + ":" +
                  m.format("%02d") + ":" +
                  s.format("%02d");

    // ===== METRICS =====
    var km = distance / 100000.0;

        drawRow(dc, width, startY + gap, timeStr, _iconTime, "TIME");
        drawRow(dc, width, startY + gap * 2, km.format("%.2f"), _iconDistance, "DISTANCE");
        drawRow(dc, width, startY + gap * 3, "--", _iconCadence, "CADENCE");
        drawRow(dc, width, startY + gap * 4, hr + "", _iconHR, "BPM (AVG)");
        drawRow(dc, width, startY + gap * 5, "--", _iconSteps, "STEPS");

        drawRow(dc, width, startY + gap * 6, pace, _iconCadence, "AVG PACE");
        drawRow(dc, width, startY + gap * 7, qcScore, _iconHR, "QC SCORE");
        drawRow(dc, width, startY + gap * 8, temperature, _iconSteps, "TEMP");
}


// 🔥 UPDATED ROW (ALL TINY + MORE SPACING FRIENDLY)
function drawRow(dc as Dc, width as Number, y as Number, value as String, icon as Graphics.BitmapType, label as String) as Void {

    var leftMargin = 40;
    var rightMargin = width - 40;

    // Drawing the icon: Subtracting 24 from Y pushes the top-left corner of the icon up, to center the icon in line with the text (icon is 50x50).
    dc.drawBitmap(leftMargin, y - 24, icon);

    // Drawing the label: We add VCENTER so the vertical middle of the text lines up exactly with our y coordinate.
    dc.drawText(leftMargin + 50, y, Graphics.FONT_XTINY, label, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

    // Drawing the value: Also using VCENTER to keep the number on the same line as the label and icon.
    dc.drawText(rightMargin, y, Graphics.FONT_XTINY, value, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
}

    function drawNoDataMessage(dc as Dc, width as Number, height as Number) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            height / 2,
            Graphics.FONT_MEDIUM,
            "No data available",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function drawSummaryContent(dc as Dc, width as Number, height as Number, app as GarminApp) as Void {
        var yPos = 10;
        var lineHeight = 25;
        var sectionSpacing = 15;

        // Title
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            yPos,
            Graphics.FONT_SMALL,
            "SESSION SUMMARY",
            Graphics.TEXT_JUSTIFY_CENTER
        );
        yPos += lineHeight + sectionSpacing;

        // Draw separator line
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(10, yPos, width - 10, yPos);
        yPos += sectionSpacing;

        // Cadence Quality Score (Large and prominent)
        var cq = app.getFinalCadenceQuality();
        if (cq != null) {
            var cqColor = getCQColor(cq);
            dc.setColor(cqColor, Graphics.COLOR_TRANSPARENT);
            
            // CQ Label
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                width / 2,
                yPos,
               Graphics.FONT_XTINY,
                "Cadence Quality",
                Graphics.TEXT_JUSTIFY_CENTER
            );
            yPos += lineHeight;

            // CQ Score (large)
            dc.setColor(cqColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                width / 2,
                yPos,
                Graphics.FONT_NUMBER_HOT,
                cq.format("%d") + "%",
                Graphics.TEXT_JUSTIFY_CENTER
            );
            yPos += lineHeight + 5;

            // CQ Confidence and Trend
            var confidence = app.getFinalCQConfidence();
            var trend = app.getFinalCQTrend();
            if (confidence != null && trend != null) {
                dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
                var statusText = "(" + confidence + ", " + trend + ")";
                dc.drawText(
                    width / 2,
                    yPos,
                    Graphics.FONT_TINY,
                    statusText,
                    Graphics.TEXT_JUSTIFY_CENTER
                );
                yPos += lineHeight + sectionSpacing;
            }
        }

        // Draw separator line
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(10, yPos, width - 10, yPos);
        yPos += sectionSpacing;

        // Time in Zone
        var timeInZone = app.getTimeInZonePercentage();
        if (timeInZone >= 0) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                15,
                yPos,
                Graphics.FONT_SMALL,
                "Time in Zone:",
                Graphics.TEXT_JUSTIFY_LEFT
            );
            
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                width - 15,
                yPos,
                Graphics.FONT_SMALL,
                timeInZone.format("%d") + "%",
                Graphics.TEXT_JUSTIFY_RIGHT
            );
            yPos += lineHeight + 3;

            // Draw progress bar
            drawProgressBar(dc, width, yPos, timeInZone, Graphics.COLOR_GREEN);
            yPos += 12 + sectionSpacing;
        }

        // Average Cadence
        var avgCadence = app.getAverageCadence();
        if (avgCadence > 0) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                15,
                yPos,
                Graphics.FONT_SMALL,
                "Avg Cadence:",
                Graphics.TEXT_JUSTIFY_LEFT
            );
            
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                width - 15,
                yPos,
                Graphics.FONT_SMALL,
                avgCadence.format("%.0f") + " spm",
                Graphics.TEXT_JUSTIFY_RIGHT
            );
            yPos += lineHeight + sectionSpacing;
        }

        // Min/Max Cadence
        var minCad = app.getMinCadenceFromHistory();
        var maxCad = app.getMaxCadenceFromHistory();
        if (minCad > 0 && maxCad > 0) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                15,
                yPos,
                Graphics.FONT_TINY,
                "Range:",
                Graphics.TEXT_JUSTIFY_LEFT
            );
            
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            var rangeText = minCad.format("%.0f") + "-" + maxCad.format("%.0f") + " spm";
            dc.drawText(
                width - 15,
                yPos,
                Graphics.FONT_TINY,
                rangeText,
                Graphics.TEXT_JUSTIFY_RIGHT
            );
            yPos += lineHeight;
        }

        // Target Zone
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            15,
            yPos,
            Graphics.FONT_TINY,
            "Target:",
            Graphics.TEXT_JUSTIFY_LEFT
        );
        
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        var targetText = app.getMinCadence().toString() + "-" + app.getMaxCadence().toString() + " spm";
        dc.drawText(
            width - 15,
            yPos,
            Graphics.FONT_TINY,
            targetText,
            Graphics.TEXT_JUSTIFY_RIGHT
        );
        yPos += lineHeight + sectionSpacing;

        // Draw separator line
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(10, yPos, width - 10, yPos);
        yPos += sectionSpacing;

        // Activity Metrics Section
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            yPos,
            Graphics.FONT_SMALL,
            "Activity Metrics",
            Graphics.TEXT_JUSTIFY_CENTER
        );
        yPos += lineHeight + sectionSpacing;

        // Duration
        var duration = app.getSessionDuration();
        if (duration != null) {
            var seconds = duration / 1000;
            var hours = seconds / 3600;
            var minutes = (seconds % 3600) / 60;
            var secs = seconds % 60;
            var durationText = hours.format("%02d") + ":" + minutes.format("%02d") + ":" + secs.format("%02d");
            
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                15,
                yPos,
                Graphics.FONT_SMALL,
                "Duration:",
                Graphics.TEXT_JUSTIFY_LEFT
            );
            
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                width - 15,
                yPos,
                Graphics.FONT_SMALL,
                durationText,
                Graphics.TEXT_JUSTIFY_RIGHT
            );
            yPos += lineHeight + sectionSpacing;
        }

        // Distance
        var distance = app.getSessionDistance();
        if (distance != null) {
            var distanceKm = distance / 100000.0;
            
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                15,
                yPos,
                Graphics.FONT_SMALL,
                "Distance:",
                Graphics.TEXT_JUSTIFY_LEFT
            );
            
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                width - 15,
                yPos,
                Graphics.FONT_SMALL,
                distanceKm.format("%.2f") + " km",
                Graphics.TEXT_JUSTIFY_RIGHT
            );
            yPos += lineHeight + sectionSpacing;
        }

        // Average Heart Rate
        var avgHR = app.getAvgHeartRate();
        if (avgHR != null) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                15,
                yPos,
                Graphics.FONT_SMALL,
                "Avg HR:",
                Graphics.TEXT_JUSTIFY_LEFT
            );
            
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                width - 15,
                yPos,
                Graphics.FONT_SMALL,
                avgHR.toString() + " bpm",
                Graphics.TEXT_JUSTIFY_RIGHT
            );
            yPos += lineHeight;
        }

        // Peak Heart Rate (if different from average)
        var peakHR = app.getPeakHeartRate();
        if (peakHR != null && avgHR != null && peakHR > avgHR) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                15,
                yPos,
                Graphics.FONT_TINY,
                "Peak HR:",
                Graphics.TEXT_JUSTIFY_LEFT
            );
            
            dc.setColor(Graphics.COLOR_DK_RED, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                width - 15,
                yPos,
                Graphics.FONT_TINY,
                peakHR.toString() + " bpm",
                Graphics.TEXT_JUSTIFY_RIGHT
            );
            yPos += lineHeight;
        }

        // Instructions at bottom
        yPos = height - 20;
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            yPos,
            Graphics.FONT_XTINY,
            "Press SELECT to continue",
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    function drawProgressBar(dc as Dc, width as Number, yPos as Number, percentage as Number, color as Number) as Void {
        var barWidth = width - 30; // 15px margin on each side
        var barHeight = 8;
        var barX = 15;
        var barY = yPos;

        // Draw background (empty bar)
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(barX, barY, barWidth, barHeight);

        // Draw filled portion
        if (percentage > 0) {
            var filledWidth = (barWidth * percentage / 100.0).toNumber();
            if (filledWidth > barWidth) { filledWidth = barWidth; }
            
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(barX, barY, filledWidth, barHeight);
        }

        // Draw border
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(barX, barY, barWidth, barHeight);
    }

    function getCQColor(cq as Number) as Number {
        if (cq >= 80) {
            return Graphics.COLOR_GREEN;
        } else if (cq >= 60) {
            return Graphics.COLOR_YELLOW;
        } else if (cq >= 40) {
            return Graphics.COLOR_ORANGE;
        } else {
            return Graphics.COLOR_RED;
        }
    }
}
