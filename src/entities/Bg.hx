package entities;

import hxd.fmt.grd.Data.ColorStop;
import hxd.fmt.grd.Data.Gradient;
import h3d.mat.Texture;
import h3d.Vector;
import h2d.Tile;
import h2d.RenderContext;
import h2d.Bitmap;

class Bg extends Bitmap {
    var gradient: hxd.BitmapData;
    public var ratio = 0.0;
	public function new(?p) {
		//var t = Tile.fromColor(0x4970a6);
        var t= Tile.fromColor(0xFFFFFF);
		super(t, p);
        color = new Vector();
        gradient = hxd.Res.img.gradient.toBitmap();
	}

	override function sync(ctx:RenderContext) {
		super.sync(ctx);
        ratio = Math.max(Math.min(1, ratio), 0);
		tile.setSize(this.getScene().width, this.getScene().height);
        var c = gradient.getPixel(Math.floor((ratio * 127)), 0);
        var r = ((c >> 16 & 0xff) / 0xFF);
        var g = ((c >> 8 & 0xFF) / 0xFF);
        var b = ((c >> 0 & 0xFF) / 0xFF);
        color.set(r, g, b);
	}
}
