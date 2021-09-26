package entities;

import gamestates.PlayState;
import elke.Game;
import hxd.res.Sound;
import h2d.RenderContext;
import h2d.Object;
import entities.Fish;
import h2d.Bitmap;
import gamestates.PlayState.Direction;
import h2d.Tile;
import elke.entity.Entity2D;


class ArrowQueue extends Entity2D {
	var bgshine:Bitmap;
	var bg: Bitmap;
	public var square: Bitmap;

	var arrowStuff: Object;

	var fishList: Array<Fish>;
	var currentGame: CatchingGame;
	var nextGame: CatchingGame;

	public var bonusKills = 0;

	public var onCatch:(Fish, Bool)->Void;
	public var onMiss:(Fish, ?Bool) ->Void;

	var state : PlayState;

	public function new(state, ?p) {
		super(p);

		this.state = state;

		fishList = [];

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
	}

    public function isFinished() {
        return fishList.length == 0;
    }

	public function reset() {
		arrowStuff.removeChildren();
		fishList = [];
	}

	var squareScale = .0;
	public function onDirPress(dir:Direction) {
		if (currentGame != null) {
			currentGame.onDirectionPress(dir);
			return false;
		}

		return false;
	}

	public function pushFishToBack(f: Fish) {
		fishList.remove(f);
		fishList.push(f);
	}

    public function failAll() {
        for(c in fishList) {
            onMiss(c);
        }

		arrowStuff.remove();

		fishList = [];
    }

	override function update(dt:Float) {
		super.update(dt);

		x = getScene().width >> 1;
        y = 78;

		if (nextGame != null) {
			nextGame.alpha += (1 - nextGame.alpha) * 0.3;
			nextGame.x += ((currentGame.width + 16 + (1 - nextGame.alpha) * 32) - nextGame.x ) * 0.3;
		}

		if (currentGame != null) {
			currentGame.x *= 0.3;
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

	function gameSucceeded() {
		onCatch(currentGame.fish, false);
		fishList.remove(currentGame.fish);

		bgshine.alpha = 1.0;

		// Get bonus kills
		for (_ in 0...bonusKills) {
			for (fish in fishList) {
				if (fish.data.ID == currentGame.fish.data.ID) {
					onCatch(fish, true);
					fishList.remove(fish);
					break;
				}
			}
		}

		nextFish();
	}

	function gameFailed() {
		var currentFish = fishList[0];
		onMiss(currentFish);
		fishList.remove(currentFish);

		var toPush = [];
		
		// Push missed bonus fish to back of queue
		for (fish in fishList) {
			if (toPush.length >= bonusKills) {
				break;
			}

			if (fish.data.ID == currentFish.data.ID) {
				toPush.push(fish);
			}
		}

		for (fish in toPush) {
			state.pushFishToBackOfQueue(fish);
		}

		nextFish();
	}

	function nextFish() {
		var nextFish = fishList[0];
		if (nextFish == null) {
			return;
		}

		if (currentGame != null) {
			currentGame.remove();
			currentGame.onDeactivate();
			currentGame = null;
		}

		if (nextGame != null) {
			currentGame = nextGame;
			nextGame = null;
		}

		if (nextGame == null && currentGame == null) {
			currentGame = getFishGame(nextFish);
		}

		if (nextGame == null) {
			var nextNextFish : Fish = null;
			var i = 0;
			for (f in fishList) {
				if (f == nextFish) {
					continue;
				}
				if (f.data.ID != nextFish.data.ID) {
					nextNextFish = f;
					break;
				} else {
					i ++;
					if (i > bonusKills) {
						nextNextFish = f;
						break;
					}
				}
			}

			if (nextNextFish != null) {
				nextGame = getFishGame(nextNextFish);
			}
		}

		if (currentGame != null) {
			currentGame.stackCount = 1 + bonusKills;
			currentGame.onActivate();
			currentGame.onSuccess = gameSucceeded;
			currentGame.onFail = gameFailed;
			currentGame.alpha = 1;
		}

		if (nextGame != null) {
			nextGame.x = currentGame.width + 8;
			nextGame.alpha = 0;
		}
	}

	function getFishGame(f: Fish): CatchingGame {
		switch (f.data.CatchType) {
			case Arrows: return new ArrowGame(f, state, arrowStuff);
			case Tetris: return new TetrisGame(f, state, arrowStuff);
			default: return new ArrowGame(f, state, arrowStuff);
		}
	}

	public function startGames() {
		nextFish();
	}

	public function addFish(f:Fish) {
		fishList.push(f);
	}
}
