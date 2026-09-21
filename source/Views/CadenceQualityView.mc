import Toybox.Graphics;
import Toybox.WatchUi;

class CadenceQualityView extends WatchUi.View {

    private var _heartIcon;

    function initialize() {
        View.initialize();

        // Load the heart-rate icon already available in drawables
        _heartIcon = WatchUi.loadResource(
            Rez.Drawables.IconHeartRate
        );
    }


    function onLayout(dc as Dc) {
    }


    function onShow() {
    }


    function onUpdate(dc as Dc) {

        // Clear the screen
        dc.setColor(
            Graphics.COLOR_BLACK,
            Graphics.COLOR_BLACK
        );

        dc.clear();

        drawCadenceQualityScreen(dc);
    }


    function onHide() {
    }


    function drawCadenceQualityScreen(dc as Dc) {

        var screenW = dc.getWidth();
        var screenH = dc.getHeight();
        var centerX = screenW / 2;


        // =====================================================
        // ON TARGET SECTION
        // =====================================================

        dc.setColor(
            Graphics.COLOR_WHITE,
            Graphics.COLOR_TRANSPARENT
        );


        // On target percentage
        dc.drawText(
            centerX,
            (screenH * 0.045).toNumber(),
            Graphics.FONT_XTINY,
            "82%",
            Graphics.TEXT_JUSTIFY_CENTER
        );


        // On target label
        dc.drawText(
            centerX,
            (screenH * 0.095).toNumber(),
            Graphics.FONT_XTINY,
            "on target",
            Graphics.TEXT_JUSTIFY_CENTER
        );


        // =====================================================
        // DIVIDER LINE
        // =====================================================

        dc.setColor(
            Graphics.COLOR_LT_GRAY,
            Graphics.COLOR_TRANSPARENT
        );

        dc.setPenWidth(1);

        dc.drawLine(
            (screenW * 0.28).toNumber(),
            (screenH * 0.165).toNumber(),
            (screenW * 0.72).toNumber(),
            (screenH * 0.165).toNumber()
        );


        // =====================================================
        // LIVE CADENCE
        // =====================================================

        dc.setColor(
            Graphics.COLOR_BLUE,
            Graphics.COLOR_TRANSPARENT
        );


        // Current cadence
        dc.drawText(
            centerX,
            (screenH * 0.235).toNumber(),
            Graphics.FONT_LARGE,
            "148",
            Graphics.TEXT_JUSTIFY_CENTER
        );


        // SPM
        dc.setColor(
            Graphics.COLOR_WHITE,
            Graphics.COLOR_TRANSPARENT
        );

        dc.drawText(
            centerX,
            (screenH * 0.365).toNumber(),
            Graphics.FONT_XTINY,
            "SPM",
            Graphics.TEXT_JUSTIFY_CENTER
        );


        // Cadence status
        dc.setColor(
            Graphics.COLOR_BLUE,
            Graphics.COLOR_TRANSPARENT
        );

        dc.drawText(
            centerX,
            (screenH * 0.425).toNumber(),
            Graphics.FONT_XTINY,
            "in range",
            Graphics.TEXT_JUSTIFY_CENTER
        );


        // =====================================================
        // PROGRESS BAR
        // =====================================================

        var barY =
            (screenH * 0.545).toNumber();

        var barStart =
            (screenW * 0.17).toNumber();

        var barEnd =
            (screenW * 0.83).toNumber();


        // Grey background bar
        dc.setColor(
            Graphics.COLOR_LT_GRAY,
            Graphics.COLOR_TRANSPARENT
        );

        dc.setPenWidth(4);

        dc.drawLine(
            barStart,
            barY,
            barEnd,
            barY
        );

        dc.setPenWidth(1);


        // =====================================================
        // TARGET RANGE BOX
        // =====================================================

        var targetX =
            (screenW * 0.40).toNumber();

        var targetY =
            (screenH * 0.525).toNumber();

        var targetWidth =
            (screenW * 0.25).toNumber();

        var targetHeight =
            (screenH * 0.055).toNumber();


        dc.setColor(
            Graphics.COLOR_WHITE,
            Graphics.COLOR_WHITE
        );

        dc.fillRoundedRectangle(
            targetX,
            targetY,
            targetWidth,
            targetHeight,
            7
        );


        // =====================================================
        // CURRENT CADENCE MARKER
        // =====================================================

        dc.setColor(
            Graphics.COLOR_GREEN,
            Graphics.COLOR_GREEN
        );

        dc.fillRectangle(
            (screenW * 0.497).toNumber(),
            (screenH * 0.505).toNumber(),
            3,
            (screenH * 0.095).toNumber()
        );


        // =====================================================
        // TARGET RANGE VALUES
        // =====================================================

        dc.setColor(
            Graphics.COLOR_WHITE,
            Graphics.COLOR_TRANSPARENT
        );


        // Minimum cadence
        dc.drawText(
            (screenW * 0.40).toNumber(),
            (screenH * 0.600).toNumber(),
            Graphics.FONT_XTINY,
            "140",
            Graphics.TEXT_JUSTIFY_CENTER
        );


        // Maximum cadence
        dc.drawText(
            (screenW * 0.65).toNumber(),
            (screenH * 0.600).toNumber(),
            Graphics.FONT_XTINY,
            "160",
            Graphics.TEXT_JUSTIFY_CENTER
        );


        // =====================================================
        // HEART RATE
        // =====================================================

        // Existing heart-rate icon
        if (_heartIcon != null) {

            dc.drawBitmap(
                (screenW * 0.20).toNumber(),
                (screenH * 0.690).toNumber(),
                _heartIcon
            );
        }


        // Heart-rate placeholder
        dc.setColor(
            Graphics.COLOR_RED,
            Graphics.COLOR_TRANSPARENT
        );

        dc.drawText(
            (screenW * 0.34).toNumber(),
            (screenH * 0.705).toNumber(),
            Graphics.FONT_XTINY,
            "--",
            Graphics.TEXT_JUSTIFY_CENTER
        );


        // =====================================================
        // DISTANCE
        // =====================================================

        dc.setColor(
            Graphics.COLOR_PURPLE,
            Graphics.COLOR_TRANSPARENT
        );

        dc.drawText(
            (screenW * 0.72).toNumber(),
            (screenH * 0.705).toNumber(),
            Graphics.FONT_XTINY,
            "-- KM",
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }
}