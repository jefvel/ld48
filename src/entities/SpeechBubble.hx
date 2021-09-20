package entities;

import elke.T;
import h2d.RenderContext;
import h2d.Object;
import h2d.ScaleGrid;
import elke.entity.Entity2D;

class SpeechBubble extends Entity2D {
	var bubble : ScaleGrid;
	var padding = 3;
	var paddingX = 6;
	public var content: Object;
	public function new(?p) {
		super(p);
		bubble = new ScaleGrid(hxd.Res.img.speechbubble.toTile(), 3, 3, 3, 6, this);
		content = new Object(this);
		bubble.x = -paddingX;
	}

	override function sync(ctx:RenderContext) {
		super.sync(ctx);
		var b = content.getBounds();
		bubble.width = b.width + paddingX * 2;
		bubble.height = b.height + padding + 5;
		bubble.y = -b.height - padding;
		content.y = -b.height;
	}

	var tIn = 1.0;

	override function update(dt:Float) {
		super.update(dt);

		tIn -= dt / 0.3;
		tIn = Math.max(0, tIn);
		rotation = T.bounceIn(tIn) * -0.1;

		if (closing) {
			alpha *= 0.9;
			if (alpha <= 0.001) {
				remove();
			}
		}
	}

	var closing = false;
	public function close() {
		closing = true;
	}

}