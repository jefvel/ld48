package entities;

import h2d.filter.DropShadow;
import h2d.Object;
import h2d.Bitmap;
import h2d.Text;
import h2d.Tile;
import h2d.Interactive;

class TextButton extends Interactive {
	var bm : Bitmap;
	var label : Text;
	var sInc = 0.0;
	var baseScale = 0.0;

	public var pressed = false;
	var bmContainer : Object;

	public function new(t: Tile, label: String, ?onPress: Void -> Void, ?onRelease: Void -> Void, ?p) {
		super(0, 0, p);
		bmContainer = new Object(this);
		bm = new Bitmap(t, bmContainer);
		this.label = new Text(hxd.Res.fonts.picory.toFont(), this);
		this.label.x = t.width + 4;

		this.label.dropShadow = {
			dx: 1,
			dy: 1,
			alpha: 0.4,
			color: 0x000000,
		}

		bm.tile.dx = -16;
		bm.tile.dy = -16;
		bm.x += 16;
		bm.y += 16;

		this.onPush = e -> {
			pressed = true;
			if (onPress != null) {
				onPress();
			}
		}

		this.onRelease = e -> {
			pressed = false;
			if (onRelease != null) {
				onRelease();
			}
		}

		this.onReleaseOutside = e -> {
			pressed = false;
		}

		setText(label);
	}

	public function setText(t) {
		this.label.text = t;
		this.label.y = Math.round((bm.tile.height - this.label.textHeight) * 0.5) + 1;

		var b = getBounds();
		this.width = b.width;
		this.height = b.height;
	}

	public function update(dt: Float) {
		sInc *= 0.7;
		bm.setScale(1 + baseScale + sInc);
	}

	public function activate() {
		onTap();
		baseScale = 0.1;
	}

	public function deactivate() {
		baseScale = 0.0;
		sInc = -0.2;
	}

	public function onTap() {
		sInc = 0.4;
		hxd.Res.sound.buttonpress.play(false, 0.56);
	}
}
