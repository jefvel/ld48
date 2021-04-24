package entities;

import gamestates.PlayState;
import elke.graphics.Sprite;
import elke.entity.Entity2D;

class Fish extends Entity2D {
    public var data : Data.Fish;
    var sprite : Sprite;

    public var caught = false;

    public function new(type: Data.Fish, ?p) {
        super(p);

        data = type;
        sprite = switch(type.ID) {
            case Basic: hxd.Res.img.fish1_tilesheet.toSprite2D(this);

            default: hxd.Res.img.fish1_tilesheet.toSprite2D(this);
        }

        sprite.originX = 29;
        sprite.originY = 17;

        x = Math.round(Math.random() * Const.SEA_WIDTH);
        y = Math.round(Math.random() * (data.ToDepth - data.FromDepth) + data.FromDepth);

        sprite.animation.play("idle");
    }

    public function catchFish() {
        caught = true;
    }
}