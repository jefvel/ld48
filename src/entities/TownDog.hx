package entities;

import elke.graphics.Sprite;
import h2d.SpriteBatch;
import elke.entity.Entity2D;

class TownDog extends Entity2D {
	var sprite:Sprite;
	public function new(?p) {
		super(p);
		sprite = hxd.Res.img.dog_tilesheet.toSprite2D(this);
		sprite.animation.play("idle");
	}
}