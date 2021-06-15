package gamestates;

import h2d.RenderContext;
import h2d.Text;
import h2d.Tile;
import h2d.Bitmap;
import entities.Fish;
import elke.entity.Entity2D;

class RoundResult extends Entity2D {
	var timeLeft: Float;
	var maxCombo: Int;
	var caughtFish: Array<Fish>;

	var bg : Bitmap;

	public function new(caughtFish, maxCombo, timeLeft, ?p) {
		super(p);

		this.caughtFish = caughtFish;
		this.maxCombo = maxCombo;
		this.timeLeft = timeLeft;

		bg = new Bitmap(Tile.fromColor(0x000000), this);
		bg.alpha = 0.0;

		var resultText = new Text(hxd.Res.fonts.futilepro_medium_12.toFont(), this);
		resultText.text = "Fishing Results";
		resultText.x = resultText.y = 32;
	}

	override function update(dt:Float) {
		super.update(dt);
		if (bg.alpha < 0.1) {
			bg.alpha += (0.1 - bg.alpha) * 0.1;
		}
	}

	override function sync(ctx:RenderContext) {
		super.sync(ctx);

		bg.width = getScene().width;
		bg.height = getScene().height;
	}
}