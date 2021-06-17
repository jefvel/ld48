package gamestates;

import h2d.Object;
import h2d.RenderContext;
import h2d.Text;
import h2d.HtmlText;
import h2d.Tile;
import h2d.Bitmap;
import entities.Fish;
import elke.entity.Entity2D;
class TextWithLabel extends Object {
	var _label: Text;
	var _text: Text;

	public static var labelWidth = 0;

	public var text(get, set): String;
	public var label(get, set): String;
	
	public var textHeight(get, null): Float;

	public function new(label: String, text: String, ?p) {
		super(p);
		var font = hxd.Res.fonts.picory.toFont();
		_label = new Text(font, this);
		_label.textAlign = Right;
		_label.x = labelWidth;
		_label.textColor = 0xdedede;

		_text = new Text(font, this);
		_text.x = labelWidth + 4;

		_text.text = text;
		_label.text = label;
	}

	override function sync(ctx:RenderContext) {
		super.sync(ctx);

		labelWidth = Std.int(Math.max(labelWidth, _label.textWidth));

		_label.x = labelWidth;
		_text.x = labelWidth + 6;
	}

	function set_text(t) {
		return _text.text = t;
	}

	function get_text() {
		return _text.text;
	}

	function set_label(t) {
		return _label.text = t;
	}

	function get_label() {
		return _label.text;
	}

	function get_textHeight() {
		return _text.textHeight;
	}
}

class RoundResult extends Entity2D {
	var timeLeft: Float;
	var roundedTime = 0.;
	var maxCombo: Int;
	var caughtFish: Array<Fish>;

	var bg : Bitmap;
	var totalBg : Bitmap;

	var totalScoreText: h2d.HtmlText;

	var timeLeftText : TextWithLabel;
	var maxComboText : TextWithLabel;

	var comboScore = 0;
	var timeScore = 0;

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
	
		comboScore = Math.floor(maxCombo * pointsPerCombo);

		var decimals = 3;
		roundedTime = Math.round((timeLeft * Math.pow(10, decimals)));
		roundedTime /= Math.pow(10, decimals);

		timeScore = Math.floor(roundedTime * scorePerExtraSecond);	resultText.x = resultText.y = 32;

		timeLeftText = new TextWithLabel('Time Left', '', this);
		timeLeftText.x = paddingX;
		timeLeftText.y = resultText.y + 64;
		timeLeftText.visible = false;

		maxComboText = new TextWithLabel('Biggest Combo', '$maxCombo * ${pointsPerCombo}  =  $comboScore', this);
		maxComboText.x = paddingX;
		maxComboText.y = timeLeftText.y + 18;
		maxComboText.visible = false;

		totalBg = new Bitmap(Tile.fromColor(0x000000), bg);
		bg.alpha = 0.2;
		totalScoreText = new h2d.HtmlText(hxd.Res.fonts.headline.toFont(), this);


		totalScoreText.dropShadow = {
			dx: 1,
			dy: 1,
			color: 0x000000,
			alpha: 0.4,
		};
	}

	function revealTimeLeft() {

		timeLeftText.text = '${roundedTime}s * ${scorePerExtraSecond}  =  $timeScore';

		timeLeftText.visible = true;
		totalScore += timeScore;
	}

	function revealCombo() {
		maxComboText.visible = true;
		totalScore += comboScore;
	}

	var timePerReveal = 0.8;

	var time = 0.;

	override function update(dt:Float) {
		super.update(dt);
		if (alpha < 1) {
			alpha += (1. - bg.alpha) * 0.2;
		}

		time += dt;
		if (time >= timePerReveal) {
			time = 0;
			if (!timeLeftText.visible) {
				revealTimeLeft();
			} else if (!maxComboText.visible) {
				revealCombo();
			}
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

		var sinc = (totalScore - scoreInterpVal) * 0.1;
		scoreInterpVal += sinc;

		//totalScoreText.setScale(1. + Math.min(0.1, sinc * 0.1));
		totalScoreText.y = s.height - totalScoreText.textHeight * totalScoreText.scaleY - 28;
		totalScoreText.text = '<font color="#33ff33">Score</font> ${Math.round(scoreInterpVal)}';
	}
}