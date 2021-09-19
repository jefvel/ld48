package gamestates;

import graphics.BoatTransition;
import entities.CatchingQueue;
import entities.Sunrays;
import h2d.filter.Outline;
import h2d.Particles;
import h2d.filter.Shader;
import entities.Mine;
import hxd.snd.Channel;
import elke.graphics.Transition;
import hxd.Perlin;
import h2d.Text;
import entities.DayText;
import entities.DepthMeter;
import entities.Timer;
import entities.BoosterThing;
import entities.PopText;
import entities.Shop;
import entities.ArrowQueue;
import entities.Rope;
import hxd.Key;
import entities.WaveBackground;
import entities.Bg;
import entities.Hook;
import h2d.Bitmap;
import entities.Fish;
import entities.Fisher;
import h2d.Object;
import hxd.Event;

enum GameMode {
	Normal;
	Chill;
}

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
	public var container:Object;

	public var world:Object;

	public var backgroundLayer : Object;
	public var fishLayer : Object;

	public var fishContainer:Object;

	public var fisher:Fisher;

	public var rope:Rope;

	var hook:Hook;
	var boatBg: Bitmap;
	public var boat:Bitmap;

	var fishPile: Object;
	var rays: Sunrays;

	var bg:Bg;
	var sky:WaveBackground;

	public var foregroundLayer: Object;

	var allFish:Array<Fish>;

	public var gameMode = Normal;

	public var currentDebt = 15000;

	public var maxCombo = 0;

	public var currentCombo = 0;
	public var maxMultiKill = 4;
	public var multikillStart = 2;
	public var multikillIncrease = 2;

	public var gameData: GameSaveData;

	public var totalRounds = 30;

	public var maxBoostTime = 2.0;

	public var maxCatchTime = 10.0;
	public var catchTime = 10.0;

	public var reelLength = 450;

	var strengths = [2, 3.0, 6.0, 12.0, 18.0, 70.0];
	var lengths = [800, 1200, 2500, 6000, 10000, 13100];
	var speeds = [2.0, 2.5, 3.1, 5.0, 9.0, 15.5];
	var boostLengths = [250, 500, 1000, 4000, 8000];

	var goldMultiplier = 1.0;
	var multipliers = [1.0, 1.2, 1.5, 1.9, 2.3, 3];

	public var catchRadius = 50.0;
	var catchRadiuses = [50, 100.0];

	public var mineProtection = false;
	var protections = [false, true];

	public var playTime = 0.0;

	public var maxWeight = 1.0;

	public var punchTime = 5.0;
	public var maxPunchTime = 7.0;
	public var caughtFish:Array<Fish>;
	public var caughtWeight = 0.0;

	public var boostScore = 0;

	public var killedFish:Array<Fish>;

	var mines : Array<Mine>;

	public var currentDepth = 0.0;

	var depthText: Text;

	public var sinkSpeed = 2.0;
	public var sinkMultiplier = 1.0;

	public var boostMultiplier = 3.0;
	public var boostTime = 0.0;
	var initialBoostTime = 0.0;

	public var started = false;
	public var currentPhase = Throwing;
	public var waves:Bitmap;
	public var bottom: Bitmap;

	public var arrows:ArrowQueue;
	public var fishList: CatchingQueue;

	public var boosterThing:BoosterThing;
	public var timer:Timer;

	var depthIndicator: DepthMeter;

	var roundResult: RoundResult;

	var noise : Perlin;

	var waveNoise: Channel;

	var fishingMusic: Channel;
	var fightingMusic: Channel;
	var shoppingMusic: Channel;

	var comboText : Text;
	var bonusKillsText : Text;

	public function new(mode: GameMode) {
		this.gameMode = mode;
		noise = new Perlin();
	}

	override function onEnter() {
		super.onEnter();

		newGame();

		container = new Object(game.s2d);
		bg = new Bg(container);

		var project = new levels.Levels();

		world = new Object(container);
		backgroundLayer = new Object(world);

		var skyBg = project.all_levels.Sky.l_Background.render();
		skyBg.y = -256;
		skyBg.x = -128;
		// backgroundLayer.addChild(skyBg);

		var particles = new Particles(world);
		particles.load(haxe.Json.parse(hxd.Res.particles.bubble.entry.getText()), hxd.Res.particles.bubble.entry.path);
		particles.y = 300;

		rays = new Sunrays(backgroundLayer, foregroundLayer);

		var t = hxd.Res.img.waves.toTile();
		t.getTexture().wrap = Repeat;
		waves = new Bitmap(t, backgroundLayer);
		waves.y = -16;
		waves.tileWrap = true;
		waves.tile.setSize(1324, 64);
		waves.x = -555;

		var sdform = new graphics.SineDeformShader();
		waves.addShader(sdform);
		sdform.amplitude = 0.04;
		sdform.frequency = 0.6;
		sdform.speed = 0.5;
		sdform.texture = t.getTexture();

		fisher = new Fisher(world);

		sky = new WaveBackground(world);

		arrows = new ArrowQueue(this, container);
		arrows.onCatch = onCatch;
		arrows.onMiss = onMiss;


		boat = new Bitmap(hxd.Res.img.boat.toTile(), world);
		boat.tile.dx = -32;
		boat.tile.dy = -18;
		boatBg = new Bitmap(hxd.Res.img.boatback.toTile(), backgroundLayer);
		boatBg.tile.dx = -32;
		boatBg.tile.dy = -18;

		rope = new Rope(world);
		hook = new Hook(this, world);
		fishContainer = new Object(world);

		fishPile = new Object(boatBg);
		fishPile.y = -5;

		var t = hxd.Res.img.bottom.toTile();
		t.getTexture().wrap = Repeat;
		bottom = new Bitmap(t, world);
		bottom.y = 13020;
		bottom.tileWrap = true;
		bottom.tile.setSize(1324, 512);
		bottom.x = -355;

		fisher.y = 0;
		fisher.x = Const.SEA_WIDTH >> 1;

		foregroundLayer = new Object(world);

		boosterThing = new BoosterThing(container);
		boosterThing.onFail = launchHook;

		timer = new Timer(container);

		fishList = new CatchingQueue(container);

		depthIndicator = new DepthMeter(container);
		depthIndicator.alpha = 0;

		comboText = new Text(hxd.Res.fonts.futilepro_medium_12.toFont(), container);
		comboText.filter = new Outline(1);
		comboText.textAlign = Center;

		bonusKillsText = new Text(hxd.Res.fonts.picory.toFont(), arrows);
		bonusKillsText.textAlign = Center;
		bonusKillsText.x = -8;
		bonusKillsText.y = -29; //27;//;comboText.font.lineHeight + 4;
		bonusKillsText.scale(2);
		//bonusKillsText.rotation = -Math.PI * 0.03;
		bonusKillsText.dropShadow = {
			dx: 1,
			dy: 1,
			alpha: 0.7,
			color: 0x111111,
		}

		depthText = new Text(hxd.Res.fonts.picory.toFont(), container);
		depthText.textAlign = Right;
		depthText.y = 12;
		depthText.x = game.s2d.width - 18;

		depthText.dropShadow = {
			color: 0xFFFFFF,
			dx: 1,
			dy: 1,
			alpha: 0.3,
		}

		reset();

		var i = Newgrounds.instance;
	}

	public function pushFishToBackOfQueue(f: Fish) {
		fishList.moveFishToEnd(f);
		arrows.pushFishToBack(f);
	}

	public function newGame() {
		gameData = GameSaveData.getCurrent();

		playTime = 0.0;

		if (gameMode == Normal) {
			maxPunchTime = 8.4;
		} else {
			maxPunchTime = 10.0;
		}

		resetPurchases();
	}

	public function resetPurchases() {
	}

	var comboBombo = 0.0;
	var comboRoto = 0.0;

	function onCatch(f:Fish, isComboKill = false) {
		f.kill();

		fishList.fishCaught(f);

		if (!isComboKill) {
			punchTime += f.data.TimeGain;
			punchTime = Math.min(punchTime, maxPunchTime);
		}

		game.sound.playWobble(hxd.Res.sound._catch, 0.3);
		gameData.caught ++;

		if (!isComboKill) {
			currentCombo ++;

			if (maxCombo < currentCombo) {
				maxCombo = currentCombo;
			}

			comboBombo += 0.4;
			comboRoto = (Math.random() - 0.5) * Math.PI * 0.3;
		}

		var medal: Data.MedalsKind = 
		switch (f.data.ID) {
			case Basic: Fish0;
			case Basic2: Fish1;
			case Eel: Fish2;
			case Jelly: Fish3;
			case Biggo: Fish4;
			case Snekris: Fish5;
			case Cthulhu: Boss;
		}

		Newgrounds.instance.unlockMedal(medal);

		putFishOnPile(f);
	}

	function onMiss(f:Fish, passive = false) {
		caughtFish.remove(f);
		fishList.fishMissed(f);

		f.flee();

		if (!passive) {
			gameData.missed ++;
			if (currentCombo > maxCombo) {
				maxCombo = currentCombo;
			}

			currentCombo = 0;

			game.sound.playWobble(hxd.Res.sound.ouch, 0.3);
		}
	}

	public function reset(keepFish = false) {
		currentDepth = 0.0;
		boostScore = 0;
		currentCombo = 0;

		currentPhase = Throwing;
		started = false;

		hook.x = fisher.x + fisher.rodX;
		hook.y = fisher.y + fisher.rodY;
		hook.reset();

		allFish = [];
		caughtFish = [];
		killedFish = [];
		mines = [];
		caughtWeight = 0.0;

		fishContainer.removeChildren();

		if (!keepFish) {
			fishPile.removeChildren();
		}

		boat.x = fisher.x;

		arrows.reset();

		var unlocked = gameData.unlocked;
		maxWeight = strengths[unlocked.get(Strength)];
		reelLength = lengths[unlocked.get(Line)];
		sinkSpeed = speeds[unlocked.get(Speed)];
		goldMultiplier = multipliers[unlocked.get(MoneyMultiplier)];
		catchRadius = catchRadiuses[unlocked.get(Magnet)];
		mineProtection = protections[unlocked.get(Protection)];

		if (unlocked.get(Magnet) > 0) {
			hook.aura.visible = true;
		} else {
			hook.aura.visible = false;
		}

		boosterThing.reset();
		boosterThing.fadeIn();

		spawnFish();

		var t = 'Day ${gameData.currentRound}';
		var dayText = new DayText(t, currentDebt, game.s2d);

		if (waveNoise != null) {
			waveNoise.stop();
		}

		waveNoise = hxd.Res.sound.waves.play(true, 0.1);
	}

	var mineCount = 27;
	var mineStart = 7000.0;
	var mineEnd = 12500.0;

	public function spawnFish() {
		for (f in Data.fish.all) {
			var amount = Math.round(f.Amount * (0.6 + Math.random() * 0.4));
			amount = Std.int(Math.max(1, amount));

			for (_ in 0...amount) {
				var fish = new Fish(f, fishContainer, this);
				allFish.push(fish);
			}
		}

		var spaceBetween = (mineEnd - mineStart) / mineCount;
		for (i in 0...mineCount) {
			var m = new Mine(fishContainer);
			m.x = Math.round(Math.random() * Const.SEA_WIDTH);
			//m.y = mineStart + i * spaceBetween;
        	m.y = Math.round(Math.random() * (mineEnd - mineStart) + mineStart);
			mines.push(m);
		}
	}

	function launchHook() {
		started = true;
		boosterThing.fadeOut();

		fisher.throwLine();

		boostTime = maxBoostTime * (boosterThing.boosts / boosterThing.maxBoosts);
		initialBoostTime = boostTime;

		timeuntilReel = totalTimeUntilReel;
		hook.start();

		catchTime = maxCatchTime;
		currentPhase = Sinking;
		game.sound.playWobble(hxd.Res.sound.throwline, 0.5);

		if (waveNoise != null) {
			waveNoise.stop();
			waveNoise = null;
		}

		depthIndicator.full = false;

		fishingMusic = hxd.Res.sound.fishingsong.play(true, 0.5);
	}

	function reelIn() {
		catchTime = 0.0;
		currentPhase = ReelingIn;

		timeUntilCatching = totalTimeUntilCatching;

		game.sound.playWobble(hxd.Res.sound.reelin, 0.4);

		fisher.reelIn();

		if (fishingMusic != null) {
			var f = fishingMusic;
			fishingMusic.fadeTo(0, 0.3, () -> {
				f.stop();
			});
			fishingMusic = null;
		}
	}

	var caughtFishCount = 0;
	var punchedFishCount = 0;

	function startCatch() {
		currentPhase = Catching;
		punchTime = maxPunchTime;

		fisher.endReelIn();

		arrows.reset();
		timeUntilDone = totalTimeUntilDone;
		if (fightingMusic != null) {
			fightingMusic.stop();
		}


		caughtFishCount = caughtFish.length;

		for (f in caughtFish) {
			arrows.addArrow(f, f.pattern);
		}

		if (!arrows.isFinished()) {
			fightingMusic = hxd.Res.sound.fightingmusic.play(true, 0.6);
		}
	}

	function stopFightMusic() {
		if (fightingMusic != null) {
			var f = fightingMusic;
			fightingMusic.fadeTo(0.0, 0.6, () -> {
				f.stop();
			});
			fightingMusic = null;

			var snds = [
				hxd.Res.sound.yeah1,
				hxd.Res.sound.yeah2,
			];

			snds[Std.int(Math.random() * snds.length)].play(false, 0.4);
		}
	}

	function giveGold(amount: Int) {
		gameData.totalGold += amount;
		gameData.gold += amount;
	}

	function finishRound() {
		currentPhase = Shopping;
		gameData.currentRound++;

		for (f in killedFish) {
			// giveGold(Math.ceil(f.data.SellPrice * goldMultiplier));
			gameData.ownedFish.push(f.data.ID);
		}

		punchedFishCount = killedFish.length;

		if (punchedFishCount == 0 && caughtFishCount >= 15) {
			Newgrounds.instance.unlockMedal(JustPretending);
		}

		if (maxCombo > gameData.bestMaxCombo) {
			gameData.bestMaxCombo = maxCombo;
		}

		if (gameData.currentRound > totalRounds) {
			if (gameData.gold < currentDebt) {
				loseGame();
			} else {
				winGame();
			}

			return;
		}

		arrows.reset();

		roundResult = new RoundResult(killedFish, maxCombo, punchTime, boostScore, container);
		roundResult.onRetry = newRound;
		roundResult.onReturn = returnToTown;
	}

	function returnToTown() {
		game.states.setState(new TownState());
	}

	public function loseGame() {
		fishContainer.removeChildren();
		Transition.to(() -> {
			game.states.setState(new GameOverState());
		}, 0.8);
	}

	function stopShopMusic() {
		if (shoppingMusic != null) {
			var f = shoppingMusic;
			shoppingMusic.fadeTo(0.0, 0.3, () -> {
				f.stop();
			});
			shoppingMusic = null;
		}
	}

	function newRound() {
		roundResult = null;
		reset(true);
	}

	public var downPressed = false;
	public var leftPressed = false;
	public var upPressed = false;
	public var rightPressed = false;

	public var usePressed = false;

	function directionPressed(dir:Direction, repeat = false) {
		if (!started && currentPhase == Throwing && !repeat) {
			if (dir == Down || dir == Up) {
				fisher.charge();
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
					shake();
					var splatter = hxd.Res.img.splatters_tilesheet.toSprite2D(world);
					splatter.x = hook.x + Math.random() * 4 + 5;
					splatter.y = hook.y + 10 + Math.random() * 4 - 2;
					splatter.originX = splatter.originY = 32;

					var animations = ["hit1", "hit2", "hit3", "hit4", "hit5",];

					var rr = 0.4;
					fishRotOffset = -rr - Math.random() * Math.PI * rr * 2;

					splatter.animation.play(animations[Std.int(Math.random() * animations.length)], false, false, 0, (s) -> splatter.remove());
				}
			}
		}

		if (currentPhase == Shopping && !repeat) {
			//shop.directionPressed(dir);
			roundResult.directionPressed(dir);
		}
	}

	function splatter() {
		var splatter = hxd.Res.img.splatters_tilesheet.toSprite2D(world);
		splatter.x = hook.x + Math.random() * 4 + 5;
		splatter.y = hook.y + 10 + Math.random() * 4 - 2;
		splatter.originX = splatter.originY = 32;
		var animations = ["hit1", "hit2", "hit3", "hit4", "hit5",];
		splatter.animation.play(animations[Std.int(Math.random() * animations.length)], false, false, 0, (s) -> splatter.remove());
	}

	function onUse() {
		if (currentPhase == Shopping) {
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
			}

			if (e.keyCode == Key.M) {
				giveGold(100);
			}
			if (e.keyCode == Key.U) {
				shake();
			}

			if (e.keyCode == Key.NUMPAD_ENTER) {
				winGame();
			}

			if (e.keyCode == Key.NUMPAD_SUB) {
				loseGame();
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

	var slowDownTime = 0.0;
	var slowDownRatio = 0.4;

	public function putFishOnPile(f:Fish) {
		killedFish.push(f);

		f.rotation = 0;
		f.vRot = (Math.random() - 0.5) * 0.6;

		var newOriginX = Std.int(f.sprite.tile.width * 0.5);
		var newOriginY = Std.int(f.sprite.tile.height * 0.5);

		var gPos = f.localToGlobal();

		f.sprite.originX = newOriginX;
		f.sprite.originY = newOriginY;

		fishPile.addChild(f);

		f.pileX = Math.random() * 40 - 20 - 4;
		f.pileY = -Math.floor(killedFish.length * 0.2) * 8;

		var pPos = fishPile.localToGlobal();
		f.x = gPos.x - pPos.x;
		f.y = gPos.y - pPos.y;

		f.by = -7.0 - Math.random() * 2;
		f.bx = (f.pileX - f.x) * 0.1;
		f.inPile = true;

		/*
		var t = new PopText('+${calcGold(f.data.SellPrice)}', container);
		t.text.textColor = 0xFFFFFF;
		t.filter = new Outline(1);

		var p = f.localToGlobal();
		t.x = Math.round(p.x + Math.random() * 20 - 10);
		t.y = Math.round(48 + Math.random() * 5);
		*/
	}

	var fishRotOffset = 0.0;

	function calcGold(price:Int) {
		return Math.ceil(price * goldMultiplier);
	}

	function fadeOutAllMusic() {
		if (waveNoise != null) {
			waveNoise.fadeTo(0, 0.6, () -> {
				waveNoise.stop();
				waveNoise = null;
			});
		}

		if (fightingMusic != null) {
			fightingMusic.fadeTo(0, 0.6, () -> {
				fightingMusic.stop();
				fightingMusic = null;
			});
		}

		if (shoppingMusic != null) {
			shoppingMusic.fadeTo(0, 0.6, () -> {
				shoppingMusic.stop();
				shoppingMusic = null;
			});
		}
	}

	public var wonGame = false;
	public function winGame() {
		if (wonGame) {
			return;
		}
		
        game.sound.playWobble(hxd.Res.sound.purchase, 0.6);

		wonGame = true;
		fadeOutAllMusic();
		Transition.to(() -> {
			game.states.setState(new WonGameState(this));
		}, 2.0, 1.0);
	}

	var shakeTime = 0.0;
	var totalShakeTime = 0.2;
	var shakeIntensity = 2.0;
	var shakeStart = 0.0;

	public function shake(intensity = 2.0, time = 0.1) {
		shakeTime = 0.0;
		totalShakeTime = time;
		shakeIntensity = intensity;
		shakeStart = Math.random() * 100.0;
	}

	override function update(dt:Float) {
		super.update(dt);

		if (currentDepth > 0) {
			depthText.text = '${Math.round(currentDepth / Const.UNITS_PER_METER)} / ${Math.round(reelLength / Const.UNITS_PER_METER)}m';
		} else {
			depthText.text = "";
		}

		playTime += dt;

		world.x += ((-Const.SEA_WIDTH * 0.5 + game.s2d.width * 0.5) - world.x) * 0.2;

		bg.ratio = (currentDepth / 13000.0);

		waves.tile.dx = Math.sin(time * 0.5) * 32;
		waves.tile.dy = Math.cos(time * 0.6) * 4;

		rope.fromX = fisher.x + fisher.rodX;
		rope.fromY = fisher.y + fisher.rodY;
		rope.weight = caughtWeight;
		rope.maxWeight = maxWeight;

		world.y = (-currentDepth + game.s2d.height * 0.5);
		time += dt;

		bg.y = Math.max(0, world.y);

		if (totalShakeTime > 0) {
			shakeTime += dt;
			var st = (shakeTime / totalShakeTime);
			st = Math.max(0, Math.min(1, st));

			var sit = (1.0 - st);
			var shakeX = noise.perlin1D(4000, shakeStart + st * 30, 4, 0.5);
			var shakeY = noise.perlin1D(2000, shakeStart + st * 30, 4, 0.5);
			shakeX = Math.round((shakeX * 2 - 1.0) * sit * shakeIntensity);
			shakeY = Math.round((shakeY * 2 - 1.0) * sit * shakeIntensity);

			world.x += shakeX;
			world.y += shakeY;
		}

		boat.y = Math.round(fisher.y + Math.sin(time) * 2);
		boatBg.x = boat.x;
		boatBg.y = boat.y;

		boat.rotation *= 0.6;
		boatBg.rotation = boat.rotation;

		if (currentPhase == Throwing) {
			boosterThing.x = game.s2d.width >> 1;
			boosterThing.y = Math.round(game.s2d.height * 0.7);
		}

		fishList.bag.visible = currentPhase == Catching;
		fishList.maxWidth = timer.getBounds().width - 8;
		fishList.x = timer.x + 8;
		fishList.y = timer.y + 32;

		comboText.visible = currentPhase == Catching;

		timer.visible = currentPhase == Sinking || currentPhase == Catching;
		timer.x = Math.round((game.s2d.width - 256) * 0.5);
		timer.y = 8;

		depthIndicator.x = game.s2d.width - 30;
		depthIndicator.y = 56;
		depthIndicator.depth = currentDepth;

		if (!started) {
			return;
		}

		if (currentPhase == Sinking || currentPhase == ReelingIn || currentPhase == PreparingReel) {
			depthIndicator.alpha += (1.0 - depthIndicator.alpha) * 0.2;
		} else {
			depthIndicator.alpha *= 0.8;
		}

		if (currentPhase != Sinking) {
			hook.sprite.animation.play("idle");
		}

		if (currentPhase == Sinking) {
			boostTime -= dt;

			var boosting = false;

			if (boostTime > 0) {
				boosting = true;
			} else {
				boostTime = 0.0;
			}

			if (boosting) {
				hook.sprite.animation.play("boost");
				depthText.textColor = 0xff96f1;
			} else {
				hook.sprite.animation.play("idle");
				depthText.textColor = 0xFFFFFF;
			}

			if (!boosting) {
				if (hook.y > 0) {
					catchTime -= dt;
				}
				timer.value = (catchTime / maxCatchTime);
        		if (timer.value < 0.3) {
            		timer.color.set(0.8, 0.3, 0.3);
        		} else {
            		timer.color.set(0.3, 0.6, 0.2);
        		}
			} else {
				timer.value = (boostTime / maxBoostTime);
				
				timer.color.set(0.39, 0.2, 0.9);
			}

			var dy = (reelLength - currentDepth) * 0.02;

			vy = sinkSpeed;
			sinkMultiplier += (1.0 - sinkMultiplier) * 0.2;


			if (boosting) {
				sinkMultiplier = boostMultiplier;
			}

			slowDownTime -= dt;
			if (slowDownTime > 0) {
				sinkMultiplier *= slowDownRatio;
			} else {
				slowDownTime = 0;
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

			var didCatch = false;

			var rr = catchRadius * catchRadius;
			if (caughtWeight < maxWeight) {
				for (f in allFish) {
					var dx = hook.x - f.x;
					var dy = hook.y - f.y;

					if (dx * dx + dy * dy < rr) {
						if (boosting) {
							f.kill();

							/*
							var g = calcGold(f.data.SellPrice);
							g = Math.ceil(0.3 * g);
							giveGold(g);
							*/

							boostScore += Math.ceil(f.data.Score * 0.6);

							/*
							var t = new PopText('+${g}', world);
							t.text.textColor = 0xf3bd00;
							t.x = hook.x;
							t.y = hook.y;
							*/

							allFish.remove(f);
							f.rotAway();
							var snds = [
								hxd.Res.sound.crush1,
								hxd.Res.sound.crush2,
							];

							game.sound.playWobble(snds[Std.int(Math.random() * snds.length)], 0.3);

						} else {
							caughtFish.push(f);
							fishList.addFish(f);
							allFish.remove(f);
							caughtWeight += f.data.Weight;
							didCatch = true;
						}
					}
				}
			} else {
				depthIndicator.full = true;
			}

			var mineR2 = 26 * 26;
			for (f in mines) {
				var dx = hook.x - f.x;
				var dy = hook.y - f.y;

				if (dx * dx + dy * dy < mineR2) {
					hxd.Res.sound.explosion.play(false, 0.5);
					mines.remove(f);
					f.explode();

					if (!mineProtection) {
						slowDownTime = 0.8;
						splatter();
						
						var fish = caughtFish.pop();
						if (fish != null) {
							var p = new PopText("Fish Escaped", world);
							onMiss(fish, true);
							p.x = fish.x;
							p.y = fish.y;
						}
					} else {
						var g = 50;
						var p = new PopText('*GUNSHOTS* +${g}', world);
						giveGold(g);
						p.text.textColor = 0xf3bd00;
						p.x = hook.x;
						p.y = hook.y;
					}
				}
			}


			if (didCatch) {
				game.sound.playWobble(hxd.Res.sound.eat, 0.2);
			}

			if (catchTime <= 0.0) {
				currentPhase = PreparingReel;
				return;
			}
		}

		fishRotOffset *= 0.9;

		for (f in caughtFish) {
			if (f.dead && (currentPhase == Catching || currentPhase == Shopping))
				continue;

			var dx = hook.x + hook.centerX - f.x;
			var dy = hook.y + hook.centerY - f.y;

			if (currentPhase != ReelingIn) {
				if (currentPhase != Catching) {
					if (Math.abs(dx) > 0.001 || Math.abs(dy) > 0.001) {
						f.rot = Math.atan2(dy, dx);
					}
				}

				f.rotation = f.rot + (Math.random() * 0.1 - 0.05) + fishRotOffset;
			}

			f.x += dx * f.attractSpeed;
			f.y += dy * f.attractSpeed;
			if (f.attractSpeed < 0.999) {
				f.caughtTime += dt;
				f.attractSpeed += (1.0 - f.attractSpeed) * 0.1;
				if (f.caughtTime > 0.4) {
					f.attractSpeed += (1.0 - f.attractSpeed) * 0.3;
				}
			} else {
				f.attractSpeed = 1.0;
			}
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
			if (!arrows.isFinished()) {
				punchTime -= dt;
			}

			if (punchTime <= 0) {
				punchTime = 0;
				arrows.failAll();
			}

			var bonusKills = Math.max(0, Math.floor((currentCombo - multikillStart + multikillIncrease - 1) / multikillIncrease));
			bonusKills = Math.min(bonusKills, maxMultiKill);
			arrows.bonusKills = Std.int(bonusKills);

			timer.value = (punchTime / maxPunchTime);
			timer.color.set(0.79, 0.5, 0.3);

			comboBombo *= 0.9;

			comboText.text = currentCombo > 2 ? 'Combo x${currentCombo}' : '';
			comboText.setScale(1 + comboBombo);
			comboText.rotation = comboRoto;
			comboRoto *= 0.9;

			bonusKillsText.text = bonusKills > 0 ? 'x${bonusKills + 1}' : '';
			bonusKillsText.alpha = arrows.square.alpha * 2;

			comboText.x = timer.x;
			comboText.y = arrows.y;

			if (arrows.isFinished()) {
				timeUntilDone -= dt;
				stopFightMusic();
				if (timeUntilDone <= 0) {
					finishRound();
				}
			}
		}
	}

	function stopFishMusic() {
		if (fishingMusic != null) {
			var f = fishingMusic;
			fishingMusic.fadeTo(0, 0.3, () -> {
				f.stop();
			});
			fishingMusic = null;
		}
	}

	function stopWaveMusick() {
		if (waveNoise != null) {
			var f = waveNoise;
			waveNoise.fadeTo(0, 0.3, () -> {
				f.stop();
			});
			waveNoise = null;
		}
	}

	function stopMusic() {
		stopFightMusic();
		stopShopMusic();
		stopFishMusic();
		stopWaveMusick();
	}

	override function onLeave() {
		super.onLeave();
		container.remove();
		stopMusic();
	}
}
