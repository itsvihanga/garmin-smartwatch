import Toybox.Application;
import Toybox.Graphics;
import Toybox.WatchUi;

class SummaryPromptView extends WatchUi.View {

    private var _selectedOption = 0; // 0 = Yes, 1 = No

    function initialize() {
        View.initialize();

        var app = Application.getApp() as GarminApp;
        _selectedOption = app.getSummaryEnabled() ? 0 : 1;
    }

    function setSelectedOption(value) {
        _selectedOption = value;
    }

    function getSelectedOption() {
        return _selectedOption;
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var centerY = height / 2;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, centerY - 82, Graphics.FONT_MEDIUM, "Do you", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(centerX, centerY - 44, Graphics.FONT_MEDIUM, "want to view", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(centerX, centerY - 6, Graphics.FONT_MEDIUM, "summary?", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        drawButton(dc, centerX - 70, centerY + 58, 104, 40, "YES", _selectedOption == 0);
        drawButton(dc, centerX + 70, centerY + 58, 104, 40, "NO", _selectedOption == 1);
    }

    function drawButton(dc, centerX, centerY, buttonWidth, buttonHeight, label, selected) {
        var x = centerX - (buttonWidth / 2);
        var y = centerY - (buttonHeight / 2);

        if (selected) {
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_GREEN);
        } else {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_LT_GRAY);
        }

        dc.fillRectangle(x, y, buttonWidth, buttonHeight);

        dc.setColor(selected ? Graphics.COLOR_BLACK : Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, centerY, Graphics.FONT_SMALL, label, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}
