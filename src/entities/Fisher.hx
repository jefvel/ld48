package entities;

import elke.graphics.Sprite;
import elke.entity.Entity2D;

class Fisher extends Entity2D {
    var sprite : Sprite;

	public var rodX = 34;
	public var rodY = -37;

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
    }

    var rx = 57;
    var ry = 26;
    var time = 0.0;

    override function update(dt:Float) {
        super.update(dt);
        time += dt;
        rodX = rx - sprite.originX;
        rodY = ry - sprite.originY;
        head.visible = sprite.animation.currentAnimationName == "idle";
        head.y = 29 - sprite.originY + Math.sin(time * 1.4);
    }

    public function punch() {
        sprite.animation.play("punch", false, true, 0, (s) -> {
            sprite.animation.play("idle");
        });
    }
}