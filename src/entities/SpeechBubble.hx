package entities;

import elke.Game;
import h2d.Text;
import elke.T;
import h2d.RenderContext;
import h2d.Object;
import h2d.ScaleGrid;
import elke.entity.Entity2D;

class SpeechBubble extends Entity2D {
	var bubble : ScaleGrid;
	var paddingTop = 12;
	var paddingBottom = 14;
	var paddingX = 16;
	public var content: Object;
	public function new(?p) {
		super(p);
		bubble = new ScaleGrid(hxd.Res.img.speechbubble.toTile(), 4, 3, 3, 6, this);
		content = new Object(this);
		content.x = paddingX;
	}

	var timePerChar = 30 / 1000.;
	var speaking = false;
	var speechSounds: Array<hxd.res.Sound>;
	var totalText: String;
	var onSpeechDone: Void -> Void;
	var currentChar = 0;
	var timeUntilSound = 0.;
	var timePerSound = 0.1;
	var sTime = 0.;

	var textField: Text;

	public function speech(text: String, sounds: Array<hxd.res.Sound>, onFinish: Void -> Void) {
		speaking = true;
		onSpeechDone = onFinish;
		speechSounds = sounds;
		totalText = text;
		textField = new Text(hxd.Res.fonts.equipmentpro_medium_12.toFont(), content);
		textField.textColor = 0x111111;
		textField.maxWidth = 160;
	}

	override function sync(ctx:RenderContext) {
		super.sync(ctx);
		var b = content.getBounds();
		bubble.width = b.width + paddingX * 2;
		bubble.height = b.height + paddingTop + paddingBottom;
		bubble.y = -b.height - paddingTop - paddingBottom;
		content.y = -b.height - paddingBottom;
	}

	var tIn = 1.0;

	override function update(dt:Float) {
		super.update(dt);

		tIn -= dt / 0.33;
		tIn = Math.max(0, tIn);
		rotation = T.bounceIn(tIn) * -0.1;

		if (speaking) {
			sTime += dt;
			timeUntilSound -= dt;
			if (timeUntilSound <= 0) {
				timeUntilSound = timePerSound;
				var s = speechSounds[Std.int(Math.random() * speechSounds.length)];
				Game.instance.sound.playWobble(s);
			}

			while(sTime >= timePerChar) {
				sTime -= timePerChar;
				currentChar ++;
			}

			textField.text = totalText.substr(0, currentChar);
			if (currentChar >= totalText.length) {
				onSpeechDone();
				speaking = false;
			}
		}

		if (closing) {
			alpha *= 0.9;
			if (alpha <= 0.001) {
				remove();
			}
		}
	}

	var closing = false;
	public function close() {
		closing = true;
	}

}