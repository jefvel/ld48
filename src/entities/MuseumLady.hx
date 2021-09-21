package entities;

import elke.process.Timeout;
import h2d.Text;
import elke.graphics.Sprite;
import elke.entity.Entity2D;

class MuseumLady extends Entity2D {
	var sprite: Sprite;
	public function new(?p) {
		super(p);
		sprite = hxd.Res.img.museumlady_tilesheet.toSprite2D(this);
        sprite.animation.play("idle");
	}

	var anyKeyWasDown = true;
	override function update(dt:Float) {
		super.update(dt);

		if (!active) {
			return;
		}

		var anyKeyDown = Const.isAnyKeyDown();
		if (!anyKeyWasDown && anyKeyDown && finishedTalking) {
			bubble.close();
			onFinishTalk();
			active = false;
			sprite.animation.play("idle");
		}

		anyKeyWasDown = anyKeyDown;
	}
	
	var active = false;
	var bubble: SpeechBubble;

	var onFinishTalk: Void -> Void;
	var finishedTalking = false;
	public function talkTo(onFinish : Void -> Void) {
		var b = new SpeechBubble(this);
		bubble = b;
		finishedTalking = false;
		this.onFinishTalk = onFinish;
		b.x = 32;
		b.y = -4;
		active = true;
		/*
		var t = new Text(hxd.Res.fonts.equipmentpro_medium_12.toFont(), b.content);
		t.textColor = 0x111111;
		*/
		var text = "";
		var d = GameSaveData.getCurrent();
		if (d.talkedToMuseumLady == 0) {
			text = "Good day hon!";
		} else if (d.talkedToMuseumLady == 1) {
			text = "The Museum needs more things to look at";
		} else if (d.talkedToMuseumLady == 2) {
			text = "If you bring me fish, the townspeople will gladly pay for museum tickets";
		} else if (d.talkedToMuseumLady == 3) {
			text = "You will of course get a fair cut!";
		} else {
			var prompts = [
				"Have a blessed day!",
				"Feel free to visit the museum, there is so much to learn!",
				"The museum gladly accepts donations of different species of fish",
				"Take care hon",
				"Don't go too far at sea, you never know what lives in the depths",
				"Come back any time!",
			];

			text = prompts[Std.int(Math.random() * prompts.length)];
		}

		sprite.animation.play("talk");

		d.talkedToMuseumLady ++; 
		bubble.speech(text, [
			hxd.Res.sound.speech.museumlady.s1,
			hxd.Res.sound.speech.museumlady.s2,
			hxd.Res.sound.speech.museumlady.s3,
			hxd.Res.sound.speech.museumlady.s4,
			hxd.Res.sound.speech.museumlady.s5,
			hxd.Res.sound.speech.museumlady.s6,
			hxd.Res.sound.speech.museumlady.s7,
			hxd.Res.sound.speech.museumlady.s8,
			hxd.Res.sound.speech.museumlady.s9,
			hxd.Res.sound.speech.museumlady.s10,
		], () -> {
			finishedTalking = true;
			sprite.animation.play("stand");
		});

	}
}