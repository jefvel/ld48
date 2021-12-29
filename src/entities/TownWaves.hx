package entities;

import h2d.Tile;
import h2d.Bitmap;
import elke.entity.Entity2D;

class TownWaves extends Entity2D {
	var b: Bitmap;

	var pY = -0.;
	var waves: Bitmap;
	public function new(water:levels.Levels.Entity_Water, ?p) {
		super(p);
		x = water.pixelX;
		y = water.pixelY - pY;
		b = new Bitmap(Tile.fromColor(0x4c93ad), this);
		b.tile.scaleToSize(water.width, water.height + pY * 2);
		waves = new Bitmap(hxd.Res.img.townwaves.toTile(), b);
		waves.y = -16;

		clip = new Bitmap(Tile.fromColor(0xffffff), waves);
		clip.scaleX = waves.tile.width;
		clip.scaleY = waves.tile.height;
		waves.filter = new h2d.filter.Mask(clip, false, true);
		alpha = 0.9;
	}
	var clip: Bitmap;

	var time = 0.;
	override function update(dt:Float) {
		super.update(dt);
		time += dt;
		b.y = Math.round(Math.sin(time * 0.5) * 4);
		waves.x = Math.sin(time * 0.8) * 32. - 32;
		clip.x = -waves.x + 1;
	}
}