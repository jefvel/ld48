package entities;

import h2d.Bitmap;
import h2d.Object;

class DepthMeter extends Object {
    var bar: Bitmap;
    var indicator: Bitmap;

    public var maxDepth = 13000.0;
    public var depth(default, set) = 0.0;

    public var weight = 0.0;
    public var totalWeight = 0.0;

    public function new(?p) {
        super(p);
        bar = new Bitmap(hxd.Res.img.horizontalbar.toTile(), this);
        indicator = new Bitmap(hxd.Res.img.hookindicator.toTile(), this);
        indicator.tile.dy = -7;
        indicator.tile.dx = -8;
        indicator.x = -8;
    }

    function set_depth(d) {
        indicator.y = 2 + Math.round((depth / maxDepth) * 252);
        return depth = d;
    }
}