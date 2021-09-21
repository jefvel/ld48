package entities;

import elke.T;
import h2d.Bitmap;
import h2d.Tile;
import elke.entity.Entity2D;

typedef Seaweed = {
	bm: Bitmap,
	x: Float,
	y: Float,
	d: Float,
}

class Seaweeds extends Entity2D {
	var tiles: Array<Tile>;
	var objs : Array<Seaweed>;

	static inline final WEED_COUNT = 64;

	public function new(?p) {
		super(p);
		var t = hxd.Res.img.seaweeds.toTile();
		tiles = [];
		objs = [];

		var ts = 32;
		for (x in 0...Std.int(t.width/ts)) {
			for (y in 0...Std.int(t.height/ts)) {
				tiles.push(t.sub(x * ts, y * ts, ts, ts));
			}
		}

		for (i in 0...WEED_COUNT) {
			var s: Seaweed = {
				bm: new Bitmap(tiles[Std.int(Math.random() * tiles.length)], this),
				x: Math.random() * Const.SCREEN_WIDTH - 128,
				y: Math.random() * Const.SCREEN_HEIGHT + 200 + 800 * Math.random(), 
				d: 0.76 + Math.random() * 0.2,
			}

			s.bm.alpha = 0.8 - T.smoothstep(0.75, 0.86, s.d) * 0.7;
			s.bm.x = s.x;
			s.bm.y = s.y;

			objs.push(s);
		}

		alpha = 0.45;
	}

	override function update(dt:Float) {
		super.update(dt);
		var g = localToGlobal();
		for (o in objs) {
			o.bm.y = o.y - g.y * o.d;
			if (g.y + o.bm.y < -32) {
				o.bm.tile = tiles[Std.int(Math.random() * tiles.length)];
				o.d = 0.76 + Math.random() * 0.2;
				o.y += 800 / o.d + Math.random() * 32;
				o.bm.alpha = 0.9 - T.smoothstep(0.75, 0.86, o.d) * 0.7;
			}
		}
	}
}