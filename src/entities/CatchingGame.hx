package entities;

import gamestates.PlayState;
import gamestates.PlayState.Direction;
import elke.entity.Entity2D;

class CatchingGame extends Entity2D {
	public var onFail: Void -> Void;
	public var onSuccess: Void -> Void;

	var playState: PlayState;

	public var isActive = false;

	public var width = 0.0;

	// The fish type being caught
	public var fish: Fish;

	// Amount of fish in being caught (affected by combos)
	public var stackCount = 1;

	function new(f: Fish, state, ?p) {
		this.fish = f;
		this.playState = state;
		super(p);
	}

	public function onDirectionPress(d: Direction) {

	}

	public function onDeactivate() {

	}

	public function onActivate() {
		isActive = true;
	}
}