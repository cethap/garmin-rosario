import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// Glance loop entry (164x62 on the Instinct 2): the day's mysteries on the first line and today's
// progress on the second, read from the progress the widget saves.
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

        // Two lines centered on the upper and lower halves; the system fonts are 23-24px tall.
        var justify = Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER;
        var h = dc.getHeight();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(0, h * 3 / 10, Graphics.FONT_TINY, Rosary.glanceTitle(set), justify);
        dc.drawText(0, h * 7 / 10, Graphics.FONT_SMALL, Rosary.glanceSummary(step), justify);
    }
}
