package entities;

import elke.process.Timeout;
import h2d.Text;
import elke.graphics.Sprite;
import elke.entity.Entity2D;

class Merchant extends Entity2D {
	var sprite: Sprite;
	public function new(?p) {
		super(p);
		sprite = hxd.Res.img.merchant_tilesheet.toSprite2D(this);
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
	public function lookedAtBoat(onFinish : Void -> Void) {
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
		var prompts = [
			"It's a mighty fine boat eh",
			"It belonged to my son",
		];

		text = prompts[Std.int(Math.random() * prompts.length)];

		sprite.animation.play("talk");

		d.talkedToMuseumLady ++; 
		bubble.speech(text, [
			hxd.Res.sound.speech.merchant.s1,
			hxd.Res.sound.speech.merchant.s2,
			hxd.Res.sound.speech.merchant.s3,
			hxd.Res.sound.speech.merchant.s4,
			hxd.Res.sound.speech.merchant.s5,
			hxd.Res.sound.speech.merchant.s6,
			hxd.Res.sound.speech.merchant.s7,
			//hxd.Res.sound.speech.merchant.s8,
			//hxd.Res.sound.speech.merchant.s9,
			//hxd.Res.sound.speech.merchant.s10,
		], () -> {
			finishedTalking = true;
			sprite.animation.play("stand");
		});

	}
}