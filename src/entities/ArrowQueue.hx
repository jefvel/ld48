package entities;

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

class ArrowCollection extends Object {
	public var fish:Fish;
	public var arrows:Array<Arrow>;

	var cleared = 0;

	public var width = 0.0;

	static var arrowW = 32;

	public function new(fish:Fish, dirs:Array<Direction>, ?p) {
		super(p);
		this.fish = fish;
		arrows = [];
		var tx = 0;

		for (d in dirs) {
			var arrow = new Arrow(d, this);
			arrow.x = (arrowW) * tx;
			tx++;
			arrows.push(arrow);
		}
	}

	public function update(dt: Float) {
		this.width = (arrows.length * arrowW);
		var tx = 0;
		for (arrow in arrows) {
			arrow.x += (arrowW * tx - arrow.x) * 0.8;
			tx++;
		}
	}

	public function popArrow() {
		var arrow = arrows.shift();
		arrow.remove();
		cleared++;
	}
}

class ArrowQueue extends Entity2D {
	public var queue:Array<Arrow>;
	var bgshine:Bitmap;
	var bg: Bitmap;
	var square: Bitmap;
	var arrowStuff: Object;

	var arrowCollections:Array<ArrowCollection>;

	public var onCatch:Fish->Void;
	public var onMiss:Fish->Void;

    var punchSounds: Array<Sound>;

	public function new(?p) {
		super(p);
		bgshine = new Bitmap(hxd.Res.img.arrowsbgshine.toTile(), this);
		bgshine.tile.dx = bgshine.tile.dy = -4;
		bgshine.x = bgshine.y = -4;
		bgshine.alpha = 0.0;

		bg = new Bitmap(hxd.Res.img.arrowqueuebg.toTile(), this);
		bg.x = -4;
		bg.y = -4;
		bg.alpha = 0;


		square = new Bitmap(hxd.Res.img.arrowqueuesquare.toTile(), this);
		square.tile.dx = square.tile.dy = -20;
		square.x = 16;
		square.y = 16;
		square.alpha = 0.0;

		arrowStuff = new Object(this);

		queue = [];
        punchSounds = [
            hxd.Res.sound.punch1,
            hxd.Res.sound.punch2,
            hxd.Res.sound.punch3,
            hxd.Res.sound.punch4,
            hxd.Res.sound.punch5,
            hxd.Res.sound.punch6,
        ];
	}

    public function isFinished() {
        return arrowCollections.length == 0;
    }

	public function reset() {
		arrowStuff.removeChildren();
		queue = [];
		arrowCollections = [];
	}

    function popCollection() {
        var c = arrowCollections.shift();
        if (c != null) {
            c.remove();
        }
    }

	var squareScale = .0;
	public function onDirPress(dir:Direction) {
        if (arrowCollections.length == 0) {
            return false;
        }

		var current = arrowCollections[0];
		if (dir == current.arrows[0].dir) {
			current.popArrow();
            var s = punchSounds[Std.int(Math.random() * punchSounds.length)];
			s.play(false, 0.5);

			if (current.arrows.length == 0) {
				onCatch(current.fish);
                popCollection();
				bgshine.alpha = 1.0;
			}

			//Game.instance.freeze(0.05);

			squareScale = .2;
            return true;
		} else {
            popCollection();
			onMiss(current.fish);
            return false;
		}
	}

    public function failAll() {
        for(c in arrowCollections) {
            onMiss(c.fish);
        }
        arrowCollections = [];
    }

	override function update(dt:Float) {
		super.update(dt);
		var sx = 0.0;

		x = getScene().width >> 1;
        y = 78;

		for (c in arrowCollections) {
			c.x += (sx - c.x) * 0.3;
			sx += c.width + 16;
            c.update(dt);
		}

		var targetAlpha = 0.0;
		if (!isFinished()) {
			targetAlpha = 1;
		}

		bg.alpha += (targetAlpha * 0.4 - bg.alpha) * 0.3;
		bgshine.alpha *= 0.82;

		square.alpha  += (targetAlpha * 0.7 - square.alpha) * 0.3;
		squareScale *= 0.76;
		square.setScale(squareScale + 1);
	}

	public function addArrow(f:Fish, dir:Array<Direction>) {
		var c = new ArrowCollection(f, dir, arrowStuff);
		arrowCollections.push(c);
	}
}
