package entities;

import h2d.filter.Outline;
import elke.T;
import h2d.RenderContext;
import h2d.Graphics;

class Rope extends Graphics {
    public var fromX = 0.;
    public var fromY = 0.;

    public var toX = 0.0;
    public var toY = 0.0;

    public var weight = 0.0;
    public var maxWeight = 0.0;
    var ff : Outline;

    public function new(?p) {
        super(p);
        //filter = new h2d.filter.Outline(1, 0x11222222);
        //ff = new Outline(1);
        alpha = 0.7;
    }

    override function draw(ctx:RenderContext) {
        super.draw(ctx);
        clear();
        var color = 0xff0000;
        var r = T.smoothstep(0.6, 1.0, (weight / maxWeight));
        var f = Std.int(0xff * (1. - r));
        color = 0xFF0000 | f << 8 | f; 

        lineStyle(2, color);
        moveTo(fromX, fromY);
        lineTo(toX, toY);
        //filter = ff;
    }
}