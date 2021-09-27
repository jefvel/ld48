package entities;

import gamestates.PlayState.Direction;
import h2d.Tile;
import h2d.Bitmap;

class Arrow extends Bitmap {
	static var upTile:Tile;
	static var downTile:Tile;
	static var leftTile:Tile;
	static var rightTile:Tile;

	public var dir:Direction;

	public function new(d:Direction, ?p) {
		if (upTile == null) {
			var bm = hxd.Res.img.arrows.toTile();
			var tw = 32;

			rightTile = bm.sub(0, 0, tw, tw);
			downTile = bm.sub(tw, 0, tw, tw);
			leftTile = bm.sub(0, tw, tw, tw);
			upTile = bm.sub(tw, tw, tw, tw);
		}

		var t = switch (d) {
			case Up: upTile;
			case Left: leftTile;
			case Right: rightTile;
			case Down: downTile;
		}

		super(t, p);
		dir = d;
	}
}
