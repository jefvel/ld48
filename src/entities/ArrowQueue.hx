package entities;

import h2d.Tile;
import elke.entity.Entity2D;

enum ArrowDirection {
	Up;
	Left;
	Down;
	Right;
}

class ArrowQueue extends Entity2D {
	public var queue:Array<ArrowDirection>;

    var upTile: Tile;
    var downTile: Tile;
    var leftTile: Tile;
    var rightTile: Tile;

	public function new(?p) {
		super(p);
		queue = [];

        var bm = hxd.Res.img.arrows.toTile();
        var tw = 32;

        rightTile = bm.sub(0, 0, tw, tw);
        downTile = bm.sub(tw, 0, tw, tw);
        leftTile = bm.sub(0, tw, tw, tw);
        upTile = bm.sub(tw, tw, tw, tw);
	}

	public function addArrow(dir:ArrowDirection) {
		queue.push(dir);
	}
}
