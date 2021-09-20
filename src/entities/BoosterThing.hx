package entities;

import h2d.Text;
import h2d.filter.Outline;
import h2d.filter.Glow;
import elke.graphics.Sprite;
import elke.Game;
import h3d.Vector;
import h2d.Bitmap;
import elke.entity.Entity2D;

class BoosterThing extends Entity2D {
    var bgbg: Bitmap;
    var bg: Bitmap;
    var arrow : Bitmap;
    var top : Bitmap;
    var v = 0.1;

    var inArea = false;

    var activated = false;
    var successfulTurn = false;

    public var onFail: Void -> Void;
    var failed = false;
    var succeeded = false;

    public var boosts = 0;
    public var maxBoosts = 5;

    var boostKey: Sprite;
    var boostInfo : TextButton;
    var glowFilter : Glow;

    var dots : ProgressDots;

    public var maxBoostDepth = 0.0;
    var boostDepthText : Text;

    public function new(?p) {
        super(p);
        bg = new Bitmap(hxd.Res.img.boosterbg.toTile());
        bg.tile.dx = -31;
        bg.tile.dy = -33;

        bgbg = new Bitmap(bg.tile, this);
        bgbg.alpha = 4.0;

        addChild(bg);

        arrow = new Bitmap(hxd.Res.img.boosterarrow.toTile(), this);
        arrow.tile.dx = -3;
        arrow.tile.dy = -3;
        arrow.color = new Vector(1, 1, 1);

        glowFilter = new Glow(0xffffff, 1.0, 0.0);
        bgbg.filter = glowFilter;

        top = new Bitmap(hxd.Res.img.boosterarrowtop.toTile(), this);
        top.tile.dx = top.tile.dy = -3;

        /*
        boostKey = hxd.Res.img.boostkey_tilesheet.toSprite2D(this);
        boostKey.originX = 16;
        boostKey.originY = 16;
        boostKey.y = 64;
        boostKey.x = 1;
        boostKey.animation.play();
        */

        boostInfo = new TextButton(
            hxd.Res.img.endroundarrows.toTile().sub(32, 32, 32, 32),
            "Tap\nTo Boost",
            null,
            null,
            this
        );

        boostInfo.muted = true;

        boostInfo.x = -16;
        boostInfo.y = 64 - 16;
        dots = new ProgressDots(maxBoosts, this);
        dots.x = -Math.round(dots.width * 0.5);
        dots.y = -50;

        boostDepthText = new Text(hxd.Res.fonts.picory.toFont(), dots);
        boostDepthText.x = 44;
        boostDepthText.y = 3;
        boostDepthText.dropShadow = {
            dx: 1,
            dy: 1,
            color: 0x000000,
            alpha: 0.5,
        };

    }

    public function reset() {
        boosts = 0;
        activated = false;
        failed = false;
        succeeded = false;
        v = 0.1;
    }

    public function activate() {
        activated = true;

        boostInfo.onTap();

        if (inArea) {
            successfulTurn = true;

            glowFilter.radius = 2.0;
            glowFilter.alpha = 1.0;

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
            dots.value = boosts;

            if (boosts == maxBoosts) {
                succeeded = true;
            }

            bg.setScale(1.2 + boosts * 0.1);
            bgbg.setScale(bg.scaleX);
            return true;
        }

        v = 0.0;

        failed = true;

        return false;
    }

    var targetAlpha = 1.0;

    public function fadeOut() {
        alpha = 1.0;
        targetAlpha = 0.0;
    }

    public function fadeIn() {
        targetAlpha = 1.0;
    }

    override function update(dt:Float) {
        super.update(dt);

        boostInfo.update(dt);

        glowFilter.radius *= 0.83;
        glowFilter.alpha *= 0.8;

        alpha += (targetAlpha - alpha) * 0.2;
        var s = bg.scaleX;
        s += (1.0 - s) * 0.1;
        bg.setScale(s);
        bgbg.setScale(bg.scaleX);

        if (failed) {
            arrow.color.set(0.8, 0.1, 0.1);
            return;
        }

        if (succeeded) {
            arrow.color.set(0.2, 0.3, 1.0);
            return;
        }

        arrow.rotation += v;

        if (arrow.rotation > Math.PI * 2) {
            arrow.rotation -= Math.PI * 2.0;
        }

        if (arrow.rotation > Math.PI * 1.25 && arrow.rotation < Math.PI * 1.75) {
            arrow.color.set(0.3, 0.8, 0.1);
            inArea = true;
        } else {
            arrow.color.set(1, 1, 1);

            if (inArea) {
                if (!successfulTurn && activated) {
                    activated = false;
                    failed = true;
                    onFail();
                }
                successfulTurn = false;
            }

            inArea = false;
        }

        boostDepthText.text = '${Math.round(boosts / maxBoosts * maxBoostDepth / Const.UNITS_PER_METER)} / ${Math.round(maxBoostDepth / Const.UNITS_PER_METER)}  m';
    }
}