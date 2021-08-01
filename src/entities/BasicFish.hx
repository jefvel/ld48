package entities;

import h2d.Bitmap;
import h2d.Tile;
import elke.entity.Entity2D;

class BasicFish extends Entity2D {
	public var fishKind : Data.FishKind;
	public function new(fishKind: Data.FishKind, tile: Tile, ?p) {
		super(p);
		var bm = new Bitmap(tile);

		addChild(bm);

		this.fishKind = fishKind;

		bm.x = -Math.round(tile.width * 0.5);
		bm.y = -Math.round(tile.height * 0.5);
	}
}