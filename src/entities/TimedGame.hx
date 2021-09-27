package entities;

class TimedGame extends CatchingGame {
	public function new(f, s, p) {
		super(f, s, p);
		width = 128;
	}

	override function onActivate() {
		super.onActivate();
		playState.pauseTimer = true;
	}

	override function onDeactivate() {
		super.onDeactivate();
		playState.pauseTimer = false;
	}
}