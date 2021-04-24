package gamestates;

import entities.Timer;
import entities.BoosterThing;
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
	var killedFishContainer:Object;

	public var fisher:Fisher;

	public var rope:Rope;

	var hook:Hook;
	var boat:Bitmap;

	var bg:Bg;
	var sky:Sky;

	var allFish:Array<Fish>;

	public var gold = 0;

	public var currentRound = 0;

	public var maxBoostTime = 2.0;

	public var maxCatchTime = 10.0;
	public var catchTime = 10.0;

	public var reelLength = 450;

	var strengths = [1.0, 3.0, 10.0, 30.0, 100.0, 300.0];
	var lengths = [450, 1200, 2500, 4000, 8000, 13100];
	var speeds = [2.0, 2.5, 3.1, 5.0, 9.0, 15.0];

	var goldMultiplier = 1.0;
	var multipliers = [1.0, 1.2, 1.5, 1.9, 2.3, 3];

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
	var initialBoostTime = 0.0;

	public var started = false;
	public var currentPhase = Throwing;
	public var waves:Bitmap;

	public var arrows:ArrowQueue;

	public var shop:Shop;

	public var unlocked:Map<Data.Items_Type, Int>;

	public var boosterThing:BoosterThing;
	public var timer:Timer;

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
		var t = hxd.Res.img.waves.toTile();
		t.getTexture().wrap = Repeat;
		waves = new Bitmap(t, world);
		waves.y = -16;
		waves.tileWrap = true;
		waves.tile.setSize(1324, 512);
		waves.x = -555;
		boat.tile.dx = -32;
		boat.tile.dy = -18;

		fisher.y = 0;
		fisher.x = Const.SEA_WIDTH >> 1;

		shop = new Shop(this, container);

		boosterThing = new BoosterThing(container);
		timer = new Timer(container);

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
		unlocked.set(Speed, 0);
	}

	function onCatch(f:Fish) {
		f.kill();
		putFishOnPile(f);
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
		killedFishContainer.removeChildren();

		boat.x = fisher.x;

		arrows.reset();

		maxWeight = strengths[unlocked.get(Strength)];
		reelLength = lengths[unlocked.get(Line)];
		sinkSpeed = speeds[unlocked.get(Speed)];
		goldMultiplier = multipliers[unlocked.get(MoneyMultiplier)];

		boosterThing.reset();
		boosterThing.fadeIn();

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

	function launchHook() {
		started = true;
		boosterThing.fadeOut();

		boostTime = maxBoostTime * (boosterThing.boosts / boosterThing.maxBoosts);
		initialBoostTime = boostTime;

		timeuntilReel = totalTimeUntilReel;
		hook.start();

		catchTime = maxCatchTime;
		currentPhase = Sinking;
		game.sound.playWobble(hxd.Res.sound.throwline, 0.5);
	}

	function reelIn() {
		catchTime = 0.0;
		currentPhase = ReelingIn;
		timeUntilCatching = totalTimeUntilCatching;
		game.sound.playWobble(hxd.Res.sound.reelin, 0.4);
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
		currentRound++;

		for (f in killedFish) {
			gold += Math.ceil(f.data.SellPrice * goldMultiplier);
		}

		openShop();
	}

	function openShop() {
		shop.show();
		hxd.Res.sound.openshop.play(false, 0.6);
		world.filter = new h2d.filter.Blur(5, 0.9, 1.0);
	}

	function closeShop() {
		shop.close();
		hxd.Res.sound.closeshop.play(false, 0.6);
		world.filter = null;
		reset();
	}

	public var downPressed = false;
	public var leftPressed = false;
	public var upPressed = false;
	public var rightPressed = false;

	public var usePressed = false;

	function directionPressed(dir:Direction, repeat = false) {
		if (!started && currentPhase == Throwing && !repeat) {
			if (dir == Down || dir == Up) {
				if (!boosterThing.activate()) {
					launchHook();
				}
				if (boosterThing.boosts == boosterThing.maxBoosts) {
					launchHook();
				}
				return;
			}
		}

		if (currentPhase == Catching && !repeat) {
			if (!arrows.isFinished()) {
				if (arrows.onDirPress(dir)) {
					fisher.punch();
					var splatter = hxd.Res.img.splatters_tilesheet.toSprite2D(world);
					splatter.x = hook.x + Math.random() * 4 - 2;
					splatter.y = hook.y + 10 + Math.random() * 4 - 2;
					splatter.originX = splatter.originY = 16;

					var animations = ["hit1", "hit2", "hit3", "hit4", "hit5",];

					fishRotOffset = -0.2 - Math.random() * Math.PI * 0.4;

					splatter.animation.play(animations[Std.int(Math.random() * animations.length)], false, false, 0, (s) -> splatter.remove());
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

			if (e.keyCode == Key.M) {
				gold += 10;
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

	public function putFishOnPile(f:Fish) {
		killedFish.push(f);
		f.rotation = 0;
		f.sprite.rotation = Math.random() * Math.PI * 2;
		f.sprite.originX = Std.int(f.sprite.tile.width * 0.5);
		f.sprite.originY = Std.int(f.sprite.tile.height * 0.5);
		killedFishContainer.addChild(f);
		f.x = Math.random() * 50 - 25 - 4;
		f.bounce();
		f.y = -Math.floor(killedFish.length * 0.2) * 8;

		var t = new PopText('+${calcGold(f.data.SellPrice)}', container);
		t.text.textColor = 0xf3bd00;

		var p = f.localToGlobal();
		t.x = p.x;
		t.y = p.y - 48;
	}

	var fishRotOffset = 0.0;

	function calcGold(price:Int) {
		return Math.ceil(price * goldMultiplier);
	}

	override function update(dt:Float) {
		super.update(dt);
		if (shop.showing) {
			world.x += (500 - world.x) * 0.1;
		} else {
			world.x += ((-Const.SEA_WIDTH * 0.5 + game.s2d.width * 0.5) - world.x) * 0.2;
		}

		waves.tile.dx = Math.sin(time * 0.5) * 32;
		waves.tile.dy = Math.cos(time * 0.6) * 4;

		rope.fromX = fisher.x + fisher.rodX;
		rope.fromY = fisher.y + fisher.rodY;
		rope.weight = caughtWeight;
		rope.maxWeight = maxWeight;

		world.y = (-currentDepth + game.s2d.height * 0.5);
		time += dt;

		boat.y = Math.round(fisher.y + Math.sin(time) * 2);
		killedFishContainer.x = boat.x;
		killedFishContainer.y = boat.y - 8;

		if (currentPhase == Throwing) {
			boosterThing.x = game.s2d.width >> 1;
			boosterThing.y = Math.round(game.s2d.height * 0.7);
		}

		timer.visible = currentPhase == Sinking;
		timer.x = Math.round((game.s2d.width - 256) * 0.5);
		timer.y = 8;

		if (!started) {
			return;
		}

		if (currentPhase == Sinking) {
			boostTime -= dt;

			var boosting = false;

			if (boostTime > 0) {
				boosting = true;
			} else {
				boostTime = 0.0;
			}

			if (!boosting) {
				catchTime -= dt;
				timer.value = (catchTime / maxCatchTime);
        		if (timer.value < 0.3) {
            		timer.color.set(0.8, 0.3, 0.3);
        		} else {
            		timer.color.set(0.3, 0.6, 0.2);
        		}
			} else {
				timer.value = (boostTime / initialBoostTime);
				
				timer.color.set(0.39, 0.2, 0.9);
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
				catchTime *= 0.99;
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

		fishRotOffset *= 0.9;

		for (f in caughtFish) {
			if (f.dead && currentPhase == Catching)
				continue;

			var dx = hook.x - f.x;
			var dy = hook.y + 7 - f.y;

			if (Math.abs(dx) > 0.001 || Math.abs(dy) > 0.001) {
				f.rot = Math.atan2(dy, dx);
			}

			f.rotation = f.rot + (Math.random() * 0.1 - 0.05) + fishRotOffset;

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
