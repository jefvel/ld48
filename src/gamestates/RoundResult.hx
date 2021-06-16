package gamestates;

import h2d.RenderContext;
import h2d.Text;
import h2d.HtmlText;
import h2d.Tile;
import h2d.Bitmap;
import entities.Fish;
import elke.entity.Entity2D;

class RoundResult extends Entity2D {
	var timeLeft: Float;
	var maxCombo: Int;
	var caughtFish: Array<Fish>;

	var bg : Bitmap;
	var totalBg : Bitmap;

	var totalScoreText: h2d.HtmlText;

	var timeLeftText : HtmlText;
	var maxComboText : HtmlText;

	var paddingX = 32.;

	var totalScore = 0;

	var scorePerExtraSecond = 1500.0;
	var scoreInterpVal = 0.;

	var pointsPerCombo = 1000.0;

	public function new(caughtFish, maxCombo, timeLeft, ?p) {
		super(p);

		this.caughtFish = caughtFish;
		this.maxCombo = maxCombo;
		this.timeLeft = timeLeft;

		alpha = 0;

		bg = new Bitmap(Tile.fromColor(0x000000), this);
		bg.alpha = 0.05;

		var resultText = new Text(hxd.Res.fonts.futilepro_medium_12.toFont(), this);
		resultText.text = "Fishing Results";
		resultText.x = resultText.y = 32;

		var decimals = 3;
		var roundedTime:Float = Math.round((timeLeft * Math.pow(10, decimals)));
		roundedTime /= Math.pow(10, decimals);

		timeLeftText = new HtmlText(hxd.Res.fonts.picory.toFont(), this);
		timeLeftText.text = '<font color="#dedede">Time Left:</font> ${roundedTime}s';
		timeLeftText.x = paddingX;
		timeLeftText.y = resultText.y + 64;

		maxComboText = new HtmlText(hxd.Res.fonts.picory.toFont(), this);
		maxComboText.text = '<font color="#dedede">Biggest Combo:</font> ${maxCombo}';
		maxComboText.x = paddingX;
		maxComboText.y = timeLeftText.y + 18;

		totalBg = new Bitmap(Tile.fromColor(0x000000), bg);
		bg.alpha = 0.2;
		totalScoreText = new h2d.HtmlText(hxd.Res.fonts.headline.toFont(), this);

		totalScore += Math.floor(roundedTime * scorePerExtraSecond);

		totalScore += Math.floor(maxCombo * pointsPerCombo);

	}

	override function update(dt:Float) {
		super.update(dt);
		if (alpha < 1) {
			alpha += (1. - bg.alpha) * 0.2;
		}
	}

	override function sync(ctx:RenderContext) {
		super.sync(ctx);

		var s = getScene();

		bg.width = s.width;
		bg.height = s.height;

		totalBg.width = bg.width;
		totalBg.height = 32 + 28 + totalScoreText.textHeight;
		totalBg.y = s.height - totalBg.height;

		totalScoreText.x = 32;
		totalScoreText.y = s.height - totalScoreText.textHeight - 28;

		scoreInterpVal += (totalScore - scoreInterpVal) * 0.05;

		totalScoreText.text = '<font color="#33ff33">Score:</font> ${Math.round(scoreInterpVal)}';
	}
}