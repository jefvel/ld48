package entities;

import elke.Game;
import h3d.Vector;
import h2d.Bitmap;
import elke.entity.Entity2D;

class BoosterThing extends Entity2D {
    var bg: Bitmap;
    var arrow : Bitmap;
    var v = 0.1;

    var inArea = false;
    public var boosts = 0;
    public var maxBoosts = 5;

    public function new(?p) {
        super(p);
        bg = new Bitmap(hxd.Res.img.boosterbg.toTile(), this);
        bg.tile.dx = -31;
        bg.tile.dy = -33;

        arrow = new Bitmap(hxd.Res.img.boosterarrow.toTile(), this);
        arrow.tile.dx = -2;
        arrow.tile.dy = -3;
        arrow.color = new Vector(1, 1, 1);
    }

    public function reset() {
        boosts = 0;
        v = 0.1;
    }

    public function activate() {
        if (inArea) {
            v *= 1.25;
            var boostSounds = [
                hxd.Res.sound.boost1,
                hxd.Res.sound.boost2,
                hxd.Res.sound.boost3,
                hxd.Res.sound.boost4,
                hxd.Res.sound.boost5,
                hxd.Res.sound.boost6,
            ];

            boostSounds[boosts].play(false, 0.4);
            boosts ++;
            setScale(1.2 + boosts * 0.1);
            return true;
        }

        v = 0.0;

        return false;
    }

    var targetAlpha = 2.0;

    public function fadeOut() {
        alpha = 4.0;
        targetAlpha = 0.0;
    }

    public function fadeIn() {
        targetAlpha = 2.0;
    }

    override function update(dt:Float) {
        super.update(dt);
        arrow.rotation += v;

        alpha += (targetAlpha - alpha) * 0.2;
        var s = scaleX;
        s += (1.0 - s) * 0.1;
        setScale(s);

        if (arrow.rotation > Math.PI * 2) {
            arrow.rotation -= Math.PI * 2.0;
        }
        if (arrow.rotation > Math.PI * 1.25 && arrow.rotation < Math.PI * 1.75) {
            arrow.color.set(0.3, 0.8, 0.1);
            inArea = true;
        } else {
            arrow.color.set(1, 1, 1);
            inArea = false;
        }
    }
}