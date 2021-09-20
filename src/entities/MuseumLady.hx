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

	public function talkTo(onFinish : Void -> Void) {
		var b = new SpeechBubble(this);
		b.x = 32;
		var t = new Text(hxd.Res.fonts.equipmentpro_medium_12.toFont(), b.content);
		t.textColor = 0x111111;
		var d = GameSaveData.getCurrent();
		if (d.talkedToMuseumLady == 0) {
			t.text = "Good day fisher boy!";
		} else if (d.talkedToMuseumLady == 1) {
			t.text = "The Museum needs more things to look at";
		} else if (d.talkedToMuseumLady == 2) {
			t.text = "If you bring me fish, the townspeople will gladly pay for museum tickets";
		} else if (d.talkedToMuseumLady == 3) {
			t.text = "You will of course get a generous cut!";
		} else {
			t.text = "Have a blessed day!";
		}

		d.talkedToMuseumLady ++; 

		t.maxWidth = 150;
		new Timeout(0.8, () -> {
			b.close();
			onFinish();
		});
	}
}