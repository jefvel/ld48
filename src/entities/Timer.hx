package entities;

import h3d.Vector;
import h2d.Tile;
import h2d.Bitmap;
import elke.entity.Entity2D;
import h2d.Object;

class Timer extends Entity2D {
    var frame : Bitmap;
    var bar: Bitmap;

    public var value = 0.0;
    public var color : Vector;

    public function new(?p) {
        super(p);
        bar = new Bitmap(Tile.fromColor(0xFFFFFF), this);
        frame = new Bitmap(hxd.Res.img.timerbar.toTile(), this);
        bar.x = bar.y = 2;
        bar.tile.setSize(frame.tile.width - 4, frame.tile.height - 4);
        color = bar.color = new Vector(1.0, 1, 1);
    }

    override function update(dt:Float) {
        super.update(dt);
        bar.scaleX = value / 1.0;
        /*
        */
    }
}