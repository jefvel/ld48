package entities;

import h2d.filter.Outline;
import haxe.display.Display.PatternCompletion;
import h2d.Tile;
import h2d.Bitmap;
import h2d.Text;
import h2d.ScaleGrid;
import elke.entity.Entity2D;

class WeightBar extends Entity2D {
	var frame:ScaleGrid;

	public var total = 1.0;
	public var current = 0.0;
    var bar: Bitmap;

	var text: Text;
	
    var weight : Bitmap;

	public function new(?p) {
		super(p);

        bar = new Bitmap(Tile.fromColor(0xFFFFFF), this);

		frame = new ScaleGrid(hxd.Res.img.weightbar.toTile(), 4, 4, 4, 4, this);
		frame.height = 17;
		frame.width = 64;

        bar.x = bar.y = 2;
        bar.tile.setSize(frame.width - 4, frame.height - 4);

		text = new Text(hxd.Res.fonts.picory.toFont(), this);
		text.x = 5;
		text.y = 3;

        weight = new Bitmap(hxd.Res.img.weight.toTile(), this);
        weight.x = -50;
		weight.y = 1;
        weight.visible = false;
	}

	override function update(dt:Float) {
		super.update(dt);

		var number = current;
		var precision = 1;
		number *= Math.pow(10, precision);
    	number = Math.round(number) / Math.pow(10, precision);
		text.text = '${number} kg';

        bar.scaleX = current / total;

		bar.scaleX = Math.min(1, bar.scaleX);
		if (current >= total) {
			bar.color.set(1.0, 0.3, 0.3);
			text.textColor = 0xffffff;
			weight.visible =  true;
		} else {
			bar.color.set(1, 1, 1);
			text.textColor = 0x000000;
			weight.visible =  false;
		}
	}
}