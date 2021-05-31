package entities;

import hxd.Perlin;
import h2d.Bitmap;
import h2d.Object;
import elke.entity.Entity2D;

class Sunrays extends Entity2D {
    var w = 500.;
    var bgLayer :Object;

    var shafts : Array<Bitmap>;

    var noise : Perlin;

    public function new(backLayer: Object, frontLayer: Object) {
        super(backLayer);
        bgLayer = backLayer;
        shafts = [];

        noise = new Perlin();
        for (i in 0...3) {
            var shaft = new Bitmap(hxd.Res.img.lightshaft.toTile(), backLayer);
            shaft.x = Math.round(Math.random() * w);
            shafts.push(shaft);
        }
    }

    var time = 0.0;
    override function update(dt:Float) {
        super.update(dt);
        time += dt;
        for (i in 0...shafts.length) {
            var shaft = shafts[i];
            shaft.alpha = noise.perlin1D(434 + i, time *  0.8, 3);
            if (shaft.alpha <= 0) {
                shaft.x = Math.random() * w;
            }
        }
    }
}