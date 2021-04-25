package entities;

import elke.graphics.Sprite;
import elke.entity.Entity2D;

class Mine extends Entity2D {
    var sprite:Sprite;

    public function new(?p) {
        super(p);
        sprite = hxd.Res.img.mine_tilesheet.toSprite2D(this);
        sprite.originX = sprite.originY = 16;
        sprite.animation.play("idle");
    }

    var exploded = false;
    public function explode() {
        if (exploded) {
            return;
        }

        exploded = true;
        sprite.animation.play("explode", false, true, 0,  (s) -> {
            remove();
        });
    }
}