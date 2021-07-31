package entities;

import h2d.RenderContext;
import hxd.Key;
import elke.graphics.Sprite;
import elke.entity.Entity2D;

class TownCharacter extends Entity2D {
	var sprite : Sprite;
	var vx = 0.0;
	var tx = 0.0;

	var speed = 1.5;
	var maxSpeed = 3.0;

    var walkingLeft = false;
    var walkingRight = false;

	public var disableControls = false;

	public function new(?p) {
		super(p);
		sprite = hxd.Res.img.fishertown_tilesheet.toSprite2D(this);
		sprite.originX = 32;
		sprite.originY = 64;
		sprite.scaleX = -1;

		y = 256;
	}

	public function setX(x) {
		this.x = tx = x;
	}

	public override function update(dt:Float) {
		super.update(dt);

        walkingRight = !disableControls && (Key.isDown(Key.D) || Key.isDown(Key.RIGHT));
        walkingLeft = !disableControls && (Key.isDown(Key.A) || Key.isDown(Key.LEFT));

		var ax = 0.;
		if (walkingRight) {
			ax += speed;
		}
		if (walkingLeft) {
			ax -= speed;
		}

		vx += ax;
		vx = Math.max(-maxSpeed, vx);
		vx = Math.min(maxSpeed, vx);

		if (vx < -0.1) {
			sprite.scaleX = -1;
		} else if (vx > 0.1) {
			sprite.scaleX = 1;
		}


		tx += vx;
		tx = Math.max(64, Math.min(tx, 1044));

		vx *= 0.72;

		if (Math.abs(tx - x) <= 0.8) {
			sprite.animation.play("idle");
		} else {
			sprite.animation.play("walk");
		}

		if (sprite.animation.currentAnimationName == "walk") {
			if (lastWalkFrame != sprite.animation.currentFrame) {
				lastWalkFrame = sprite.animation.currentFrame;
				if (lastWalkFrame == 4 || lastWalkFrame == 7) {
					var sounds = [
						hxd.Res.sound.footsteps.step1,
						hxd.Res.sound.footsteps.step2,
						hxd.Res.sound.footsteps.step3,
						hxd.Res.sound.footsteps.step4,
					];

					sounds[Std.int(sounds.length * Math.random())].play(false, 0.05);
				}
			}

		}

		x = Math.round(tx);
	}

	var lastWalkFrame = 0;

	override function sync(ctx:RenderContext) {
		super.sync(ctx);
	}
}