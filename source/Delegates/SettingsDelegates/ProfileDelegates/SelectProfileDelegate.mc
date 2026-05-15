import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Graphics;

class SelectProfileDelegate extends WatchUi.Menu2InputDelegate { 

    private var _menu as WatchUi.Menu2;

    function initialize(menu as WatchUi.Menu2) {
        Menu2InputDelegate.initialize();
        _menu = menu;
        
        // 1. REVERT TITLE: Remove the speed from here
        _menu.setTitle("Profile Settings"); 
    }

    function onSelect(item) as Void {

        var id = item.getId();

        //displays the menu for the selected item
        if (id == :profile_height){
            heightPicker();
        } 
        else if (id == :profile_speed){
            speedPicker();
        } 
        else if (id == :profile_experience){
            experienceMenu();
        } 
        else if (id == :profile_gender){
            genderMenu();
        }
    }

    function onMenuItem(item as Symbol) as Void {}

    // Returns back one menu
    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT); 
    }

    function heightPicker() as Void {
        var app = Application.getApp();
        var currentHeight = app.getUserHeight();

        var factory = new ProfilePickerFactory(100, 250, 1, {:label=>" cm"});

        var picker = new WatchUi.Picker({
            :title => new WatchUi.Text({:text=>"Set Height", :locX=>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_BOTTOM, :color=>Graphics.COLOR_WHITE}),
            :pattern => [factory],
            :defaults => [factory.getIndex(currentHeight)]
        });

        WatchUi.pushView(picker, new ProfilePickerDelegate(:prof_height), WatchUi.SLIDE_LEFT);

    }

    function speedPicker() as Void {
    // 1. Get the real app instance and the saved speed
    var app = Application.getApp() as GarminApp;
    var currentSpeed = app._userSpeed;

    // 2. Safety Check: If the app just installed and storage is empty
    if (currentSpeed == null) { 
        currentSpeed = 10; 
    }

    // 3. Initialize the factory with your range (5 to 30)
    // Note: Ensure your factory constructor saves 5 as '_start' and 1 as '_increment'
    var factory = new ProfilePickerFactory(5, 30, 1, {:label=>" km/h"});

    var picker = new WatchUi.Picker({
        :title => new WatchUi.Text({
            :text=>"Set Speed", 
            :locX=>WatchUi.LAYOUT_HALIGN_CENTER, 
            :locY=>WatchUi.LAYOUT_VALIGN_BOTTOM, 
            :color=>Graphics.COLOR_WHITE
        }),
        :pattern => [factory],
        // 4. CALL YOUR GETINDEX: This maps '17' to the correct scroll position
        :defaults => [factory.getIndex(currentSpeed)]
    });

    WatchUi.pushView(picker, new ProfilePickerDelegate(:prof_speed), WatchUi.SLIDE_LEFT);
    }

    function experienceMenu() as Void {
        var menu = new WatchUi.Menu2({
            :title => "Set Experience"
        });

        menu.addItem(new WatchUi.MenuItem("Beginner", null, :exp_beginner, null));
        menu.addItem(new WatchUi.MenuItem("Intermediate", null, :exp_intermediate, null));
        menu.addItem(new WatchUi.MenuItem("Advanced", null, :exp_advanced, null));

        //pushes the view to the screen with the relevent delegate
        WatchUi.pushView(menu, new SelectExperienceDelegate(menu), WatchUi.SLIDE_LEFT);
    }

    function genderMenu() as Void {
        var menu = new WatchUi.Menu2({
            :title => "Set Gender"
        });

        menu.addItem(new WatchUi.MenuItem("Male", null, :user_male, null));
        menu.addItem(new WatchUi.MenuItem("Female", null, :user_female, null));
        menu.addItem(new WatchUi.MenuItem("Other", null, :user_other, null));

        //pushes the view to the screen with the relevent delegate
        WatchUi.pushView(menu, new SelectGenderDelegate(menu), WatchUi.SLIDE_LEFT);
    }

}