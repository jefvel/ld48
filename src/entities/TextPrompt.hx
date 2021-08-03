package entities;

import hxd.snd.Channel;
import elke.Game;
import h2d.Tile;
import h2d.Bitmap;
import h2d.RenderContext;
import h2d.HtmlText;
import elke.entity.Entity2D;

class TextPrompt extends Entity2D {
	var allText: String;
	var charsPerSec = 30;
	var field: HtmlText;
	var maxWidth = 256;

	var bg : Bitmap;
	var paddingX = 16;
	var paddingY = 12;

	public function new(text: String, ?p, ?onDone) {
		super(p);
		allText = text;
		bg = new Bitmap(Tile.fromColor(0x000, 1, 1), this);
		bg.width = maxWidth + paddingX * 2;
		bg.x = -paddingX;
		bg.y = -paddingY;

		field = new HtmlText(hxd.Res.fonts.picory.toFont(), this);
		field.maxWidth = maxWidth;

		field.dropShadow = {
			dx: 1,
			dy: 1,
			alpha: 0.6,
			color: 0x111111,
		}

		this.onDone = onDone;
	}

	override function sync(ctx:RenderContext) {
		super.sync(ctx);
		var s = getScene();
		this.x = Math.round((s.width - maxWidth) * 0.5);
		this.y = Math.round((s.height * 0.75));

		bg.height = field.getBounds().height + paddingY * 2;
	}

	var t = 0.0;
	var revealedChars = 0;

	var speedup = false;

	var onDone : Void -> Void;
	public var isDone = false;

	var doClose = false;

	override function update(dt:Float) {
		super.update(dt);

		var newSpeedup = Const.isAnyKeyDown();
		var ratio = newSpeedup ? 5 : 1;

		if (isDone) {
			if (newSpeedup && !speedup) {
				doClose = true;
			}

			if (doClose) {
				alpha *= 0.9;
				if (alpha <= 0.1) {
					remove();
					if (onDone != null) {
						onDone();
					}
				}
			}
		}

		speedup = newSpeedup;

		t += dt;
		var time = 1. / (charsPerSec * ratio);
		var addedChars = false;
		while (t > time) {
			revealedChars ++;
			revealedChars = Std.int(Math.min(allText.length, revealedChars));
			t -= time;
			if (field.text.length != revealedChars) {
				addedChars = true;
			}
			field.text = allText.substr(0, revealedChars);
			if (revealedChars == allText.length) {
				isDone = true;
			}
		}

		if (addedChars) {
			curChan = Game.instance.sound.playWobble(hxd.Res.sound.speech.think);
		}
	}
	var curChan: Channel;
}