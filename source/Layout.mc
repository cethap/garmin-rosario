import Toybox.Graphics;
import Toybox.Lang;

// Text layout shared by the views and the layout tests: each view asks for a plan (the text items it
// draws) and draws it, so the tests can measure the very same items against the visible area.
(:glance)
module Layout {

    // Instinct 2 screen: 176x176.
    const SCREEN_SIZE = 176;
    // Height of the glance content area in the selected slot of the glance loop (164x62 at 9,19).
    const GLANCE_HEIGHT = 62;
    // Glance text: two tiny lines at the bottom of the slot, sharing a left indent. The subscreen
    // lens takes the top right of the slot, so the first line sits low enough to clear it; the indent
    // keeps both lines off the round edge on the left (see LayoutTests.mc for the measured limits).
    const GLANCE_LEFT = 7;
    const GLANCE_PITCH = 17;

    // One piece of text a view draws, with the arguments Dc.drawText takes.
    class TextItem {
        var text as String;
        var font as Graphics.FontType;
        var x as Number;
        var y as Number;
        var justify as Number;

        function initialize(text as String, font as Graphics.FontType, x as Number, y as Number, justify as Number) {
            self.text = text;
            self.font = font;
            self.x = x;
            self.y = y;
            self.justify = justify;
        }

        function draw(dc as Dc) as Void {
            dc.drawText(x, y, font, text, justify);
        }
    }

    // Glance: the day's mysteries over today's progress, bottom-aligned in a slot of the given height.
    function glancePlan(set as Rosary.MysterySet, step as Number, height as Number) as Array<TextItem> {
        var font = Graphics.FONT_TINY;
        var bottomLine = height - Graphics.getFontHeight(font);
        var justify = Graphics.TEXT_JUSTIFY_LEFT as Number;
        return [
            new TextItem(Rosary.glanceTitle(set), font, GLANCE_LEFT, bottomLine - GLANCE_PITCH, justify),
            new TextItem(Rosary.glanceSummary(step), font, GLANCE_LEFT, bottomLine, justify)
        ] as Array<TextItem>;
    }

    // Box [left, top, right, bottom] that text of the given measured size covers when drawn as the
    // item says. Centered text may fall on half pixels, so the box is in Floats.
    function textBox(item as TextItem, width as Number, height as Number) as Array<Float> {
        var left = item.x.toFloat();
        var horizontal = item.justify & 3;
        if (horizontal == Graphics.TEXT_JUSTIFY_CENTER) {
            left -= width / 2.0;
        } else if (horizontal == Graphics.TEXT_JUSTIFY_RIGHT) {
            left -= width;
        }
        var top = item.y.toFloat();
        if ((item.justify & Graphics.TEXT_JUSTIFY_VCENTER) != 0) {
            top -= height / 2.0;
        }
        return [left, top, left + width, top + height] as Array<Float>;
    }
}
