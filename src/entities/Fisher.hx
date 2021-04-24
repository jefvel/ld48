package entities;

import elke.graphics.Sprite;
import elke.entity.Entity2D;

class Fisher extends Entity2D {
    var sprite : Sprite;
    public function new(?p) {
        super(p);
        sprite = hxd.Res.img.fisher_tilesheet.toSprite2D(this);
        sprite.originX = 24;
        sprite.originY = 64;
    }
}