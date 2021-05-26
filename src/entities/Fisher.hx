package entities;

import h2d.RenderContext;
import elke.graphics.Sprite;
import elke.entity.Entity2D;

class Fisher extends Entity2D {
    var sprite : Sprite;

	public var rodX = 34;
	public var rodY = -34;

    var head: Sprite;

    public function new(?p) {
        super(p);
        sprite = hxd.Res.img.fisher_tilesheet.toSprite2D(this);
        sprite.originX = 24;
        sprite.originY = 64;
        sprite.animation.play("idle");
        head = hxd.Res.img.fisherhead_tilesheet.toSprite2D(this);
        head.originX = 14;
        head.originY = 25;
        head.animation.play("idle");
        head.x = 26 - sprite.originX;
        head.y = 29 - sprite.originY;
        timeUntilBlink = 0.5 + Math.random() * 5.0;
    }

    var rx = 57;
    var ry = 29;
    var time = 0.0;
    var timeUntilBlink = 3.0;

    function resetHead(s) {
        head.animation.play("idle");
    }

    override function update(dt:Float) {
        super.update(dt);
        time += dt;
        rodX = rx - sprite.originX;
        rodY = ry - sprite.originY;
        head.y = 29 - sprite.originY + Math.sin(time * 1.4);
        timeUntilBlink -= dt;
        if (timeUntilBlink < 0) {
            timeUntilBlink = 0.5 + Math.random() * 5.0;
            head.animation.play("blink", false, false, 0.0, resetHead);
        }
    }

    override function sync(ctx:RenderContext) {
        super.sync(ctx);
        head.visible = sprite.animation.currentFrame == 0;
    }

    public function punch() {
        sprite.animation.play("punch", false, true, 0, (s) -> {
            sprite.animation.play("idle");
        });
    }
}