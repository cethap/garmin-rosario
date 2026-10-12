import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

// Entry point. Annotated for the glance so the glance process can load it too.
(:glance)
class RosarioApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    // Full-screen widget, opened from the glance with START.
    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [new RosaryView(), new RosaryDelegate()];
    }

    // Compact view shown in the glance loop.
    function getGlanceView() as [GlanceView] or [GlanceView, GlanceViewDelegate] or Null {
        return [new RosaryGlanceView()];
    }
}

(:glance)
function getApp() as RosarioApp {
    return Application.getApp() as RosarioApp;
}
