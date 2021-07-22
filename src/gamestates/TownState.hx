package gamestates;

import h3d.Engine;
import entities.TownCharacter;
import h2d.Object;
import elke.gamestate.GameState;

class TownState extends GameState {
    var container: Object;
    var world: Object;

    var entities: Object;
    var characters : Object;

    var fisher: TownCharacter;
    var level: levels.Levels.Levels_Level;

    public function new() {
        name = "town";
    }

    override function onEnter() {
        super.onEnter();
        container = new Object(game.s2d);
        var project = new levels.Levels();
        level = project.all_levels.Level_0;

        world = new Object(container);

        var backestground = level.l_Background2.render();
        var background = level.l_Background.render();
        var foreground = level.l_Foreground.render();

        world.addChild(backestground);
        world.addChild(background);

        entities = new Object(world);

        characters = new Object(world);

        world.addChild(foreground);

        world.x = -2000;

        spawnCharacters();
    }

    var targetX = -2000.;

    function spawnCharacters() {
        for (m in level.l_Entities.all_Merchant) {
            var s = hxd.Res.img.merchant_tilesheet.toSprite2D(characters);
            s.x = m.pixelX;
            s.y = m.pixelY;
            s.animation.play();
        }

        fisher = new TownCharacter(characters);
        fisher.setX(934 + 32);
        fisher.y = 256;

        for (s in level.l_Entities.all_Shop_Sign) {
            var spr = hxd.Res.img.shopsignanimated_tilesheet.toSprite2D(entities);
            spr.x = s.pixelX;
            spr.y = s.pixelY;
            spr.animation.play();
        }
    }

    override function onRender(e:Engine) {
        super.onRender(e);
    }

    override function update(dt:Float) {
        super.update(dt);

        var newTargetX = (game.s2d.width * 0.5 - fisher.x);
        newTargetX = Math.min(0, newTargetX);
        newTargetX = Math.max(-1280 + game.s2d.width, newTargetX);

        targetX += (newTargetX - targetX);
        targetX = Math.max(-1280 + game.s2d.width, targetX);

        world.x = Math.round(targetX);
    }

    override function onLeave() {
        super.onLeave();
        container.remove();
    }
}