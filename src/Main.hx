package;

import elke.Game;
import gamestates.PlayState;

class Main {
	static var game:Game;

	static function main() {
		game = new Game({
			initialState: new PlayState(),
			onInit: () -> {},
			tickRate: Const.TICK_RATE,
			pixelSize: Const.PIXEL_SIZE,
			backgroundColor: 0x68c2d3,
		});
	}
}
