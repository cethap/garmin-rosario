import Toybox.Application;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

// Entry point. Annotated for the glance so the glance process can load it and read the progress.
(:glance)
class RosarioApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    // Full-screen widget, opened from the glance with START. The session keeps the date it was
    // opened on, so a rosary prayed across midnight is saved under the day of its mysteries. Opening
    // saves nothing: a day only counts as started once a bead moves.
    function getInitialView() as [Views] or [Views, InputDelegates] {
        var today = todayInfo();
        var dateKey = dateKeyOf(today);
        var position = loadProgress(dateKey);
        if (position == Rosary.NOT_STARTED) {
            position = 0;
        }
        var view = new RosaryView(position, Rosary.mysterySetForWeekday(today.day_of_week as Number));
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

    // Position saved for the given day (0..Rosary.DONE), or Rosary.NOT_STARTED.
    function loadProgress(dateKey as Number) as Number {
        return Rosary.decodeProgress(Storage.getValue(Rosary.PROGRESS_KEY), dateKey);
    }

    // One write, so the position never detaches from its day.
    function saveProgress(position as Number, dateKey as Number) as Void {
        Storage.setValue(Rosary.PROGRESS_KEY, Rosary.encodeProgress(dateKey, position) as Array<Application.PropertyValueType>);
    }
}

(:glance)
function getApp() as RosarioApp {
    return Application.getApp() as RosarioApp;
}
