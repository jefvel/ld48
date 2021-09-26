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

class Arrow extends Bitmap {
	static var upTile:Tile;
	static var downTile:Tile;
	static var leftTile:Tile;
	static var rightTile:Tile;

	public var dir:Direction;

	public function new(d:Direction, ?p) {
		if (upTile == null) {
			var bm = hxd.Res.img.arrows.toTile();
			var tw = 32;

			rightTile = bm.sub(0, 0, tw, tw);
			downTile = bm.sub(tw, 0, tw, tw);
			leftTile = bm.sub(0, tw, tw, tw);
			upTile = bm.sub(tw, tw, tw, tw);
		}

		var t = switch (d) {
			case Up: upTile;
			case Left: leftTile;
			case Right: rightTile;
			case Down: downTile;
		}

		super(t, p);
		dir = d;
	}
}

class ArrowGame extends CatchingGame {
	public var arrows:Array<Arrow>;

	var cleared = 0;

	static var arrowW = 32;

	static var punchSounds: Array<hxd.res.Sound>;

	public function new(fish:Fish, state, ?p) {
		super(fish, state, p);
		arrows = [];

		if (punchSounds == null) {
			punchSounds = [
				hxd.Res.sound.punch1,
				hxd.Res.sound.punch2,
				hxd.Res.sound.punch3,
				hxd.Res.sound.punch4,
				hxd.Res.sound.punch5,
				hxd.Res.sound.punch6,
			];
		}

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

            var s = punchSounds[Std.int(Math.random() * punchSounds.length)];
			s.play(false, 0.5);

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
