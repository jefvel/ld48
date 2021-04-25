package entities;

import h2d.Bitmap;
import h2d.Object;

class DepthMeter extends Object {
    var bar: Bitmap;
    var indicator: Bitmap;

    public var maxDepth = 13000.0;
    public var depth(default, set) = 0.0;


    public var full(default, set) = false;
    var weight : Bitmap;

    public function new(?p) {
        super(p);
        bar = new Bitmap(hxd.Res.img.horizontalbar.toTile(), this);
        indicator = new Bitmap(hxd.Res.img.hookindicator.toTile(), this);
        indicator.tile.dy = -7;
        indicator.tile.dx = -8;
        indicator.x = -8;
        weight = new Bitmap(hxd.Res.img.weight.toTile(), this);
        weight.x = -70;
        weight.visible = false;
    }

    function set_full(f) {
        weight.visible = f;
        return full = f;
    }

    function set_depth(d) {
        indicator.y = 2 + Math.round((depth / maxDepth) * 252);
        return depth = d;
    }
}