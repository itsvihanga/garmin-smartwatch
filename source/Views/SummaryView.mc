import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class SummaryView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var app = getApp();
        var width = dc.getWidth();
        var height = dc.getHeight();
        var titleY = (height * 0.07).toNumber();
        var dividerY = (height * 0.16).toNumber();
        var startY = (height * 0.24).toNumber();
        var gap = (height * 0.105).toNumber();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            titleY,
            Graphics.FONT_XTINY,
            "Workout Summary",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(
            (width * 0.18).toNumber(),
            dividerY,
            (width * 0.82).toNumber(),
            dividerY
        );

        var duration = app.getSessionDuration();
        var distance = app.getSessionDistance();

        drawRow(dc, width, startY, SummaryFormatter.formatDuration(duration), :duration, "DURATION");
        drawRow(dc, width, startY + gap, SummaryFormatter.formatDistance(distance), :distance, "DISTANCE");
        drawRow(dc, width, startY + gap * 2, SummaryFormatter.formatCadence(app.getAverageCadence()), :cadence, "AVG CADENCE");
        drawRow(dc, width, startY + gap * 3, SummaryFormatter.formatHeartRate(app.getAvgHeartRate()), :heart_rate, "AVG HR");
        drawRow(dc, width, startY + gap * 4, SummaryFormatter.formatAveragePace(duration, distance), :pace, "AVG PACE");
        drawRow(dc, width, startY + gap * 5, SummaryFormatter.formatCadenceQuality(app.getFinalCadenceQuality()), :quality, "CADENCE QUALITY");
        drawRow(dc, width, startY + gap * 6, SummaryFormatter.formatTemperature(app.getSessionTemperature()), :temperature, "TEMPERATURE");
    }

    function drawRow(
        dc as Dc,
        width as Number,
        y as Number,
        value as String,
        iconType as Symbol,
        label as String
    ) as Void {
        var leftMargin = (width * 0.08).toNumber();
        var rightMargin = (width * 0.94).toNumber();
        var iconX = leftMargin + 7;
        var labelX = leftMargin + 20;

        drawIcon(dc, iconX, y, iconType);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            labelX,
            y,
            Graphics.FONT_XTINY,
            label,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.drawText(
            rightMargin,
            y,
            Graphics.FONT_XTINY,
            value,
            Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    private function drawIcon(dc as Dc, x as Number, y as Number, iconType as Symbol) as Void {
        if (iconType == :duration) {
            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
            dc.drawCircle(x, y, 6);
            dc.drawLine(x, y, x, y - 4);
            dc.drawLine(x, y, x + 3, y);
        } else if (iconType == :distance) {
            dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(x - 6, y, x + 6, y);
            dc.drawLine(x + 3, y - 3, x + 6, y);
            dc.drawLine(x + 3, y + 3, x + 6, y);
        } else if (iconType == :cadence) {
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(x - 5, y - 3, 2, 6);
            dc.fillRectangle(x - 1, y - 6, 2, 9);
            dc.fillRectangle(x + 3, y - 4, 2, 7);
        } else if (iconType == :heart_rate) {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.drawCircle(x, y, 5);
            dc.drawLine(x - 4, y, x - 1, y);
            dc.drawLine(x - 1, y, x + 1, y - 3);
            dc.drawLine(x + 1, y - 3, x + 3, y + 2);
            dc.drawLine(x + 3, y + 2, x + 5, y);
        } else if (iconType == :pace) {
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(x + 2, y - 6, x - 2, y);
            dc.drawLine(x - 2, y, x + 1, y);
            dc.drawLine(x + 1, y, x - 2, y + 6);
        } else if (iconType == :quality) {
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
            dc.drawCircle(x, y, 6);
            dc.drawLine(x - 3, y, x - 1, y + 3);
            dc.drawLine(x - 1, y + 3, x + 4, y - 3);
        } else {
            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
            dc.drawCircle(x, y + 3, 4);
            dc.drawLine(x, y - 7, x, y + 3);
            dc.drawLine(x - 2, y - 7, x + 2, y - 7);
        }
    }
}
