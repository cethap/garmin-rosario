import Toybox.Application;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

// Entry point. Annotated for the glance so the glance process can load it and read the progress.
(:glance)
class RosarioApp extends Application.AppBase {

    // Application.Storage keys: the current step and the YYYYMMDD date it belongs to.
    const STEP_KEY = "step";
    const DATE_KEY = "date";

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    // Full-screen widget, opened from the glance with START. The session keeps the date it was
    // opened on, so a rosary prayed across midnight is saved under the day of its mysteries.
    function getInitialView() as [Views] or [Views, InputDelegates] {
        var today = todayInfo();
        var dateKey = dateKeyOf(today);
        var view = new RosaryView(loadStep(dateKey), Rosary.mysterySetForWeekday(today.day_of_week as Number));
        return [view, new RosaryDelegate(view, dateKey)];
    }

    // Compact view shown in the glance loop.
    function getGlanceView() as [GlanceView] or [GlanceView, GlanceViewDelegate] or Null {
        return [new RosaryGlanceView()];
    }

    function todayInfo() as Gregorian.Info {
        return Gregorian.info(Time.now(), Time.FORMAT_SHORT);
    }

    function dateKeyOf(info as Gregorian.Info) as Number {
        return Rosary.dateKey(info.year as Number, info.month as Number, info.day as Number);
    }

    // Step saved for the given day, or 0 when the saved progress belongs to another day.
    function loadStep(dateKey as Number) as Number {
        return Rosary.restoreStep(Storage.getValue(STEP_KEY), Storage.getValue(DATE_KEY), dateKey);
    }

    function saveStep(step as Number, dateKey as Number) as Void {
        Storage.setValue(STEP_KEY, step);
        Storage.setValue(DATE_KEY, dateKey);
    }
}

(:glance)
function getApp() as RosarioApp {
    return Application.getApp() as RosarioApp;
}
