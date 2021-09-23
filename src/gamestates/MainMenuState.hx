package gamestates;

import graphics.BoatTransition;
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

class MainMenuState extends GameState {
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
        var t = new Transition(game.s2d);
        t.hide(() -> t.remove(), true);
        buttons = new Object(container);
        mainText = new Text(hxd.Res.fonts.futilepro_medium_12.toFont(), container);
        mainText.textAlign = Center;
        mainText.text = "Click to Start";
        mainText.dropShadow = {
            dx: 1,
            dy: 1,
            alpha: 0.3,
            color: 0x111111,
        }

        mainText.scale(2);

        /*
        normalButton = new Button("Normal", buttons);
        chillButton = new Button("Chill", buttons);
        chillButton.x = normalButton.width + 32;

        var p = 2;
        normalDesc = new Text(hxd.Res.fonts.picory.toFont(), normalButton);
        normalDesc.y = normalButton.height + 12;
        normalDesc.x = p;
        normalDesc.maxWidth = normalButton.width - p * 2;
        normalDesc.text = "The default game mode. It has a time limit of 30 days, and is a bit more challenging";

        chillDesc = new Text(hxd.Res.fonts.picory.toFont(), chillButton);
        chillDesc.y = chillButton.height + 12;
        chillDesc.x = p;
        chillDesc.maxWidth = chillButton.width - p * 2;
        chillDesc.text = "A relaxing fishing experience. Play at your own pace.";

        normalButton.onClick = e -> {
            select(Normal);
        }
        chillButton.onClick = e -> {
            select(Chill);
        }
        */
    }

    var showingIntro = false;
    var introSprite : Sprite;
    var introSound: Channel;
    var selectedMode: GameMode = Normal;
    var introText : Text;

    function select(mode : GameMode) {
        if (selected) {
            return;
        }

        selectedMode = mode;

        selected = true;

        game.sound.playWobble(hxd.Res.sound.select);
        startTransition = new Transition(game.s2d);
        startTransition.inTime = 0.3;
        startTransition.show(() -> {
            new Timeout(0.5, () -> {
                introSprite = hxd.Res.img.intro_tilesheet.toSprite2D(game.s2d);
                introSprite.x = Math.round((game.s2d.width - 128) * 0.5);
                introSprite.y = Math.round((game.s2d.height - 128) * 0.5);
                introSprite.animation.play(null, false, false, 0, (s) -> {
                    introSprite.remove();
                    launch();
                });
                introText = new Text(hxd.Res.fonts.picory.toFont(), introSprite);
                introText.y = 132;
                introText.maxWidth = 128;
                introSound = hxd.Res.sound.introspeech.play(false, 0.6);
                showingIntro = true;
            });
        }, false);

        //Transition.to(() -> {
        //});
    }


    override function onEvent(e:Event) {
        super.onEvent(e);

        if (e.kind == EPush) {
            if (launched) {
                return;
            }
            launched = true;
            hxd.Res.sound.reelin.play(false, 0.4);
            new BoatTransition(() -> {
                if (GameSaveData.getCurrent().currentRound == 0) {
                    game.states.setState(new PlayState(Normal));
                } else {
                    game.states.setState(new TownState());
                }
            }, game.s2d);
        }

        if (showingIntro) {
            if (e.kind == EKeyDown) {
                launch();
            }
        }
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
		mainText.x = Math.round(game.s2d.width * 0.5);
		mainText.y = Math.round(game.s2d.height * 0.5 - mainText.textHeight * 0.5);
        buttons.y = Math.round(game.s2d.height * 0.5);
        var bnds = buttons.getBounds();
        buttons.x = Math.round((game.s2d.width - bnds.width) * 0.5);

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