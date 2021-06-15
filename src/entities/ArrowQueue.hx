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

	public var bonusKills = 0;

	public var onCatch:(Fish, Bool)->Void;
	public var onMiss:(Fish, ?Bool) ->Void;

	var state : PlayState;

    var punchSounds: Array<Sound>;

	public function new(state, ?p) {
		super(p);

		this.state = state;

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

	function removeCollection(c: ArrowCollection) {
		arrowCollections.remove(c);
		c.remove();
	}

    function popCollection() {
        var c = arrowCollections.shift();
        if (c != null) {
            c.remove();
        }
    }

	/// if true, bonus kills will ignore which kind of fish is auto killed
	public var bonusKillsAllowAnyKind = false;

	var visibleCollections = 2;

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
				onCatch(current.fish, false);
                popCollection();
				bgshine.alpha = 1.0;

				// Get bonus kills
				for (_ in 0...bonusKills) {
					for (col in arrowCollections) {
						if (bonusKillsAllowAnyKind || col.fish.data.ID == current.fish.data.ID) {
							onCatch(col.fish, true);
							removeCollection(col);
							break;
						}
					}
				}

			}

			// Game.instance.freeze(0.01);

			squareScale = .2;
            return true;
		} else {
            popCollection();
			onMiss(current.fish);

			var toPush = [];
			
			// Push missed bonus fish to back of queue
			for (col in arrowCollections) {
				if (toPush.length >= bonusKills) {
					break;
				}

				if (bonusKillsAllowAnyKind || col.fish.data.ID == current.fish.data.ID) {
					toPush.push(col);
				}
			}

			for (c in toPush) {
				state.pushFishToBackOfQueue(c.fish);
			}

            return false;
		}
	}

	public function pushFishToBack(f: Fish) {
		for (c in arrowCollections) {
			if (c.fish == f) {
				arrowCollections.remove(c);
				arrowCollections.push(c);
				return;
			}
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

		var toHide = bonusKills;

		var bonusKillsClear = new Map<Data.FishKind, Int>();
		var bonusStackPositions = new Map<Data.FishKind, Float>();
		var lastColVisible = false;
		var lastWidth = 0.;

		var totalVisible = 0;

		for (c in arrowCollections) {
			var id = c.fish.data.ID;
			if (!bonusKillsClear.exists(id)) {
				bonusKillsClear[id] = 0;
			}

			var hiddenCompletely = false;

			var colVisible = false;

			if (bonusKillsClear[id] == 0) {
				colVisible = true;
			}

			if (bonusKillsClear[id] > bonusKills) {
				colVisible = true;
			}

			if (totalVisible >= visibleCollections) {
				hiddenCompletely = true;
			}

			if (colVisible) {
				sx += lastWidth;
			}


			if (colVisible) {
				c.x += (sx - c.x) * 0.3;
				bonusStackPositions[id] = c.x;
				c.y = 0;
				totalVisible ++;
			} else {
				c.x += (bonusStackPositions[id] - c.x) * 0.3;
				c.y += (40 * bonusKillsClear[id] - c.y) * 0.4;
			}

			var targetAlpha = 1.0;

			if (!colVisible) {
				targetAlpha = 0.1;
			}

			c.alpha += (targetAlpha - c.alpha) * 0.3;

			c.visible = !hiddenCompletely;

            c.update(dt);

			lastColVisible = colVisible;

			bonusKillsClear[id] ++;
			lastWidth = c.width + 16;
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
