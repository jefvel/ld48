package gamestates;

import entities.PopText;
import entities.Shop;
import entities.ArrowQueue;
import entities.Rope;
import hxd.Key;
import entities.Sky;
import entities.Bg;
import entities.Hook;
import h2d.Bitmap;
import entities.Fish;
import entities.Fisher;
import entities.ExampleEntity;
import h2d.Object;
import hxd.snd.effect.ReverbPreset;
import elke.graphics.Transition;
import h2d.Text;
import hxd.Event;

enum Direction {
	Up;
	Right;
	Down;
	Left;
}

enum FishingPhase {
	Throwing;
	Sinking;
	PreparingReel;
	ReelingIn;
	Catching;
	Shopping;
}

class PlayState extends elke.gamestate.GameState {
	var container:Object;
	var world:Object;

	var fishContainer:Object;
	var killedFishContainer: Object;

	public var fisher:Fisher;

	public var rope:Rope;

	var hook:Hook;
	var boat:Bitmap;

	var bg:Bg;
	var sky:Sky;

	var allFish:Array<Fish>;

	public var gold = 0;

	public var currentRound = 0;

	public var maxCatchTime = 10.0;
	public var catchTime = 10.0;

	public var reelLength = 450;

	public var catchRadius = 32.0;
	public var maxWeight = 1.0;

	public var caughtFish:Array<Fish>;
	public var caughtWeight = 0.0;

	public var killedFish:Array<Fish>;

	public var currentDepth = 0.0;

	public var sinkSpeed = 2.0;
	public var sinkMultiplier = 1.0;

	public var boostMultiplier = 3.0;
	public var boostTime = 0.0;

	public var started = false;
	public var currentPhase = Throwing;

	public var arrows:ArrowQueue;

	public var shop: Shop;

	public var unlocked : Map<Data.Items_Type, Int>;

	public function new() {}

	override function onEnter() {
		super.onEnter();

		container = new Object(game.s2d);
		bg = new Bg(container);

		world = new Object(container);
		sky = new Sky(world);

		killedFishContainer = new Object(world);
		fisher = new Fisher(world);
		rope = new Rope(world);
		hook = new Hook(this, world);
		fishContainer = new Object(world);

		arrows = new ArrowQueue(container);
		arrows.onCatch = onCatch;
		arrows.onMiss = onMiss;

		boat = new Bitmap(hxd.Res.img.boat.toTile(), world);
		boat.tile.dx = -32;
		boat.tile.dy = -18;

		fisher.y = 0;
		fisher.x = Const.SEA_WIDTH >> 1;

		shop = new Shop(this, container);

		newGame();
	}

	public function newGame() {
		currentRound = 0;

		resetPurchases();
		reset();
	}

	public function resetPurchases() {
		unlocked = new Map<Data.Items_Type, Int>();

		unlocked.set(Line, 0);
		unlocked.set(Strength, 0);
		unlocked.set(MoneyMultiplier, 0);
	}

	function onCatch(f:Fish) {
		caughtFish.remove(f);
		putFishOnPile(f);
		f.kill();
	}

	function onMiss(f:Fish) {
		caughtFish.remove(f);
		f.flee();
	}

	public function reset() {
		currentDepth = 0.0;
		currentPhase = Throwing;
		started = false;

		hook.x = fisher.x + fisher.rodX;
		hook.y = fisher.y + fisher.rodY;
		hook.reset();

		allFish = [];
		caughtFish = [];
		killedFish = [];
		caughtWeight = 0.0;
		fishContainer.removeChildren();

		boat.x = fisher.x;

		arrows.reset();

		spawnFish();
	}

	public function spawnFish() {
		for (f in Data.fish.all) {
			var amount = Math.round(f.Amount * (0.6 + Math.random() * 0.4));
			amount = Std.int(Math.max(1, amount));

			for (_ in 0...amount) {
				var fish = new Fish(f, fishContainer);
				allFish.push(fish);
			}
		}
	}

