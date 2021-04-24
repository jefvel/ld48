package entities;

import gamestates.PlayState;
import elke.graphics.Sprite;
import elke.entity.Entity2D;

class Fish extends Entity2D {
    public var data : Data.Fish;
    var sprite : Sprite;

    public var fleeing = false;
    public var caught = false;
    public var rot = 0.0;
    public var pattern: Array<Direction>;
    public var dead = false;

    static public var fishPatterns = {
        Basic: [Up, Left, Down, Right],
        Basic2: [Left, Right, Left, Right, Up, Left, Down, Right],
    }

    var vx = 0.0;
    var vy = 0.0;

    public function new(type: Data.Fish, ?p) {
        super(p);

        data = type;
        sprite = switch(type.ID) {
            case Basic: hxd.Res.img.fish0_tilesheet.toSprite2D(this);
            case Basic2: hxd.Res.img.fish1_tilesheet.toSprite2D(this);
        }

        sprite.originX = data.OriginX;
        sprite.originY = data.OriginY;

        pattern = switch(type.ID) {
            case Basic: fishPatterns.Basic;
            case Basic2: fishPatterns.Basic2;
        }

        x = Math.round(Math.random() * Const.SEA_WIDTH);
        y = Math.round(Math.random() * (data.ToDepth - data.FromDepth) + data.FromDepth);

        sprite.animation.play("idle");
    }

    var gravity = 0.4;
    public function flee() {
        fleeing = true;
        vx = Math.random() * 10 - 5;
        vy = Math.random() * -10.0 - 5.0;
    }

    override function update(dt:Float) {
        super.update(dt);
        if (fleeing) {
            x += vx;
            y += vy;
            vy += gravity;
            rotation = Math.atan2(vy, vx);
        }
    }

    public function kill() {
        sprite.animation.play("dead");
    }

    public function catchFish() {
        caught = true;
    }
}