package entities;

import elke.Game;
import elke.T;
import gamestates.PlayState;
import elke.graphics.Sprite;
import elke.entity.Entity2D;

class Fish extends Entity2D {
    public var data : Data.Fish;
    public var sprite : Sprite;

    public var fleeing = false;
    public var caught = false;
    public var rot = 0.0;
    public var pattern: Array<Direction>;
    public var dead = false;

    public var attractSpeed = 0.2;

    static public var fishPatterns = {
        Basic: [Up, Left, Down, Right],
        Basic2: [Left, Right, Left, Right, Left, Right, Left, Right],
        Eel: [Up, Down, Up, Down, Up, Down, Up, Down, Left, Right],
        Jelly: [Left, Left, Left, Right, Right, Right, Up, Up, Up, Down, Down, Down],
        Biggo: [Left, Right, Up, Down, Left, Right, Up, Down, Left, Right, Left, Right],
        Cthulhu: [Up, Left, Down, Right, Up, Left, Down, Right, Up, Left, Right, Left, Up, Left, Right, Left, Down, Right, Up, Left],
    }

    var vx = 0.0;
    var vy = 0.0;

    public function new(type: Data.Fish, ?p) {
        super(p);

        data = type;
        sprite = switch(type.ID) {
            case Basic: hxd.Res.img.fish0_tilesheet.toSprite2D(this);
            case Basic2: hxd.Res.img.fish1_tilesheet.toSprite2D(this);
            case Eel: hxd.Res.img.fish2_tilesheet.toSprite2D(this);
            case Jelly: hxd.Res.img.fish3_tilesheet.toSprite2D(this);
            case Biggo: hxd.Res.img.fish4_tilesheet.toSprite2D(this);
            case Cthulhu: hxd.Res.img.crumbo_tilesheet.toSprite2D(this);
        }

        sprite.originX = data.OriginX;
        sprite.originY = data.OriginY;

        pattern = switch(type.ID) {
            case Basic: fishPatterns.Basic;
            case Basic2: fishPatterns.Basic2;
            case Eel: fishPatterns.Eel;
            case Jelly: fishPatterns.Jelly;
            case Biggo: fishPatterns.Biggo;
            case Cthulhu: fishPatterns.Cthulhu;
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

    var bTime = 0.0;
    public function bounce() {
        bTime = 0.4;
    }

    var rotting = false;
    var rotTime = 3.0;
    public function rotAway() {
        rotting = true;
    }

    var plumsed = false;

    override function update(dt:Float) {
        super.update(dt);
        if (rotting) {
            rotTime -= dt;
            if (rotTime < 0) {
                alpha -= dt;
                if (alpha < 0) {
                    remove();
                }
            }
        }

        if (fleeing) {
            x += vx;
            y += vy;
            vy += gravity;

            if (y > 0) {
                vy *= 0.9;
                if (!plumsed) {
                    plumsed = true;
                    Game.instance.sound.playWobble(hxd.Res.sound.splash, 0.2);
                }
            }

            rotation = Math.atan2(vy, vx);
        }

        if (bTime > 0) {
            bTime -= dt;
            bTime = Math.max(0, bTime);
            sprite.y = -5 + T.bounceOut(1.0 - (bTime / 0.4)) * 5;
        }
    }

    public function kill() {
        sprite.animation.play("dead");
        dead = true;
    }

    public function catchFish() {
        caught = true;
    }
}