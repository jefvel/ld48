package gamestates;

import elke.gamestate.GameState;

class WonGameState extends GameState {
    var playState : PlayState;
    public function new(playState: PlayState) {
        this.playState = playState;
    }

    override function onEnter() {
        super.onEnter();
    }
}