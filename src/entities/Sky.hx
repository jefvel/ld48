package entities;

import graphics.WaterShader;
import h2d.Tile;
import h2d.RenderContext;
import h2d.Bitmap;

class Sky extends Bitmap {
	var s : WaterShader;
	public function new(?p) {
		var t = Tile.fromColor(0x68a5d3);
		super(t, p);
		s = new graphics.WaterShader();
		addShader(s);
		s.texture = hxd.Res.img.water.toTexture();
		s.texture.wrap = Repeat;
		s.amplitude = 0.0004;
		s.frequency = 9.5;
		s.speed = 1.0;
		tileWrap = true;

		s.textureSize.set(s.texture.width, s.texture.height);
	}

	override function sync(ctx:RenderContext) {
		super.sync(ctx);
		width = getScene().width; // * 2;
		height = getScene().height;
		//width = s.texture.width;
		//height = s.texture.height;
		y = 0;
		x = -120;
		//x = Math.round(-width * 0.5);
		s.size.set(width, height);
		s.textureSize.set(s.texture.width, s.texture.height);
	}
}
