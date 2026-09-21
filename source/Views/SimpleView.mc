import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Activity;
import Toybox.Lang;
import Toybox.Timer;

class SimpleView extends WatchUi.View {

    const MAIN_VIBRATION_ICON_SIZE = 34;
    const MAIN_VIBRATION_ICON_BOTTOM_MARGIN = 0.05;

    // UI Drawables
    private var _cadenceDisplay;
    private var _cadencePercentDisplay;
    private var _cadenceZoneDisplay;
    private var _cadenceRangeDisplay;
    private var _heartrateDisplay;
    private var _distanceDisplay;
    private var _timeDisplay;
    private var _paceDisplay;
    private var _paceIcon;
    private var _heartRateIcon;
    private var _vibrationOnIcon;
    private var _vibrationOffIcon;
    
    // Logic & Timer Variables
    private var _refreshTimer;
    function initialize() {
        WatchUi.View.initialize();
    }
    
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
        
        // Link UI variables to layout IDs
        _cadenceDisplay = findDrawableById("cadence_text");
        _cadencePercentDisplay = findDrawableById("cadence_percent");
        _cadenceZoneDisplay = findDrawableById("cadence_zone");
        _cadenceRangeDisplay = findDrawableById("cadence_range");
        _heartrateDisplay = findDrawableById("heartrate_text");
        _distanceDisplay = findDrawableById("distance_text"); // Restored
        _timeDisplay = findDrawableById("time_text");
        _paceDisplay = findDrawableById("pace_text");
        _paceIcon = WatchUi.loadResource(Rez.Drawables.PaceIcon);
        _heartRateIcon = WatchUi.loadResource(Rez.Drawables.MainHeartRateIcon);
        _vibrationOnIcon = WatchUi.loadResource(Rez.Drawables.MainVibrationOnIcon);
        _vibrationOffIcon = WatchUi.loadResource(Rez.Drawables.MainVibrationOffIcon);

    }

    function onShow() as Void {
        // Start the logic loop and keep it alive across views
        if (_refreshTimer == null) {
            _refreshTimer = new Timer.Timer();
            _refreshTimer.start(method(:refreshScreen), 1000, true);
        }
    }

    function onHide() as Void {
// CRITICAL: Stop the timer to prevent "Timer Limit" crashes
        if (_refreshTimer != null) {
            _refreshTimer.stop();
            _refreshTimer = null;
        }
    }

