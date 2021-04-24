package entities;

import h2d.RenderContext;
import h2d.Graphics;

class Rope extends Graphics {
    public var fromX = 0.;
    public var fromY = 0.;

    public var toX = 0.0;
    public var toY = 0.0;

    public function new(?p) {
        super(p);
        //filter = new h2d.filter.Outline(1, 0x11222222);
        alpha = 0.4;
    }

    override function draw(ctx:RenderContext) {
        super.draw(ctx);
        clear();
        lineStyle(2, 0xffffff);
        moveTo(fromX, fromY);
        lineTo(toX, toY);
    }
}