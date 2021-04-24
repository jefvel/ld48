package gamestates;

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

class PlayState extends elke.gamestate.GameState {
	var container:Object;
	var world:Object;

	var fishContainer:Object;

	var fisher:Fisher;
	public var rope: Rope;
	var hook:Hook;
	var boat:Bitmap;

	var bg:Bg;
	var sky:Sky;

	var allFish:Array<Fish>;

	var maxFish = 1000;

	public var reelLength = 450;

	public var catchRadius = 32.0;
	public var maxWeight = 1.0;
	
	public var caughtFish: Array<Fish>;
	public var caughtWeight = 0.0;

	public var currentDepth = 0.0;

	public var sinkSpeed = 2.0;
	public var sinkMultiplier = 1.0;

	public var boostMultiplier = 3.0;
	public var boostTime = 0.0;

	public var started = false;

	public function new() {}

	override function onEnter() {
		super.onEnter();

		container = new Object(game.s2d);
		bg = new Bg(container);

		world = new Object(container);
		sky = new Sky(world);

		fisher = new Fisher(world);
		rope = new Rope(world);
		hook = new Hook(this, world);
		fishContainer = new Object(world);

		boat = new Bitmap(hxd.Res.img.boat.toTile(), world);

		fisher.y = 0;
		fisher.x = Const.SEA_WIDTH >> 1;

		reset();
	}

	var rodX = 34;
	var rodY = -37;

	public function reset() {
		currentDepth = 0.0;
		hook.x = fisher.x + rodX;
		hook.y = fisher.y + rodY;

		allFish = [];
		caughtFish = [];
		caughtWeight = 0.0;
		fishContainer.removeChildren();

		boat.tile.dx = -32;
		boat.tile.dy = -18;
		boat.x = fisher.x;
		boat.y = fisher.y;

		spawnFish();
	}

	public function spawnFish() {
		for (f in Data.fish.all) {
			for (i in 0...f.Amount) {
				var fish = new Fish(f, fishContainer);
				allFish.push(fish);
			}
		}
	}

	function launchHook(boostTime = 0.0) {
		started = true;
		this.boostTime = boostTime;
		hook.start();
	}

	public var downPressed = false;
	public var leftPressed = false;
	public var upPressed = false;
	public var rightPressed = false;

	function directionPressed(dir:Direction) {
		if (!started) {
			if (dir == Down) {
				launchHook(1.9);
				return;
			}
		}
	}

	function directionReleased(dir:Direction) {}

	override function onEvent(e:Event) {
		if (e.kind == EKeyDown) {
			if (e.keyCode == Key.LEFT || e.keyCode == Key.A) {
				if (!leftPressed) {
					leftPressed = true;
					directionPressed(Left);
				}
			}

			if (e.keyCode == Key.RIGHT || e.keyCode == Key.D) {
				if (!rightPressed) {
					rightPressed = true;
					directionPressed(Right);
				}
			}

			if (e.keyCode == Key.DOWN || e.keyCode == Key.S) {
				if (!downPressed) {
					downPressed = true;
					directionPressed(Down);
				}
			}

			if (e.keyCode == Key.UP || e.keyCode == Key.W) {
				if (!upPressed) {
					upPressed = true;
					directionPressed(Up);
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
		}
	}

	var time = 0.0;

	var vy = 0.0;

	override function update(dt:Float) {
		super.update(dt);
		rope.fromX = fisher.x + rodX;
		rope.fromY = fisher.y + rodY;

		world.x = (-Const.SEA_WIDTH * 0.5 + game.s2d.width * 0.5);
		world.y = (-currentDepth + game.s2d.height * 0.5);

		if (!started) {
			return;
		}

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
				}
			}
		}


		for (f in caughtFish) {
			var dx = hook.x - f.x; 
			var dy = hook.y + 7 - f.y; 

			f.rotation = Math.atan2(dy, dx) + (Math.random() * 0.1 - 0.05);

			f.x += dx * 0.9;
			f.y += dy * 0.9;
		}
	}

	override function onLeave() {
		super.onLeave();
	}
}
