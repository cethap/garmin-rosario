import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// Glance loop entry (164x62 on the Instinct 2): the day's mysteries on the first line and today's
// progress on the second, read from the progress the widget saves. Layout.glancePlan places them.
(:glance)
class RosaryGlanceView extends WatchUi.GlanceView {

    function initialize() {
        GlanceView.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        var app = getApp();
        var today = app.todayInfo();
        var set = Rosary.mysterySetForWeekday(today.day_of_week as Number);
        var step = app.loadStep(app.dateKeyOf(today));

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var items = Layout.glancePlan(set, step, dc.getHeight());
        for (var i = 0; i < items.size(); i++) {
            items[i].draw(dc);
        }
    }
}
