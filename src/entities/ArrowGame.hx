package entities;
import gamestates.PlayState;
import elke.process.Timeout;
import elke.Game;
import hxd.res.Sound;
import h2d.RenderContext;
import h2d.Object;
import entities.Fish;
import h2d.Bitmap;
import gamestates.PlayState.Direction;
import h2d.Tile;
import elke.entity.Entity2D;

class ArrowGame extends CatchingGame {
	public var arrows:Array<Arrow>;

	var cleared = 0;

	static var arrowW = 32;

	public function new(fish:Fish, state, ?p) {
		super(fish, state, p);
		arrows = [];

		var tx = 0;
		var dirs = fish.pattern;

		for (d in dirs) {
			var arrow = new Arrow(d, this);
			arrow.x = (arrowW) * tx;
			tx++;
			arrows.push(arrow);
		}

		this.width = (arrows.length * arrowW);
	}

	override public function update(dt: Float) {
		this.width = (arrows.length * arrowW);
		var tx = 0;
		for (arrow in arrows) {
			arrow.x += (arrowW * tx - arrow.x) * 0.8;
			tx++;
		}
	}

	override function onDirectionPress(d:Direction) {
		if (d == arrows[0].dir) {
			popArrow();

			playState.doPunch();

			if (arrows.length == 0) {
				onSuccess();
			}
		} else {
			onFail();
		}
	}

	public function popArrow() {
		var arrow = arrows.shift();
		arrow.remove();
		cleared++;
	}
}
