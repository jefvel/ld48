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
			active = false;
			sprite.animation.play("idle");
			onFinishTalk();
		}

		anyKeyWasDown = anyKeyDown;
	}
	
	var active = false;
	var bubble: SpeechBubble;

	var onFinishTalk: Void -> Void;
	var finishedTalking = false;
	public function startLooking() {
		sprite.animation.play("stand");
	}

	public function onMuseumFull(onFinish: Void -> Void) {
		sprite.animation.play("happy", true, true);
		new Timeout(0.6, () -> {
			var b = new SpeechBubble(this);
			bubble = b;
			finishedTalking = false;
			this.onFinishTalk = onFinish;
			b.x = 32;
			b.y = -4;
			active = true;

			sprite.animation.play("talk");
			var text = "My goodness, The museum is filled to the brim! Everyone loves it! Hon, what a great job you have done";

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
		});
	}

	public function gotFish(fish: Data.Fish, onFinish: Void -> Void) {
		sprite.animation.play("happy");
		new Timeout(0.6, () -> {
			var b = new SpeechBubble(this);
			bubble = b;
			finishedTalking = false;
			this.onFinishTalk = onFinish;
			b.x = 32;
			b.y = -4;
			active = true;

			sprite.animation.play("talk");
			var text = switch (fish.ID) {
				case Basic: "A small one, and very cute. The kids will really like it!";
				case Basic2: "What a round little fella! Thank you!";
				case Eel: "An eel! This one has to be handled with care!";
				case Jelly: "Slimy! My mom used to make jelly jelly out of these back when I was young";
				case Snekris: "What a long one! It looks just like Robert! He will surely enjoy looking at it";
				case Biggo: "Oh my lord, this is a huge fish! What a frightening creature";
				case Cthulhu: ".... If this is what I think it is... then the whole town has your gratitude.";

				default: "Thank you so much! This will be a great addition to the collection!";
			}

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
		});
	}

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
				"Take care hon",
				"Feel free to visit the museum, there is so much to learn!",
				"Don't go too far at sea, you never know what lives in the depths",
				"Come back any time!",
			];

			var unfinishedPrompts = [
				"The museum gladly accepts donations of different species of fish",
				"We are trying our best to find more objects to place in the museum",
			];

			var finishedPrompts = [
				"The museum is such a success, all thanks to you hon!",
				"Kids and old people all flock to look at all the wonderful sealife in the museum!",
				"Thank you so much hon!"
			];

			if (d.hasDonatedAllFish) {
				prompts = prompts.concat(finishedPrompts);
			} else {
				prompts = prompts.concat(unfinishedPrompts);
			}

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