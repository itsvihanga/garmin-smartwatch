import Toybox.Lang;

// Converts captured workout values into strings that are safe to render.
// Activity data is nullable, and elapsedDistance is reported in metres.
module SummaryFormatter {
    const MISSING_VALUE = "--";

    function formatDuration(duration) as String {
        if (duration == null || duration <= 0) {
            return MISSING_VALUE;
        }

        var wholeSeconds = (duration / 1000.0).toNumber();
        if (wholeSeconds <= 0) {
            return MISSING_VALUE;
        }

        var hours = wholeSeconds / 3600;
        var minutes = (wholeSeconds % 3600) / 60;
        var seconds = wholeSeconds % 60;

        return hours.format("%02d") + ":" +
               minutes.format("%02d") + ":" +
               seconds.format("%02d");
    }

    function formatDistance(distance) as String {
        if (distance == null || distance <= 0) {
            return MISSING_VALUE;
        }

        return (distance / 1000.0).format("%.2f") + " km";
    }

    function formatAveragePace(duration, distance) as String {
        if (duration == null || distance == null || duration <= 0 || distance <= 0) {
            return MISSING_VALUE;
        }

        var totalSeconds = duration / 1000.0;
        var distanceKm = distance / 1000.0;
        if (totalSeconds <= 0.0 || distanceKm <= 0.0) {
            return MISSING_VALUE;
        }

        // Monkey C modulo requires a Number/Long. Convert the complete Float
        // pace to whole seconds before calculating its minute/second parts.
        var wholePaceSeconds = (totalSeconds / distanceKm).toNumber();
        if (wholePaceSeconds <= 0) {
            return MISSING_VALUE;
        }

        var minutes = wholePaceSeconds / 60;
        var seconds = wholePaceSeconds % 60;
        return minutes.format("%d") + ":" + seconds.format("%02d") + " /km";
    }

    function formatCadence(cadence) as String {
        if (cadence == null || cadence <= 0) {
            return MISSING_VALUE;
        }

        return cadence.format("%.0f") + " spm";
    }

    function formatHeartRate(heartRate) as String {
        if (heartRate == null || heartRate <= 0) {
            return MISSING_VALUE;
        }

        return heartRate.format("%d") + " bpm";
    }

    function formatCadenceQuality(quality) as String {
        if (quality == null || quality < 0) {
            return MISSING_VALUE;
        }

        return quality.format("%.0f") + "%";
    }

    function formatTemperature(temperature) as String {
        if (temperature == null) {
            return MISSING_VALUE;
        }

        return temperature.format("%.1f") + " C";
    }
}
