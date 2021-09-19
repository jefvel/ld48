package entities;

import h2d.Bitmap;
import h2d.ScaleGrid;
import elke.Game;
import elke.graphics.Sprite;
import h2d.SpriteBatch;
import elke.entity.Entity2D;

class TownDog extends Entity2D {
	var sprite:Sprite;
	var bubble : ScaleGrid;
	public function new(?p) {
		super(p);
		sprite = hxd.Res.img.dog_tilesheet.toSprite2D(this);
		sprite.animation.play("idle");
		bubble = new ScaleGrid(hxd.Res.img.speechbubble.toTile(), 3, 3, 3, 6, this);
		var boneBm = new Bitmap(hxd.Res.img.bone.toTile(), bubble);
		boneBm.x = boneBm.y = 3;
		bubble.width = 3 * 2 + boneBm.tile.width;
		bubble.height = 3 + boneBm.tile.height + 6;
		bubble.x = 32;
		bubble.y = - 32;
		bubble.alpha = 0;
	}

	var talkingTo = false;
	var timeout = 0.;

	override function update(dt:Float) {
		super.update(dt);
		if (!talkingTo) {
			timeout -= dt;
			if (timeout < 0) {
				bubble.alpha *= 0.92;
			}
		}
	}

	public function talkTo(onFinish: Void -> Void) {
		Game.instance.sound.playWobble(hxd.Res.sound.bark);
		bubble.alpha = 1.0;
		talkingTo = true;
		sprite.animation.play("bark", false, false, 0, (s) -> {
			sprite.animation.play("idle");
			onFinish();
			talkingTo = false;
			timeout = 0.6;
		});
	}
}