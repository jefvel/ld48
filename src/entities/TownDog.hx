package entities;

import elke.T;
import h2d.Bitmap;
import h2d.ScaleGrid;
import elke.Game;
import elke.graphics.Sprite;
import h2d.SpriteBatch;
import elke.entity.Entity2D;

class TownDog extends Entity2D {
	var sprite:Sprite;
	var bubble : ScaleGrid;
	var idleAnim = "idle";
	var hasBone = false;
	public function new(?p) {
		super(p);
		sprite = hxd.Res.img.dog_tilesheet.toSprite2D(this);
		sprite.animation.play(idleAnim);
		sprite.originX = 32;
		sprite.x = 32;
		bubble = new ScaleGrid(hxd.Res.img.speechbubble.toTile(), 3, 3, 3, 6, this);
		var boneBm = hxd.Res.img.bone_tilesheet.toSprite2D(bubble);
		boneBm.animation.play();
		boneBm.x = boneBm.y = 3;
		bubble.width = 3 * 2 + 32;
		bubble.height = 3 + 32 + 6;
		bubble.x = 32;
		bubble.y = - 32;
		bubble.alpha = 0;
	}

	var jumpTime = 0.;

	public function jumpAround() {
		jumpTime = 0.9;
	}

	public var fisherX = 0.;

	public function giveBone() {
		idleAnim = "idlebone";
		hasBone = true;
		sprite.animation.play(idleAnim);
	}

	var talkingTo = false;
	var timeout = 0.;
	var tIn = 0.0;

	override function update(dt:Float) {
		super.update(dt);
		
		if (jumpTime > 0) {
			jumpTime -= dt;
			sprite.y = Math.sin(jumpTime * 34.4) > 0 ? -4 : 0;
		} else {
			sprite.y = 0;
		}

		tIn -= dt / 0.3;
		tIn = Math.max(0, tIn);
		bubble.rotation = T.bounceIn(tIn) * -0.1;
		if (!talkingTo) {
			timeout -= dt;
			if (timeout < 0) {
				bubble.alpha *= 0.92;
			}
		}

		if (hasBone) {
			var dx = fisherX - (x + 32);
			if (Math.abs(dx) > 64) {
				var speed = 4.4;
				if (dx < 0) {
					vx = -speed;
					sprite.scaleX = -1;
				} else {
					vx = speed;
					sprite.scaleX = 1;
				}
			} else {
				vx *= 0.92;
			}

			x += vx;

			if (Math.abs(vx) > 0.3) {
				sprite.animation.play("run");
			} else {
				sprite.animation.play(idleAnim);
			}
		}
	}

	var vx = 0.;



	public function talkTo(onFinish: Void -> Void) {
		Game.instance.sound.playWobble(hxd.Res.sound.bark);
		bubble.alpha = 1.0;
		talkingTo = true;
		tIn = 1.0;
		sprite.animation.play("bark", false, false, 0, (s) -> {
			sprite.animation.play(idleAnim);
			onFinish();
			talkingTo = false;
			timeout = 0.6;
		});
	}
}