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

        walkingRight = Key.isDown(Key.D) || Key.isDown(Key.RIGHT);
        walkingLeft = Key.isDown(Key.A) || Key.isDown(Key.LEFT);

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

		x = Math.round(tx);
	}

	override function sync(ctx:RenderContext) {
		super.sync(ctx);
	}
}