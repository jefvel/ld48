package entities;

import h2d.ScaleGrid;
import h2d.Text;
import elke.graphics.Sprite;
import elke.entity.Entity2D;

class ShopKeeper extends Entity2D {
	var sprite:Sprite;
	var sayText:Text;
	var bubble:ScaleGrid;

	public function new(?p) {
		super(p);
		sprite = hxd.Res.img.shopkeeper_tilesheet.toSprite2D(this);
		sprite.animation.play("idle");
		sprite.x = -16;
		bubble = new ScaleGrid(hxd.Res.img.speechbubble.toTile(), 4, 3, 3, 6, this);
		sayText = new Text(hxd.Res.fonts.m5x7_medium_12.toFont(), bubble);
		sayText.textColor = 0x444444;
		sayText.x = 5;
		sayText.y = 2;
		sayText.maxWidth = 140;
	}

	var minTime = 0.0;

	public function resetSay() {
		minTime = 0.0;
	}

	public function say(message:String, minTime = 0.0) {
		if (this.minTime <= 0) {
			sayText.text = message;
			this.minTime = minTime;
			resize();
		}
	}

	function resize() {
		bubble.visible = sayText.text.length > 0;
		bubble.width = sayText.textWidth + 10;
		bubble.height = sayText.textHeight + 9;
		bubble.y = -bubble.height;
	}

	override function update(dt:Float) {
		super.update(dt);
		resize();
		minTime -= dt;
		if (minTime < 0) {
			minTime = 0.0;
		}
	}
}
