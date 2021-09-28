package entities;

import elke.Game;
import elke.graphics.Sprite;
import gamestates.PlayState.Direction;

class TimedGame extends CatchingGame {
	var directions: Array<Direction> = [Up, Down, Left, Right];
	var direction : Direction;
	var arrow: Arrow;

	var timeUntilReveal = Math.random() * 1.5 + 0.7;
	var revealed = false;

	var timeForReaction = 0.5;

	var waitIcon:Sprite;

	public function new(f, s, p) {
		super(f, s, p);
		width = 128;
		direction = directions[Std.int(Math.random() * directions.length)];
		arrow = new Arrow(direction, this);
		arrow.visible = false;

		waitIcon = hxd.Res.img.wait_tilesheet.toSprite2D(this);
		waitIcon.animation.stop();
	}

	override function update(dt:Float) {
		super.update(dt);
		if (!isActive) {
			return;
		}

		if (!revealed) {
			timeUntilReveal -= dt;
			if (timeUntilReveal <= 0) {
				revealed = true;
				arrow.visible = true;
				waitIcon.visible = false;
				Game.instance.sound.playWobble(hxd.Res.sound.timingreadybeep, 0.5);
			}
		} else {
			timeForReaction -= dt;
			if (timeForReaction <= 0) {
				onFail();
			}
		}
	}

	override function onDirectionPress(d:Direction) {
		super.onDirectionPress(d);
		if (!revealed) {
			onFail();
		} else {
			if (d == direction) {
				playState.doPunch();
				onSuccess();
			} else {
				onFail();
			}
		}
	}

	override function onActivate() {
		super.onActivate();
		waitIcon.animation.play();
		playState.pauseTimer = true;
	}

	override function onDeactivate() {
		super.onDeactivate();
		playState.pauseTimer = false;
	}
}