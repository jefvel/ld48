package gamestates;

import h2d.Object;
import elke.gamestate.GameState;

class TownState extends GameState {
    var container: Object;
    var world: Object;

    public function new() {
        name = "town";
    }

    override function onEnter() {
        super.onEnter();
        container = new Object(game.s2d);
        var project = new levels.Levels();
        var level = project.all_levels.Level_0;

        world = new Object(container);

        var backestground = level.l_Background2.render();
        var background = level.l_Background.render();
        var foreground = level.l_Foreground.render();

        world.addChild(backestground);
        world.addChild(background);
        world.addChild(foreground);
        var entities = new Object(world);
        for (m in level.l_Entities.all_Merchant) {
            var s = hxd.Res.img.merchant_tilesheet.toSprite2D(entities);
            s.x = m.pixelX;
            s.y = m.pixelY;
            s.animation.play();
        }

        world.addChild(entities);
        world.x = -300;
    }

    override function onLeave() {
        super.onLeave();
        container.remove();
    }
}