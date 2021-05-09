package;

import gamestates.MainMenuState;
import elke.Game;
import gamestates.PlayState;

class Main {
	static var game:Game;

	static function main() {
		game = new Game({
			#if !debug
			initialState: new MainMenuState(),
			#else
			initialState: new PlayState(Normal),
			#end
			onInit: () -> {},
			tickRate: Const.TICK_RATE,
			pixelSize: Const.PIXEL_SIZE,
			backgroundColor: 0x5f556a,
		});
	}
}
