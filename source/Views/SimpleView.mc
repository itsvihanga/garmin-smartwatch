import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Activity;
import Toybox.Lang;
import Toybox.System;

class SimpleView extends WatchUi.View {

    // UI Drawables
    private var _cadenceDisplay;
    private var _cadenceZoneDisplay;
    private var _heartrateDisplay;
    private var _distanceDisplay;
    private var _timeDisplay;
    private var _paceDisplay;

    function initialize() {
        WatchUi.View.initialize();
    }
    
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
        
        // Link UI variables to layout IDs
        _cadenceDisplay = findDrawableById("cadence_text");
        _cadenceZoneDisplay = findDrawableById("cadence_zone");
        _heartrateDisplay = findDrawableById("heartrate_text");
        _distanceDisplay = findDrawableById("distance_text"); // Restored
        _timeDisplay = findDrawableById("time_text");
        _paceDisplay = findDrawableById("pace_text"); 

        var _spmLabel = findDrawableById("spm_label") as WatchUi.Text;
        if (_spmLabel != null) { _spmLabel.setText("SPM"); }
    }

    function onShow() as Void {
        var app = Application.getApp() as GarminApp;
        app.startRefreshTimer(self, "simple_view", method(:refreshScreen));
    }

    function onHide() as Void {
        var app = Application.getApp() as GarminApp;
        app.stopRefreshTimer(self, "simple_view");
    }

    // --- Logic Loop (The "Heartbeat") ---
    function refreshScreen() as Void {
        // Cadence sampling and zone alerts are handled centrally by
        // GarminApp.handleRefreshTick(), so they keep running even when this
        // view isn't the one currently visible.
        WatchUi.requestUpdate();
    }

    // --- Drawing Loop (The "Face") ---
    function onUpdate(dc as Dc) as Void {
        updateDisplayStrings();

        View.onUpdate(dc);
        drawDividers(dc);

        drawRecordingIndicator(dc);
    }

    function updateDisplayStrings() as Void {
        var info = Activity.getActivityInfo();
        var app = Application.getApp();
        
        // Cadence
        if (_cadenceDisplay != null) {
            _cadenceDisplay.setText(info != null && info.currentCadence != null ? info.currentCadence.toString() : "--");
        }

        // Zone Info
        if (_cadenceZoneDisplay != null) {
            var min = app.getCalculatedMinCadence();
            var max = app.getCalculatedMaxCadence();
            _cadenceZoneDisplay.setText("(" + min + "-" + max + ")");
        }

        // Heartrate
        if (_heartrateDisplay != null) {
            _heartrateDisplay.setText(info != null && info.currentHeartRate != null ? info.currentHeartRate.toString() : "--");
        }

        // --- DISTANCE (RESTORED) ---
        if (_distanceDisplay != null) {
            if (info != null && info.elapsedDistance != null) {
                var distanceKm = info.elapsedDistance / 1000.0; // Meters to Kilometers
                _distanceDisplay.setText(distanceKm.format("%.2f") + " KM");
            } else {
                _distanceDisplay.setText("-- KM");
            }
        }

        // Time
        if (_timeDisplay != null && info != null && info.timerTime != null) {
            var s = info.timerTime / 1000;
            _timeDisplay.setText((s/3600).format("%02d") + ":" + ((s%3600)/60).format("%02d") + ":" + (s%60).format("%02d"));
        }
        
        // Pace
        if (_paceDisplay != null && info != null && info.currentSpeed != null && info.currentSpeed > 0) {
            var pace = (1000.0 / info.currentSpeed).toNumber();
            _paceDisplay.setText((pace/60).format("%d") + ":" + (pace%60).format("%02d") + " min/km");
        } else if (_paceDisplay != null) {
            _paceDisplay.setText("--:-- min/km");
        }
    }

    // --- Helpers ---
    function drawRecordingIndicator(dc as Dc) as Void {
        var app = Application.getApp();
        if (app.isActivityRecording()) {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(dc.getWidth() - 15, 15, 8);
        }

        drawVibrationModeIndicator(dc);
    }

    function drawVibrationModeIndicator(dc as Dc) as Void {
    var app = Application.getApp();
    var vibrationOn = app.getVibrationEnabled();

    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);

    if (vibrationOn) {
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() - 30,
            Graphics.FONT_XTINY,
            "VIB ON",
            Graphics.TEXT_JUSTIFY_CENTER
        );
    } else {
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() - 30,
            Graphics.FONT_XTINY,
            "VIB OFF",
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }
}

    function drawDividers(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(20, h * 0.22, w - 20, h * 0.22);
        dc.drawLine(20, h * 0.43, w - 20, h * 0.43);
        dc.drawLine(20, h * 0.60, w - 20, h * 0.60);
        dc.drawLine(20, h * 0.78, w - 20, h * 0.78);
    }
}