// --- Logic Loop (The "Heartbeat") ---
    function refreshScreen() as Void {
        var app = Application.getApp();
        
        // Pause freeze: stop all runtime calculations while not recording.
        // This freezes cadence processing and vibration alerts until Resume.
        if (!app.isRecording()) {
            WatchUi.requestUpdate();
            return;
        }

        if (app.isFeedbackHidden()) {
            // Hidden windows still record cadence in GarminApp, but all cadence
            // guidance is suppressed here. The app timer owns cadence alerts,
            // so there is no second view-level alert to cancel or duplicate.
            WatchUi.requestUpdate();
            return;
        }

        // Cadence sampling and alerting are centralized in GarminApp so they
        // remain stable when this view is covered by menus or other screens.
        WatchUi.requestUpdate();
    }

    // --- Drawing Loop (The "Face") ---
    function onUpdate(dc as Dc) as Void {
        var app = Application.getApp();

        if (app.isFeedbackHidden()) {
            drawFeedbackHiddenIndicator(dc, app);
            return;
        }

        updateDisplayStrings();

        // Layout labels do not erase their previous pixels on every device.
        // Clear first so changing values never ghost or overlap one another.
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        View.onUpdate(dc); 
        drawHeartRateIcon(dc);
        drawPaceIcon(dc);
        drawDividers(dc);
        drawVibrationStatusIcon(dc);
        drawRecordingIndicator(dc);
    }

    function drawFeedbackHiddenIndicator(dc as Dc, app) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            (height * 0.36).toNumber(),
            Graphics.FONT_MEDIUM,
            "FEEDBACK",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.drawText(
            centerX,
            (height * 0.48).toNumber(),
            Graphics.FONT_MEDIUM,
            "HIDDEN",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            (height * 0.61).toNumber(),
            Graphics.FONT_XTINY,
            app.isPaused() ? "Paused - feedback stays hidden" : "Cadence is still recording",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        var activeDots = (app.getFeedbackActiveSeconds() % 3) + 1;
        var dotRadius = (width * 0.012).toNumber();
        if (dotRadius < 2) { dotRadius = 2; }
        var dotGap = (width * 0.075).toNumber();
        var firstDotX = centerX - dotGap;
        var dotY = (height * 0.72).toNumber();

        for (var i = 0; i < 3; i++) {
            dc.setColor(
                i < activeDots ? Graphics.COLOR_GREEN : Graphics.COLOR_DK_GRAY,
                Graphics.COLOR_TRANSPARENT
            );
            dc.fillCircle(firstDotX + (i * dotGap), dotY, dotRadius);
        }
    }

    function updateDisplayStrings() as Void {
        var info = Activity.getActivityInfo();
        
        var app = Application.getApp();
        var minCadence = app.getCalculatedMinCadence();
        var maxCadence = app.getCalculatedMaxCadence();
        var cadence = info != null ? info.currentCadence : null;

        // Cadence and its live quality score.
        if (_cadenceDisplay != null) {
            _cadenceDisplay.setText(cadence != null ? cadence.toString() + " SPM" : "-- SPM");
        }

        if (_cadencePercentDisplay != null) {
            var cadenceQuality = app.computeCadenceQualityScore();
            _cadencePercentDisplay.setText((cadenceQuality < 0 ? 0 : cadenceQuality).toString() + "%");
        }

        if (_cadenceZoneDisplay != null) {
            var zoneText = "in range";
            if (cadence != null && cadence < minCadence) {
                zoneText = "below";
            } else if (cadence != null && cadence > maxCadence) {
                zoneText = "above";
            }
            _cadenceZoneDisplay.setText(zoneText);
        }

        if (_cadenceRangeDisplay != null) {
            _cadenceRangeDisplay.setText(
                minCadence.toString() + "-" + maxCadence.toString() + " spm"
            );
        }

        // Heartrate
        if (_heartrateDisplay != null) {
            _heartrateDisplay.setText(info != null && info.currentHeartRate != null ? info.currentHeartRate.toString() : "--");
        }

        // Distance
        if (_distanceDisplay != null) {
            if (info != null && info.elapsedDistance != null) {
                var distanceKm = info.elapsedDistance / 1000.0; // Meters to Kilometers
                _distanceDisplay.setText(distanceKm.format("%.2f") + " KM");
            } else {
                _distanceDisplay.setText("-- KM");
            }
        }

        // Time
        if (_timeDisplay != null) {
            if (info != null && info.timerTime != null) {
                var s = info.timerTime / 1000;
                _timeDisplay.setText((s/3600).format("%02d") + ":" + ((s%3600)/60).format("%02d") + ":" + (s%60).format("%02d"));
            } else {
                _timeDisplay.setText("00:00:00");
            }
        }
        
        // Pace uses the average of up to five most recent active seconds.
        if (_paceDisplay != null) {
            var averageSpeed = Application.getApp().getAverageRecentSpeed();

            if (averageSpeed != null && averageSpeed > 0) {
                var pace = (1000.0 / averageSpeed).toNumber();
                _paceDisplay.setText(
                    (pace / 60).format("%d") + ":" +
                    (pace % 60).format("%02d") + " min/km"
                );
            } else {
                _paceDisplay.setText("--:-- min/km");
            }
        }
    }

    function drawRecordingIndicator(dc as Dc) as Void {
        var app = Application.getApp();
        if (app.isActivityRecording()) {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle((dc.getWidth() * 0.82).toNumber(), (dc.getHeight() * 0.12).toNumber(), 6);
        }
    }

    function drawPaceIcon(dc as Dc) as Void {
        if (_paceIcon == null) { return; }

        dc.drawBitmap(
            (dc.getWidth() * 0.17).toNumber(),
            (dc.getHeight() * 0.70).toNumber(),
            _paceIcon
        );
    }

    function drawHeartRateIcon(dc as Dc) as Void {
        if (_heartRateIcon == null) { return; }

        // Align the icon's visual centre with the heart-rate text baseline.
        dc.drawBitmap(
            (dc.getWidth() * 0.15).toNumber(),
            (dc.getHeight() * 0.50).toNumber(),
            _heartRateIcon
        );
    }

    function drawVibrationStatusIcon(dc as Dc) as Void {
        var app = Application.getApp();
        var icon = app.getVibrationEnabled() ? _vibrationOnIcon : _vibrationOffIcon;
        if (icon == null) { return; }

        // The x position is derived from the screen width so the icon remains
        // centred across every supported round watch size.
        var x = ((dc.getWidth() - MAIN_VIBRATION_ICON_SIZE) / 2).toNumber();
        var bottomMargin = (dc.getHeight() * MAIN_VIBRATION_ICON_BOTTOM_MARGIN).toNumber();
        var y = dc.getHeight() - MAIN_VIBRATION_ICON_SIZE - bottomMargin;

        dc.drawBitmap(x, y, icon);
    }

    function drawDividers(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        var inset = (w * 0.10).toNumber();
        dc.drawLine(inset, (h * 0.23).toNumber(), w - inset, (h * 0.23).toNumber());
        dc.drawLine(inset, (h * 0.48).toNumber(), w - inset, (h * 0.48).toNumber());
        dc.drawLine(inset, (h * 0.63).toNumber(), w - inset, (h * 0.63).toNumber());
    }
}
