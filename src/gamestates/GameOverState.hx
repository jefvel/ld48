package gamestates;

import elke.T;
import h2d.Bitmap;
import hxd.Event;
import hxd.snd.Channel;
import elke.graphics.Sprite;
import elke.process.Timeout;
import gamestates.PlayState.GameMode;
import elke.graphics.Transition;
import entities.ShopButtons.Button;
import h2d.Text;
import h2d.Object;
import elke.gamestate.GameState;

class GameOverState extends GameState {
    var container : Object;
    var mainText : Text;
    var buttons : Object;
    var normalButton : Button;
    var chillButton : Button;

    var normalDesc : Text;
    var chillDesc : Text;

    var selected = false;

    var startTransition: Transition;

    public function new() {
    }

    override function onEnter() {
        super.onEnter();
        container = new Object(game.s2d);
        startTransition = new Transition(container);
        startTransition.inTime = 0;
        startTransition.show(null, false);
        rip = new Bitmap(hxd.Res.img.rip.toTile(), container);
        rip.tile.dx = rip.tile.dy = -42;
        rip.visible = false;

        var gmoverText = new Text(hxd.Res.fonts.equipmentpro_medium_12.toFont(), rip);
        gmoverText.textAlign = Center;
        gmoverText.y = 45;
        gmoverText.text = "Game Over";

        new Timeout(1.3, () -> {
            introSound = hxd.Res.sound.badending.play(false, 0.3);
            new Timeout(4.56, () -> {
                rip.visible = true;
            });
        });
    }

    var rip: Bitmap;

    var showingIntro = false;
    var introSprite : Sprite;
    var introSound: Channel;
    var selectedMode: GameMode = Normal;
    var introText : Text;

    override function onEvent(e:Event) {
        super.onEvent(e);
    }

    var launched = false;
    function launch() {
        if (launched) {
            return;
        }

        launched = true;
        game.states.setState(new PlayState(selectedMode));
        introSprite.remove();

        game.s2d.addChild(startTransition);

        startTransition.hide();
    }

    override function update(dt:Float) {
        super.update(dt);
        rip.x = Math.round((game.s2d.width) * 0.5);
        rip.y = Math.round((game.s2d.height) * 0.5) - 24;

        /*
        if (introSprite != null && introText != null) {
            var right = [
                false,
                true,
                false,
                false,
                true,
            ];

            var texts = [
                "WHERES MY MONEY FISHER BOY",
                "uuh i dunno ma",
                "PAY ME WITHIN 30 DAYS OR I WILL KILL YOU",
                "AND YOU WILL BE DEAD",
                "aw man okay",
                "",
            ];

            if (right[introSprite.animation.currentFrame]) {
                introText.textAlign = Right;
                //introText.x = ;
            } else {
                introText.x = 0;
                introText.textAlign = Left;
            }

            introText.text = texts[introSprite.animation.currentFrame];
        }
        */
    }

    override function onLeave() {
        super.onLeave();
        container.remove();
        if (introSound != null) {
            introSound.fadeTo(0, 0.2, () -> {
                introSound.stop();
            });
        }
    }
}