import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class FeedbackSummaryView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        var app = getApp();
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        // Connect IQ reports the drawable canvas, not the outer watch size.
        // Keep every round-watch layout inside a conservative circular safe
        // area so labels do not disappear behind the bezel.
        var compactLayout = width <= 450;
        var titleY = compactLayout ? 0.10 : 0.08;
        var scoreY = compactLayout ? 0.19 : 0.18;
        var scoreFont = compactLayout
            ? Graphics.FONT_MEDIUM
            : Graphics.FONT_LARGE;
        var subtitleY = compactLayout ? 0.27 : 0.27;
        var legendY = compactLayout ? 0.76 : 0.79;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        if (!app.hasFeedbackSummaryData()) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                centerX,
                height / 2,
                Graphics.FONT_SMALL,
                "No hidden-period data",
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
            return;
        }

        var score = app.getFeedbackHiddenPercentage();
        var stateColor = app.didHoldCadenceWhenHidden()
            ? Graphics.COLOR_GREEN
            : Graphics.COLOR_ORANGE;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            (height * titleY).toNumber(),
            Graphics.FONT_XTINY,
            "When hidden",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        dc.setColor(stateColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            (height * scoreY).toNumber(),
            scoreFont,
            score.toString() + "%",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            (height * subtitleY).toNumber(),
            Graphics.FONT_XTINY,
            "in target range",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        drawMetrics(dc, app, width, height);
        drawCadenceGraph(dc, app, stateColor, width, height);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            (height * legendY).toNumber(),
            Graphics.FONT_XTINY,
            "Shaded = feedback hidden",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function drawMetrics(dc as Dc, app, width as Number, height as Number) as Void {
        var heartRate = app.getAvgHeartRate();
        var distance = app.getSessionDistance();
        var heartRateText = heartRate == null ? "-- bpm" : heartRate.toString() + " bpm";
        var distanceText = distance == null
            ? "-- KM"
            : (distance / 1000.0).format("%.2f") + " KM";
        var compactLayout = width <= 450;
        var y = (height * (compactLayout ? 0.34 : 0.36)).toNumber();

        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            (width * 0.29).toNumber(),
            y,
            Graphics.FONT_XTINY,
            heartRateText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        dc.setColor(Graphics.COLOR_PURPLE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            (width * 0.71).toNumber(),
            y,
            Graphics.FONT_XTINY,
            distanceText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function drawCadenceGraph(
        dc as Dc,
        app as GarminApp,
        stateColor as Number,
        width as Number,
        height as Number
    ) as Void {
        var cadenceLog = app.getFeedbackCadenceLog();
        var hiddenLog = app.getFeedbackHiddenLog();
        var timeLog = app.getFeedbackTimeLog();
        var count = cadenceLog.size();

        if (count == 0) {
            return;
        }

        var compactLayout = width <= 450;
        var left = (width * (compactLayout ? 0.24 : 0.20)).toNumber();
        var right = (width * (compactLayout ? 0.76 : 0.80)).toNumber();
        var top = (height * (compactLayout ? 0.43 : 0.44)).toNumber();
        var bottom = (height * (compactLayout ? 0.63 : 0.66)).toNumber();
        var graphWidth = right - left;
        var graphHeight = bottom - top;
        var targetMin = app.getCalculatedMinCadence();
        var targetMax = app.getCalculatedMaxCadence();
        var graphMin = targetMin - 10;
        var graphMax = targetMax + 10;

        for (var i = 0; i < count; i++) {
            var cadence = cadenceLog[i];
            if (cadence != null) {
                if (cadence < graphMin) { graphMin = cadence; }
                if (cadence > graphMax) { graphMax = cadence; }
            }
        }

        if (graphMax <= graphMin) {
            graphMax = graphMin + 1;
        }

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(left, top, graphWidth, graphHeight);

        var bandTop = cadenceToY(targetMax, graphMin, graphMax, top, bottom);
        var bandBottom = cadenceToY(targetMin, graphMin, graphMax, top, bottom);
        dc.setColor(0x003300, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(left, bandTop, graphWidth, bandBottom - bandTop + 1);

        var sampleWidth = count > 1
            ? (graphWidth.toFloat() / (count - 1))
            : graphWidth.toFloat();

        dc.setColor(0x222222, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < count; i++) {
            if (hiddenLog[i]) {
                var shadedX = left + (i * sampleWidth).toNumber();
                var shadedWidth = sampleWidth.toNumber();
                if (shadedWidth < 1) { shadedWidth = 1; }
                dc.fillRectangle(shadedX, top, shadedWidth, graphHeight);
            }
        }

        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(left, bandTop, right, bandTop);
        dc.drawLine(left, bandBottom, right, bandBottom);

        dc.setColor(stateColor, Graphics.COLOR_TRANSPARENT);
        var previousX = -1;
        var previousY = -1;

        for (var i = 0; i < count; i++) {
            var cadence = cadenceLog[i];
            if (cadence == null) {
                previousX = -1;
                previousY = -1;
                continue;
            }

            var x = count > 1
                ? left + ((i * graphWidth) / (count - 1)).toNumber()
                : left;
            var y = cadenceToY(cadence, graphMin, graphMax, top, bottom);

            if (previousX >= 0 && previousY >= 0) {
                dc.drawLine(previousX, previousY, x, y);
            }

            previousX = x;
            previousY = y;
        }

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            left - 3,
            top,
            Graphics.FONT_XTINY,
            graphMax.toString(),
            Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.drawText(
            left - 3,
            bottom,
            Graphics.FONT_XTINY,
            graphMin.toString(),
            Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER
        );

        var firstMinute = timeLog[0] / 60.0;
        var lastMinute = timeLog[count - 1] / 60.0;
        dc.drawText(
            left,
            bottom + 2,
            Graphics.FONT_XTINY,
            firstMinute.format("%.0f"),
            Graphics.TEXT_JUSTIFY_LEFT
        );
        dc.drawText(
            right,
            bottom + 2,
            Graphics.FONT_XTINY,
            lastMinute.format("%.0f") + " min",
            Graphics.TEXT_JUSTIFY_RIGHT
        );
    }

    function cadenceToY(
        cadence,
        graphMin as Number,
        graphMax as Number,
        top as Number,
        bottom as Number
    ) as Number {
        var ratio = (cadence - graphMin).toFloat() / (graphMax - graphMin);
        return bottom - ((bottom - top) * ratio).toNumber();
    }
}