	function launchHook(boostTime = 0.0) {
		started = true;
		this.boostTime = boostTime;
		timeuntilReel = totalTimeUntilReel;
		hook.start();

		catchTime = maxCatchTime;
		currentPhase = Sinking;
	}

	function reelIn() {
		catchTime = 0.0;
		currentPhase = ReelingIn;
		timeUntilCatching = totalTimeUntilCatching;
	}

	function startCatch() {
		currentPhase = Catching;
		arrows.reset();
		timeUntilDone = totalTimeUntilDone;
		for (f in caughtFish) {
			if (f.dead) {
				onCatch(f);
				continue;
			}
			arrows.addArrow(f, f.pattern);
		}
	}

	function finishRound() {
		currentPhase = Shopping;
		currentRound ++;
		openShop();
	}

	function openShop() {
		shop.show();
		hxd.Res.sound.openshop.play(false, 0.6);
	}

	function closeShop() {
		shop.close();
		hxd.Res.sound.closeshop.play(false, 0.6);
		reset();
	}

	public var downPressed = false;
	public var leftPressed = false;
	public var upPressed = false;
	public var rightPressed = false;

	public var usePressed = false;

	function directionPressed(dir:Direction, repeat = false) {
		if (!started && currentPhase == Throwing && !repeat) {
			if (dir == Down) {
				launchHook(2.0);
				return;
			}
		}

		if (currentPhase == Catching && !repeat) {
			if (!arrows.isFinished()) {
				if (arrows.onDirPress(dir)) {
					fisher.punch();
				}
			}
		}

		if (currentPhase == Shopping) {
			shop.directionPressed(dir);
		}
	}

	function onUse() {
		if (currentPhase == Shopping) {
			shop.usePressed();
		}
	}

	function directionReleased(dir:Direction) {}

	override function onEvent(e:Event) {
		if (e.kind == EKeyDown) {
			if (e.keyCode == Key.LEFT || e.keyCode == Key.A) {
				directionPressed(Left, leftPressed);
				if (!leftPressed) {
					leftPressed = true;
				}
			}

			if (e.keyCode == Key.RIGHT || e.keyCode == Key.D) {
				directionPressed(Right, rightPressed);
				if (!rightPressed) {
					rightPressed = true;
				}
			}

			if (e.keyCode == Key.DOWN || e.keyCode == Key.S) {
				directionPressed(Down, downPressed);
				if (!downPressed) {
					downPressed = true;
				}
			}

			if (e.keyCode == Key.UP || e.keyCode == Key.W) {
				directionPressed(Up, upPressed);
				if (!upPressed) {
					upPressed = true;
				}
			}

			if (e.keyCode == Key.SPACE || e.keyCode == Key.E || e.keyCode == Key.ENTER) {
				if (!usePressed) {
					usePressed = true;
					onUse();
				}
			}
		}

		if (e.kind == EKeyUp) {
			if (e.keyCode == Key.LEFT || e.keyCode == Key.A) {
				if (leftPressed) {
					leftPressed = false;
					directionReleased(Left);
				}
			}

			if (e.keyCode == Key.RIGHT || e.keyCode == Key.D) {
				if (rightPressed) {
					rightPressed = false;
					directionReleased(Right);
				}
			}

			if (e.keyCode == Key.DOWN || e.keyCode == Key.S) {
				if (downPressed) {
					downPressed = false;
					directionReleased(Down);
				}
			}

			if (e.keyCode == Key.UP || e.keyCode == Key.W) {
				if (upPressed) {
					upPressed = false;
					directionReleased(Up);
				}
			}

			if (e.keyCode == Key.SPACE || e.keyCode == Key.E || e.keyCode == Key.ENTER) {
				if (usePressed) {
					usePressed = false;
				}
			}
		}

		#if debug
		if (e.kind == EKeyDown) {
			if (e.keyCode == Key.O) {
				finishRound();
			}
			if (e.keyCode == Key.P) {
				closeShop();
			}
		}
		#end
	}

	var time = 0.0;

	var vy = 0.0;

	var totalTimeUntilReel = 0.5;
	var timeuntilReel = 0.5;

	var totalTimeUntilCatching = 1.0;
	var timeUntilCatching = 0.4;

