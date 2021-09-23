package entities;

import elke.T;
import elke.entity.Entity2D;

class ArcingItem extends Entity2D {
	var x0: Float = 0.;
	var y0: Float = 0.;
	var x1: Float = 0.;
	var y1: Float = 0.;

	public var onFinish: Void -> Void;

	var hoverTime = 0.;
	var totalHoverTime = 1.8;
	var hovering = true;

	var arcTime = 0.;
	var totalArcTime = 0.6;

	var finished = false;

	public function new(?p, xFrom, yFrom, xTo, yTo, ?onFinish) {
		super(p);

		x0 = xFrom;
		y0 = yFrom;
		x1 = xTo;
		y1 = yTo;

		this.onFinish = onFinish;
		x = x0;
		y = y0;
	}

	override function update(dt:Float) {
		super.update(dt);

		if (finished) {
			return;
		}

		if (hovering) {
			hoverTime += dt;
			hoverTime = Math.min(hoverTime, totalHoverTime);

			y = Math.round(y0 + Math.sin((hoverTime / totalHoverTime) * Math.PI * 8.) * 3 * (1 - T.smoothstep(0, totalHoverTime * 0.8, hoverTime)));

			if (hoverTime >= totalHoverTime) {
				hovering = false;
			}

			return;
		}

		arcTime += dt;
		arcTime = Math.min(arcTime, totalArcTime);

		var arcInterp = T.smoothstep(0, 1, arcTime / totalArcTime);
		var dx = x1 - x0;
		var dy = y1 - y0;

		x = Math.round(x0 + arcInterp * dx);
		var bY = -Math.sin(T.smootherstep(0, 1, arcTime / totalArcTime) * Math.PI) * 32.;
		y = Math.round(y0 + dy * (arcTime / totalArcTime) + bY);

		if (arcTime >= totalArcTime) {
			finished = true;
			if (onFinish != null) {
				onFinish();
			}
		}
	}
}