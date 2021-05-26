package entities;

import h2d.RenderContext;
import elke.graphics.Sprite;
import h2d.Object;

class Splash extends Object {
    var s : Sprite;
    public function new(x, y, ?p) {
        super(p);
        this.x = x;
        this.y = y;
        alpha = 0.6;
        s = hxd.Res.img.splash_tilesheet.toSprite2D(this);
        s.originX = 32;
        s.originY = 18;
        s.animation.play(null, false);
    }
    override function sync(ctx:RenderContext) {
        super.sync(ctx);
        if (s.animation.finished) {
            remove();
        }
    }
}