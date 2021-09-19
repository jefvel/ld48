package entities;

import h2d.Bitmap;
import h2d.Tile;
import h2d.Object;

class ProgressDots extends Object {
	public var max(default, set) = 4;
	public var value(default, set) = 0;

	public var width(default, null) = 0;
	public var height(default, null) = 0;

	var dots : Array<Bitmap> = [];
	var offTile : Tile = null;
	var onTile : Tile = null;

	var dotWidth = 8;
	var dotHeight = 16;

	public function new(max: Int, ?p) {
		super(p);
		var t = hxd.Res.img.progressdots.toTile();

		offTile = t.sub(0, 0, 8, 16);
		onTile = t.sub(8, 0, 8, 16);

		this.max = max;

		height = dotHeight;
	}

	function set_value(v) {
		if (v == value) {
			return v;
		}

		for (i in 0...dots.length) {
			var t = v > i ? onTile : offTile;
			dots[i].tile = t;
		}

		return this.value = v;
	}

	function set_max(m) {
		if (m == this.max) {
			return m;
		}

		for (d in dots) {
			d.remove();
			dots.remove(d);
		}

		for (i in 0...m) {
			var s = new Bitmap(offTile);
			s.x = i * dotWidth;
			addChild(s);
			dots.push(s);
		}

		width = m * dotWidth - 1;

		return this.max = m;
	}
}