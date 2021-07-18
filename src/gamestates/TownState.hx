package gamestates;

import h2d.Object;
import elke.gamestate.GameState;

class TownState extends GameState {
    var container: Object;
    public function new() {
        name = "town";
    }

    override function onEnter() {
        super.onEnter();
        container = new Object(game.s2d);
    }

    override function onLeave() {
        super.onLeave();
        container.remove();
    }
}