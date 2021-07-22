package entities;

import h2d.Bitmap;
import h2d.Text;
import h2d.Tile;
import h2d.Interactive;

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
