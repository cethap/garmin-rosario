import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// Glance loop entry (164x62 on the Instinct 2): the day's mysteries over today's progress, read from the
// progress the widget saves, as one block in the medium font. Layout.glancePlan places them.
(:glance)
class RosaryGlanceView extends WatchUi.GlanceView {

    function initialize() {
        GlanceView.initialize();
    }

    // Resolves the language again on each refresh, so the glance follows a new choice in the widget and a
    // new watch language.
    function onUpdate(dc as Dc) as Void {
        I18n.reset();
        var app = getApp();
        var today = app.todayInfo();
        var set = Rosary.mysterySetForWeekday(today.day_of_week as Number);
        var position = app.loadProgress(app.dateKeyOf(today));

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var items = Layout.glancePlan(set, position, dc.getHeight());
        for (var i = 0; i < items.size(); i++) {
            items[i].draw(dc);
        }
    }
}