	var timeUntilDone = 0.6;
	var totalTimeUntilDone = 1.6;

	public function putFishOnPile(f: Fish) {
		killedFish.push(f);
		f.rotation = 0;
		f.sprite.rotation = Math.random() * Math.PI * 2;
		f.sprite.originX = Std.int(f.sprite.tile.width * 0.5);
		f.sprite.originY = Std.int(f.sprite.tile.height * 0.5);
		killedFishContainer.addChild(f);
		f.x = Math.random() * 50 - 25 - 4;
		f.bounce();
		f.y = Math.floor(killedFish.length * 0.2) * 8;

		var t = new PopText('${f.data.SellPrice}', container);
		var p = f.localToGlobal();
		t.x = p.x;
		t.y = p.y;
	}

	override function update(dt:Float) {
		super.update(dt);
		if (shop.showing) {
			world.x += (500 - world.x) * 0.1;
		} else {
			world.x += ((-Const.SEA_WIDTH * 0.5 + game.s2d.width * 0.5) - world.x) * 0.2;
		}

		rope.fromX = fisher.x + fisher.rodX;
		rope.fromY = fisher.y + fisher.rodY;
		rope.weight = caughtWeight;
		rope.maxWeight = maxWeight;

		world.y = (-currentDepth + game.s2d.height * 0.5);
		time += dt;

		boat.y = Math.round(fisher.y + Math.sin(time) * 2);
		killedFishContainer.x = boat.x;
		killedFishContainer.y = boat.y - 8;

		if (!started) {
			return;
		}

		if (currentPhase == Sinking) {
			catchTime -= dt;
			boostTime -= dt;

			var boosting = false;

			if (boostTime > 0) {
				boosting = true;
			} else {
				boostTime = 0.0;
			}

			var dy = (reelLength - currentDepth) * 0.02;

			vy = sinkSpeed;
			sinkMultiplier += (1.0 - sinkMultiplier) * 0.2;

			if (boosting) {
				sinkMultiplier = boostMultiplier;
			}

			vy *= sinkMultiplier;

			if (Math.abs(reelLength - currentDepth) < 10.0) {
				catchTime *= 0.99;
			}

			if (caughtWeight >= maxWeight) {
				catchTime *= 0.5;
			}

			dy = Math.min(dy, vy);

			currentDepth += dy;

			var rr = catchRadius * catchRadius;
			if (caughtWeight < maxWeight) {
				for (f in allFish) {
					var dx = hook.x - f.x;
					var dy = hook.y - f.y;

					if (dx * dx + dy * dy < rr) {
						caughtFish.push(f);
						allFish.remove(f);
						caughtWeight += f.data.Weight;
						if (boosting) {
							f.kill();
						}
					}
				}
			}

			if (catchTime <= 0.0) {
				currentPhase = PreparingReel;
				return;
			}
		}

		for (f in caughtFish) {
			var dx = hook.x - f.x;
			var dy = hook.y + 7 - f.y;

			if (Math.abs(dx) > 0.001 || Math.abs(dy) > 0.001) {
				f.rot = Math.atan2(dy, dx);
			}

			f.rotation = f.rot + (Math.random() * 0.1 - 0.05);

			f.x += dx * 0.9;
			f.y += dy * 0.9;
		}

		if (currentPhase == PreparingReel) {
			timeuntilReel -= dt;
			if (timeuntilReel <= 0) {
				reelIn();
				return;
			}
		}

		if (currentPhase == ReelingIn) {
			var vy = -currentDepth * 0.1;
			vy = Math.max(-10, vy);
			currentDepth = Math.max(0.0, hook.y);
			if (currentDepth <= 10) {
				timeUntilCatching -= dt;
				if (timeUntilCatching <= 0) {
					startCatch();
				}
			}
		}

		if (currentPhase == Catching) {
			if (arrows.isFinished()) {
				timeUntilDone -= dt;
				if (timeUntilDone <= 0) {
					finishRound();
				}
			}
		}
	}

	override function onLeave() {
		super.onLeave();
	}
}
