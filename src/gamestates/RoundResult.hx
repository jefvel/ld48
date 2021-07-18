package gamestates;

import h2d.filter.Glow;
import elke.T;
import entities.CatchingQueue;
import graphics.BoatTransition;
import elke.graphics.Transition;
import hxd.Event;
import h2d.Interactive;
import h2d.Object;
import h2d.RenderContext;
import h2d.Text;
import h2d.HtmlText;
import h2d.Tile;
import h2d.Bitmap;
import entities.Fish;
import elke.entity.Entity2D;

enum ResultPresentingSection {
	Start;
	BoostScore;
	CatchTime;
	MaxCombo;
	CaughtFish;
	Complete;
}
class TextWithLabel extends Object {
	var _label: Text;
	var _text: Text;

	public static var labelWidth = 0;

	public var text(get, set): String;
	public var label(get, set): String;
	
	var f: Glow;
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
		f = new Glow(0xffffff, 0.8, 1);
	}

	var bounceTime = 0.0;
	var maxBounceTime = 0.2;
	public function bounce() {
		bounceTime = maxBounceTime;
		this.filter = f;
	}

	override function sync(ctx:RenderContext) {
		super.sync(ctx);

		labelWidth = Std.int(Math.max(labelWidth, _label.textWidth));

		_label.x = labelWidth;
		_text.x = labelWidth + 6;

		bounceTime -= ctx.elapsedTime;
		bounceTime = Math.max(0, bounceTime);

		var b = T.bounceIn((bounceTime / maxBounceTime));

		f.radius = (bounceTime / maxBounceTime) * 1.4;
		f.alpha = (bounceTime / maxBounceTime);

		if (f.radius == 0) {
			filter = null;
		} else {
			filter = f;
		}

		setScale(1.0 + b * 0.25);
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

class TextButton extends Interactive {
	var bm : Bitmap;
	var label : Text;
	var sInc = 0.0;

	public function new(t: Tile, label: String, onPress: Void -> Void, ?p) {
		super(0, 0, p);
		bm = new Bitmap(t, this);
		this.label = new Text(hxd.Res.fonts.picory.toFont(), this);
		this.label.text = label;
		this.label.x = t.width + 4;
		this.label.y = Math.round((t.height - this.label.textHeight) * 0.5) + 1;

		bm.tile.dx = -16;
		bm.tile.dy = -16;
		bm.x += 16;
		bm.y += 16;

		var b = getBounds();
		this.width = b.width;
		this.height = b.height;
		this.onPush = e -> {
			onPress();
		}
	}

	public function update(dt: Float) {
		sInc *= 0.7;
		bm.setScale(1 + sInc);
	}

	public function onTap() {
		sInc = 0.4;
		hxd.Res.sound.buttonpress.play(false, 0.56);
	}
}

class RoundResult extends Entity2D {
	var timeLeft: Float;
	var roundedTime = 0.;
	var maxCombo: Int = 0;
	var boostScore: Int = 0;
	var caughtFish: Array<Fish>;

	var bg : Bitmap;
	var totalBg : Bitmap;

	var currentState: ResultPresentingSection = Start;

	var totalScoreText: h2d.HtmlText;

	var boostScoreText: TextWithLabel;
	var timeLeftText : TextWithLabel;
	var maxComboText : TextWithLabel;

	var comboScore = 0;
	var timeScore = 0;

	var paddingX = 32.;

	var totalScore = 0;

	var scorePerExtraSecond = 900.0;
	var scoreInterpVal = 0.;

	var pointsPerCombo = 1000.0;

	var buttonContainer : Object;
	var returnButton : TextButton;
	var retryButton: TextButton;

	var queue: CatchingQueue;
	var caughtFishScore = 0;
	var caughtFishScoreText : Text;

	public function new(caughtFish, maxCombo, timeLeft, boostScore, ?p) {
		super(p);

		this.boostScore = boostScore;
		this.caughtFish = caughtFish;
		this.maxCombo = maxCombo;
		this.timeLeft = timeLeft;

		alpha = 0;

		bg = new Bitmap(Tile.fromColor(0x000000), this);
		bg.alpha = 0.05;

		var resultText = new Text(hxd.Res.fonts.equipmentpro_medium_12.toFont(), this);
		resultText.setScale(2);

		resultText.text = "Fishing Results";
	
		comboScore = Math.floor(maxCombo * pointsPerCombo);

		var decimals = 3;
		roundedTime = Math.round((timeLeft * Math.pow(10, decimals)));
		roundedTime /= Math.pow(10, decimals);

		timeScore = Math.floor(roundedTime * scorePerExtraSecond);	resultText.x = resultText.y = 32;

		boostScoreText = new TextWithLabel('Boost Score', '$boostScore', this);
		boostScoreText.y = resultText.y + 64;
		boostScoreText.x = paddingX;
		boostScoreText.visible = false;

		timeLeftText = new TextWithLabel('Time Left', '', this);
		timeLeftText.x = paddingX;
		timeLeftText.y = boostScoreText.y + 18;
		timeLeftText.visible = false;

		maxComboText = new TextWithLabel('Biggest Combo', '$maxCombo * ${pointsPerCombo}  =  $comboScore', this);
		maxComboText.x = paddingX;
		maxComboText.y = timeLeftText.y + 18;
		maxComboText.visible = false;

		totalBg = new Bitmap(Tile.fromColor(0x000000), bg);
		bg.alpha = 0.2;
		totalScoreText = new h2d.HtmlText(hxd.Res.fonts.headline.toFont(), this);

		resultText.dropShadow = {
			dx: 1,
			dy: 1,
			color: 0x000000,
			alpha: 0.4,
		};

		totalScoreText.dropShadow = {
			dx: 1,
			dy: 1,
			color: 0x000000,
			alpha: 0.4,
		};

		buttonContainer = new Object(this);
		var arrows = hxd.Res.img.endroundarrows.toTile();

		returnButton = new TextButton(arrows.sub(0, 0, 32, 32), 'Return\nto town', doReturn, buttonContainer);

		retryButton = new TextButton(arrows.sub(32, 0, 32, 32), 'Continue\nfishing', doRetry, buttonContainer);
		retryButton.x = returnButton.width + 16;

		queue = new CatchingQueue(this);
		queue.animated = false;
		queue.x = paddingX + 4;
		queue.y = maxComboText.y + maxComboText.textHeight + 40;
		queue.maxWidth = 250;
		caughtFishScoreText = new Text(hxd.Res.fonts.picory.toFont(), queue);
		caughtFishScoreText.x = 236;
		caughtFishScoreText.y = -6;
		// caughtFishScoreText.y = Math.round((16 - caughtFishScoreText.textHeight) * 0.5);
	}

	public var onReturn : Void -> Void;
	public var onRetry : Void -> Void;
	var chosen = false;

	var canLeave = false;

	function doReturn() {
		if (chosen) {
			return;
		}

		returnButton.onTap();
		chosen = true;

		new BoatTransition(() -> {
			remove();
			if (onReturn != null) {
				onReturn();
			}
		}, getScene());
	}

	function doRetry() {
		if (chosen) {
			return;
		}

		retryButton.onTap();
		chosen = true;

		new BoatTransition(() -> {
			remove();
			if (onRetry != null) {
				onRetry();
			}
		}, getScene());
	}

	public function directionPressed(dir: PlayState.Direction) {
		if (!canLeave) {
			return;
		}

		switch(dir) {
			case Left: doReturn();
			case Right: doRetry();
			default:
		}
	}

	var scoreTickSound: hxd.snd.Channel;
	var tickSoundDelay = 0.;
	var minTickSound = 0.0;

	function punchSound() {
		hxd.Res.sound.scorepunch.play(false, 0.8);
	}

	function revealBoostScore() {
		currentState = BoostScore;
		boostScoreText.visible = true;
		totalScore += boostScore;
		boostScoreText.bounce();

		punchSound();
	}

	function revealTimeLeft() {
		currentState = CatchTime;
		timeLeftText.text = '${roundedTime}s * ${scorePerExtraSecond}  =  $timeScore';

		timeLeftText.visible = true;
		totalScore += timeScore;
		timeLeftText.bounce();

		punchSound();
	}

	function revealCombo() {
		currentState = MaxCombo;
		maxComboText.visible = true;
		totalScore += comboScore;
		maxComboText.bounce();

		punchSound();
	}

	function startShowCatch() {
		currentState = CaughtFish;
	}

	var finalized = false;
	function finalizeRound() {
		currentState = Complete;
		if (finalized) {
			return;
		}

		finalized = true;
		punchSound();

		canLeave = true;
	}

	var timePerReveal = 0.85;

	var time = 0.;
	var prevInterpScore = 0.0;

	var timePerFish = 0.1;
	var currentTimePerFish = 0.;
	var fishCatchTimeout = 1.5;

	override function update(dt:Float) {
		super.update(dt);

		if (alpha < 1) {
			alpha += (1. - bg.alpha) * 0.2;
		}

		time += dt;
		if (time >= timePerReveal) {
			time = 0;
			if (currentState == Start) {
				revealBoostScore();
			} else if (currentState == BoostScore) {
				revealTimeLeft();
			} else if (currentState == CatchTime) {
				revealCombo();
			} else if (currentState == MaxCombo) {
				startShowCatch();
			}
		}

		if (currentState == CaughtFish) {
			currentTimePerFish += dt;
			if (currentTimePerFish > timePerFish) {
				var f = caughtFish.shift();
				if (f == null ) {
					fishCatchTimeout -= dt;
					if (fishCatchTimeout <= 0) {
						finalizeRound();
					}
				} else {
					totalScore += f.data.Score;

					queue.addFish(f);
					hxd.Res.sound.fishthud.play(false, 0.3);
					currentTimePerFish -= timePerFish;

					caughtFishScore += f.data.Score;
					caughtFishScoreText.text = '= $caughtFishScore';
				}
			}
		}


		var sinc = (totalScore - scoreInterpVal) * 0.08;

		prevInterpScore = scoreInterpVal;
		scoreInterpVal += sinc;

		minTickSound += dt;
		if (Math.round(prevInterpScore) != Math.round(scoreInterpVal) && minTickSound > 0.03) {
			minTickSound = 0;
			scoreTickSound = hxd.Res.sound.scoretick.play(false, 0.1);
		}

		totalScoreText.text = '<font color="#33ff33">Score</font> ${Math.round(scoreInterpVal)}';

		returnButton.update(dt);
		retryButton.update(dt);
	}

	override function sync(ctx:RenderContext) {
		super.sync(ctx);

		buttonContainer.visible = canLeave;

		var s = getScene();

		bg.width = s.width;
		bg.height = s.height;

		totalBg.width = bg.width;
		totalBg.height = 32 + 28 + totalScoreText.textHeight;
		totalBg.y = s.height - totalBg.height;

		totalScoreText.x = 32;
		totalScoreText.y = s.height - totalScoreText.textHeight * totalScoreText.scaleY - 28;

		var padding = Math.round((totalBg.height - 32) * 0.5);
		var tWidth = retryButton.width + returnButton.width + 16;
		buttonContainer.x = s.width - tWidth - padding;
		buttonContainer.y = totalBg.y + padding;
	}
}