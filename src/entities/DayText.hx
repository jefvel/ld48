package entities;

import h2d.RenderContext;
import h2d.Font;
import h2d.Text;
import h2d.Object;
import elke.entity.Entity2D;

class DayText extends Object {
    public var text : Text;
    static var font : Font;
    var debtText : Text;
    public function new(text: String, debt: Int, ?p) {
        super(p);
        if (font == null) {
            font = hxd.Res.fonts.headline.toFont();
        }

        var t = new Text(font, this);

        t.textAlign = Center;
        t.dropShadow = {
            dx: 1,
            dy: 1,
            alpha: 0.3,
            color: 0x222222,
        }
        t.text = text;

        this.text = t;

        debtText = new Text(hxd.Res.fonts.equipmentpro_medium_12.toFont(), this);
        debtText.textAlign = Center;
        debtText.y = t.textHeight + 16;
        //debtText.text = 'You are $$${debt} dollars in debt';
        alpha = -1;
    }

    var yy = 0.0;
    var elapsed = 0.0;
    var fadingIn = true;
    override function sync(ctx:RenderContext) {
        super.sync(ctx);
        var s2d = getScene();

		x = Math.round(s2d.width * 0.5);
		y = Math.round(s2d.height * 0.18);

        if (fadingIn) {
            alpha += ctx.elapsedTime / 0.9;
            if (alpha >= 1) {
                fadingIn = false;
            }
            return;
        }

        if (elapsed > 1.8) {
            yy -= ctx.elapsedTime * 4;
        }

        text.y = Math.round(yy);
        elapsed += ctx.elapsedTime;

        if (elapsed > 2.5) {
            text.alpha -= ctx.elapsedTime / 0.8;
        }

        if (elapsed > 3.0) {
            alpha -= ctx.elapsedTime / 0.3;
            debtText.y += ctx.elapsedTime * 7;
            if (alpha <= 0) remove();
        }
    }
}