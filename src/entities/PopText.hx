package entities;

import h2d.RenderContext;
import h2d.Font;
import h2d.Text;
import h2d.Object;
import elke.entity.Entity2D;

class PopText extends Object {
    public var text : Text;
    static var font : Font;
    public function new(text: String, ?p) {
        super(p);
        if (font == null) {
            font = hxd.Res.fonts.small.toFont();
        }

        var t = new Text(font, this);

        t.textAlign = Center;
        t.text = text;

        this.text = t;
    }

    var yy = 0.0;
    var elapsed = 0.0;
    override function sync(ctx:RenderContext) {
        super.sync(ctx);
        yy -= ctx.elapsedTime * 4;
        text.y = Math.round(yy);
        elapsed += ctx.elapsedTime;
        if (elapsed > 0.6) {
            alpha -= ctx.elapsedTime / 0.8;
            if (alpha <= 0) remove();
        }
    }
}