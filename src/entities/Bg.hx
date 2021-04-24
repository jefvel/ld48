package entities;

import h2d.Tile;
import h2d.RenderContext;
import h2d.Bitmap;

class Bg extends Bitmap {
	public function new(?p) {
		var t = Tile.fromColor(0x4b80ca);
		super(t, p);
	}

	override function sync(ctx:RenderContext) {
		super.sync(ctx);
		tile.setSize(this.getScene().width, this.getScene().height);
	}
}
