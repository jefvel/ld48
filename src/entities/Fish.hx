package entities;

import elke.Game;
import elke.T;
import gamestates.PlayState;
import elke.graphics.Sprite;
import elke.entity.Entity2D;

class Fish extends Entity2D {
    public var data : Data.Fish;
    public var sprite : Sprite;
    var state: PlayState;

    public var fleeing = false;
    public var caught = false;
    public var rot = 0.0;
    public var pattern: Array<Direction>;
    public var dead = false;

    public var attractSpeed = 0.4;
    public var caughtTime = 0.0;

    static public var fishPatterns = {
        Basic: [Up, Left, Down, Right],
        Basic2: [Left, Right, Left, Right, Left, Right],
        Eel: [Up, Down, Up, Down, Up, Down, Left, Right],
        Jelly: [Left, Left, Right, Right, Up, Up, Down, Down],
        Biggo: [Left, Right, Up, Down, Left, Right, Up, Down, Left, Right, Left, Right],
        Cthulhu: [Up, Left, Down, Right, Up, Left, Down, Right, Up, Left, Right, Left, Up, Left, Right, Left, Down, Right, Up, Left],
        Snekris: [Up, Up, Up, Up, Up],
    }

    var vx = 0.0;
    var vy = 0.0;

    public var pileX = 0.0;
    public var pileY = 0.0;
    public var bx = 0.0;
    public var by = 0.0;
    public var inPile = false;
    public var vRot = 0.0;
    var splatted = false;
    var inPlace = false;

    public function new(type: Data.Fish, ?p, state: PlayState) {
        super(p);
        this.state = state;

        data = type;
        sprite = switch(type.ID) {
            case Basic: hxd.Res.img.fish0_tilesheet.toSprite2D(this);
            case Basic2: hxd.Res.img.fish1_tilesheet.toSprite2D(this);
            case Eel: hxd.Res.img.fish2_tilesheet.toSprite2D(this);
            case Jelly: hxd.Res.img.fish3_tilesheet.toSprite2D(this);
            case Snekris: hxd.Res.img.fish.Snaktris_tilesheet.toSprite2D(this);
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
            case Snekris: fishPatterns.Snekris;
        }

        x = Math.round(Math.random() * Const.SEA_WIDTH);
        y = Math.round(Math.random() * (data.ToDepth - data.FromDepth) + data.FromDepth);

        sprite.animation.play("idle");
    }

    var gravity = 0.4;
    public function flee() {
        fleeing = true;
        vx = Math.random() * 8 - 4;
        vy = Math.random() * -5.0 - 4.0;
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
                    var s = new Splash(x, y, parent);
                }
            }

            rotation = Math.atan2(vy, vx);
        }

        if (bTime > 0) {
            bTime -= dt;
            bTime = Math.max(0, bTime);
            sprite.y = -5 + T.bounceOut(1.0 - (bTime / 0.4)) * 5;
        }

        if (inPile && !inPlace) {
            x += bx;
            bx = (pileX - x) * 0.1;
            y += by;

            if (y < pileY) {
                by += Math.min(0.7, -y + pileY);
            }

            sprite.rotation += vRot;

            if (y > pileY && by >= 0) {
                by *= -0.4;
                y = pileY;
                vRot *= 0.4;
                if(!splatted) {
                    hxd.Res.sound.splat.play(false, 0.3);
                    state.boat.rotation = x * 0.006;
                    splatted = true;
                }
            }

            var eps = 1;
            if(Math.abs(x - pileX) < eps && Math.abs(y - pileY) < eps && Math.abs(by) < 0.01) {
                inPlace = true;
                x = pileX;
                y = pileY;
            }
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