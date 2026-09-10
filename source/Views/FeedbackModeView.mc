import Toybox.Graphics;
import Toybox.Timer;
import Toybox.WatchUi;

class FeedbackModeView extends WatchUi.View {

    const AUTO_RETURN_DELAY_MS = 5000;

    private var _returnTimer = null;

    function initialize() {
        View.initialize();
    }

    function onShow() as Void {
        stopReturnTimer();
        _returnTimer = new Timer.Timer();
        _returnTimer.start(method(:returnToMainScreen), AUTO_RETURN_DELAY_MS, false);
    }

    function onHide() as Void {
        stopReturnTimer();
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            dc.getWidth() / 2,
            (dc.getHeight() * 0.45).toNumber(),
            Graphics.FONT_MEDIUM,
            "Feedback Mode",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            dc.getWidth() / 2,
            (dc.getHeight() * 0.60).toNumber(),
            Graphics.FONT_XTINY,
            "Testing",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function returnToMainScreen() as Void {
        _returnTimer = null;
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    function stopReturnTimer() as Void {
        if (_returnTimer != null) {
            _returnTimer.stop();
            _returnTimer = null;
        }
    }
}
