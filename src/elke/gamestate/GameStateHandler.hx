package elke.gamestate;

import h3d.Engine;
import elke.Game;

class GameStateHandler {
	static var instance:GameStateHandler;

	public static inline function getInstance() {
		return instance;
	}

	var stateStack : Array<GameState>;

	var currentState:GameState;

	var game:Game;

	public function new(g:Game) {
		instance = this;
		game = g;

		stateStack = [];

		hxd.Window.getInstance().addEventTarget(onEvent);
	}

	public function pushState(s: GameState) {
		stateStack.push(s);
	}

	public function update(dt:Float) {
		var i = 0;
		for (s in stateStack) {
			if (s.alwaysActive || i == stateStack.length) {
				s.update(dt);
			}

			i ++;
		}

		if (currentState != null) {
			currentState.update(dt);
		}
	}

	public function onRender(e: Engine) {
		if (currentState != null) {
			currentState.onRender(e);
		}
	}

	function onEvent(e:hxd.Event) {
		if (currentState != null) {
			currentState.onEvent(e);
		}
	}

	public function setState(s:GameState) {
		if (currentState != null) {
			currentState.onLeave();
		}

		s.game = game;

		s.onEnter();

		currentState = s;
	}
}