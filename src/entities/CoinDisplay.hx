package entities;

import h2d.Object;
import h2d.filter.Outline;
import h2d.Text;
import h2d.Bitmap;
import elke.entity.Entity2D;

class CoinDisplay extends Entity2D {
	var coinIcon: Bitmap;

	public var coins : Int = 0;
	var _coins = 0.0;

	var container : Object;

	var coinText: Text;
	public var active = false;
	public function new(?p) {
		super(p);

		container = new Object(this);

		coinIcon = new Bitmap(hxd.Res.img.coin.toTile(), container);
		coinText = new Text(hxd.Res.fonts.picory.toFont(), container);
		coinText.filter = new Outline(1, 0xff2c1b2e, 0.9, true);
		coinText.x = coinIcon.tile.width + 4;
		coinText.y = 2;
		container.alpha = 0;
		container.x = -3;
	}

	override function update(dt:Float) {
		super.update(dt);
		_coins += (coins - _coins) * 0.2;
		coinText.text = '${Math.round(_coins)}';
		var targetAlpha = 0.;
		var targetX = -3.;

		if (active) {
			targetX = 0;
			targetAlpha = 1.0;
		}

		container.alpha += (targetAlpha - container.alpha) * 0.12;
		container.x += (targetX - container.x) * 0.12;
	}
}