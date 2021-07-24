package gamestates;

import graphics.BoatTransition;
import hxd.Key;
import h3d.Engine;
import entities.TownCharacter;
import h2d.Object;
import entities.TextButton;
import elke.gamestate.GameState;

class TownState extends GameState {
    var container: Object;
    var world: Object;

    var entities: Object;
    var characters : Object;

    var fisher: TownCharacter;
    var level: levels.Levels.Levels_Level;

    var parallax1: Object;

    var ui : Object;
    var activityButton1: TextButton;
    var currentActivity: String = null;

    public function new() {
        name = "town";
    }

    override function onEnter() {
        super.onEnter();
        container = new Object(game.s2d);
        var project = new levels.Levels();
        level = project.all_levels.Level_0;
        
        var sky = project.all_levels.Sky.l_Background.render();

        world = new Object(container);
        parallax1 = new Object(world);

        parallax1.addChild(sky);

        //var backestground = level.l_Background2.render();
        var background = level.l_Background.render();
        var foreground = level.l_Foreground.render();
        var above = level.l_Above.render();

        //world.addChild(backestground);
        world.addChild(background);

        entities = new Object(world);

        characters = new Object(world);

        world.addChild(foreground);

        world.addChild(above);

        world.x = -2000;

        spawnCharacters();

        ui = new Object(container);

        activityButton1 = new TextButton(hxd.Res.img.endroundarrows.toTile().sub(32, 32, 32, 32), "Go\nfish", onActivity, ui);
        activityButton1.alpha = 0.0;
    }

    var busy = false;

    function onActivity() {
        if (busy) {
            return;
        }

        if (currentActivity != null) {
            activityButton1.onTap();
        }

        busy = true;

        if (currentActivity == "GoFish") {
            new BoatTransition(() -> {
                game.states.setState(new PlayState(Normal));
            }, null, game.s2d);
        }
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

        parallax1.x = Math.round(-world.x * 0.9);

        var setActivity = false;
        for (a in level.l_Entities.all_Activity) {
            if (a.pixelX < fisher.x && a.pixelX + a.width > fisher.x) {
                setActivity = true;

                if (currentActivity != a.f_ID) {
                    activityButton1.setText(a.f_Name);
                    currentActivity = a.f_ID;

                    var padding = 24;
                    var s = game.s2d;
                    activityButton1.x = s.width - activityButton1.width - padding;
                    activityButton1.y = s.height - activityButton1.height - 18;
                }
            }
        }

        if (!setActivity) {
            currentActivity = null;
        }

        if (Key.isDown(Key.W) || Key.isDown(Key.UP)) {
            if (!activatePressed) {
                onActivity();
                activatePressed = true;
            }
        } else {
            activatePressed = false;
        }

        var v = currentActivity != null && !busy;
        var tAlpha = v ? 1.0 : 0.0;

        activityButton1.alpha += (tAlpha - activityButton1.alpha) * 0.2;
        activityButton1.update(dt);
    }

    var activatePressed = false;

    override function onLeave() {
        super.onLeave();
        container.remove();
    }
}