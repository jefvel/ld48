package entities;

import h2d.Tile;
import h2d.RenderContext;
import h2d.Bitmap;

class Sky extends Bitmap {
	public function new(?p) {
		var t = Tile.fromColor(0x68c2d3);
		super(t, p);
	}

	override function sync(ctx:RenderContext) {
		super.sync(ctx);
		tile.setSize(this.getScene().width * 2, this.getScene().height);
		tile.dx = -tile.width * 0.5;
		tile.dy = -tile.height;
	}
}
