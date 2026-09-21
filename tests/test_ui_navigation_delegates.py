import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DELEGATES = ROOT / "source" / "Delegates"
SETTINGS = DELEGATES / "SettingsDelegates"
SETTINGS_RING = SETTINGS / "SettingsMenuDelegates"


def source(path):
    return path.read_text(encoding="utf-8")


def method(text, name, next_name=None):
    start = text.index(f"function {name}(")
    if next_name is None:
        return text[start:]
    end = text.index(f"function {next_name}(", start)
    return text[start:end]


class UiNavigationDelegateTests(unittest.TestCase):
    def test_main_view_stacks_settings_and_preserves_back_long_press(self):
        text = source(DELEGATES / "SimpleViewDelegate.mc")

        settings = method(text, "pushSettingsView", "setMenuActive")
        self.assertIn("WatchUi.pushView(new SettingsView()", settings)
        self.assertNotIn("WatchUi.switchToView", settings)

        on_back = method(text, "onBack")
        self.assertIn("return true;", on_back)
        self.assertIn("triggerBackLongPress", text)
        self.assertIn("openFeedbackMode", text)

    def test_main_and_advanced_swipes_match_gesture_direction(self):
        simple = method(source(DELEGATES / "SimpleViewDelegate.mc"), "onSwipe", "showActivityControlMenu")
        self.assertIn("WatchUi.SWIPE_UP", simple)
        self.assertIn("WatchUi.SLIDE_UP", simple)
        self.assertIn("WatchUi.SWIPE_DOWN", simple)
        self.assertIn("WatchUi.SLIDE_DOWN", simple)

        advanced_text = source(DELEGATES / "AdvancedViewDelegate.mc")
        advanced = method(advanced_text, "onSwipe", "onBack")
        self.assertIn("WatchUi.popView(WatchUi.SLIDE_UP)", advanced)
        self.assertIn("WatchUi.popView(WatchUi.SLIDE_DOWN)", advanced)
        self.assertIn(
            "WatchUi.popView(WatchUi.SLIDE_DOWN)",
            method(advanced_text, "pushSimpleView"),
        )

    def test_settings_entry_is_stacked_and_back_unstacks_it(self):
        text = source(SETTINGS / "SettingsMenuDelegate.mc")

        self.assertIn("WatchUi.popView(WatchUi.SLIDE_DOWN)", method(text, "onBack", "onSelect"))
        for name, next_name in (
            ("onSelect", "onNextPage"),
            ("onNextPage", "onPreviousPage"),
        ):
            self.assertIn("WatchUi.pushView", method(text, name, next_name))
        self.assertIn("WatchUi.pushView", method(text, "onPreviousPage"))

    def test_settings_ring_replaces_cards_instead_of_growing_stack(self):
        cases = (
            ("CadenceSettingsMenuDelegate.mc", "onNextPage", "onPreviousPage"),
            ("CadenceSettingsMenuDelegate.mc", "onPreviousPage", None),
            ("ProfileSettingsMenuDelegate.mc", "onNextPage", "onPreviousPage"),
            ("ProfileSettingsMenuDelegate.mc", "onPreviousPage", "pushProfileMenu"),
            ("SummarySettingsMenuDelegate.mc", "handleUp", "handleDown"),
            ("SummarySettingsMenuDelegate.mc", "handleDown", "onKey"),
            ("BarChartSettingsMenuDelegate.mc", "onNextPage", "onPreviousPage"),
            ("BarChartSettingsMenuDelegate.mc", "onPreviousPage", "pushBarChartMenu"),
            ("ResetSettingsDelegate.mc", "handleUp", "handleDown"),
            ("ResetSettingsDelegate.mc", "handleDown", "onBack"),
        )

        for filename, name, next_name in cases:
            with self.subTest(filename=filename, method=name):
                body = method(source(SETTINGS_RING / filename), name, next_name)
                self.assertIn("WatchUi.switchToView", body)

    def test_settings_cards_pop_back_to_settings_root(self):
        for filename in (
            "CadenceSettingsMenuDelegate.mc",
            "ProfileSettingsMenuDelegate.mc",
            "BarChartSettingsMenuDelegate.mc",
        ):
            with self.subTest(filename=filename):
                text = source(SETTINGS_RING / filename)
                self.assertIn("WatchUi.popView(WatchUi.SLIDE_DOWN)", method(text, "onBack", "onSelect"))

        summary = source(SETTINGS_RING / "SummarySettingsMenuDelegate.mc")
        self.assertIn("WatchUi.popView(WatchUi.SLIDE_DOWN)", method(summary, "onBack", "handleUp"))


if __name__ == "__main__":
    unittest.main()
