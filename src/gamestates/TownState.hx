package gamestates;

import entities.TownDog;
import entities.TextPrompt;
import h2d.Text;
import entities.PopText;
import elke.graphics.Sprite;
import entities.BasicFish;
import h2d.col.Point;
import entities.FishInventory;
import hxd.Event;
import h2d.filter.Blur;
import entities.Shop;
import h3d.shader.Displacement;
import entities.CoinDisplay;
import hxd.res.Sound;
import hxd.snd.Channel;
import hxd.snd.effect.Spatialization;
import hxd.snd.Manager;
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
    var aboveNpcsLayer : Object;
    var playerLayer : Object;

    var fisher: TownCharacter;
    var dog:TownDog;
    var fishMonger: Sprite;
    var level: levels.Levels.Levels_Level;

    var parallax1: Object;

    var ui : Object;
    var activityButton1: TextButton;
    var currentActivity: String = null;
    var lastActivity: String = null;

    var oceanAmbience: hxd.snd.Channel;
    var wavesEff : Spatialization;
    var shopMusic:hxd.snd.Channel;

    var townAmbience: hxd.snd.Channel;
    var townEff : Spatialization;

    var shop: Shop;
    var coinDisplay: CoinDisplay;

    var data : GameSaveData;

    var fishInventory: FishInventory;
    var soldFishList: Array<BasicFish>;
    var totalSellPrice = 0;
    var moneyGottenText: Text;
    var lastSoldFishPrice : Text;
	var returnMoneyToBag = false;
    var finishedSelling = false;

    public function new() {
        name = "town";
    }

    override function onEnter() {
        super.onEnter();
        data = GameSaveData.getCurrent();

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
        aboveNpcsLayer = new Object(world);
        aboveNpcsLayer.addChild(level.l_AboveNpcs.render());

        playerLayer = new Object(world);

        world.addChild(foreground);

        world.addChild(above);

        world.x = -2000;

        spawnCharacters();

        ui = new Object(container);

        activityButton1 = new TextButton(hxd.Res.img.endroundarrows.toTile().sub(32, 32, 32, 32), "Go\nfish", null, onActivityEnd, ui);
        activityButton1.alpha = 0.0;

        initSounds();

        soldFishList = [];

        shop = new Shop(data, container);
        coinDisplay = new CoinDisplay(container);
        coinDisplay.coins = data.gold;
        fishInventory = new FishInventory(data, container);

        moneyGottenText = new Text(hxd.Res.fonts.equipmentpro_medium_12.toFont(), container);
        moneyGottenText.dropShadow = {
            dx: 1,
            dy: 1,
            color: 0x111111,
            alpha: 0.4,
        }
        moneyGottenText.textAlign = Center;

        lastSoldFishPrice = new Text(hxd.Res.fonts.picory.toFont(), moneyGottenText);
        lastSoldFishPrice.y = 18;
        lastSoldFishPrice.alpha = 0;
        lastSoldFishPrice.textAlign = Center;
    }

    function initSounds() {
        oceanAmbience = hxd.Res.sound.town.oceanambience.play(true, 0.2);
        townAmbience = hxd.Res.sound.town.chatterwind.play(true, 0.08);

        wavesEff = new hxd.snd.effect.Spatialization();
        wavesEff.maxDistance = 150;
        wavesEff.referenceDistance = 100;
        wavesEff.rollOffFactor = 0.5;
        wavesEff.fadeDistance = 150;
        wavesEff.position.set(1050, 10, 0);
        oceanAmbience.addEffect(wavesEff);

        townEff = new hxd.snd.effect.Spatialization();
        townEff.maxDistance = 200;
        townEff.referenceDistance = 200;
        townEff.rollOffFactor = 0.5;
        townEff.fadeDistance = 200;
        townEff.position.set(1050, 10, 0);
        townAmbience.addEffect(townEff);

        soundSources = [];
        for (s in level.l_Entities.all_SoundSource) {
            var channel = hxd.Res.loader.loadCache(s.f_Audio, Sound).play(true, s.f_Volume);
            var eff = new hxd.snd.effect.Spatialization();
            eff.maxDistance = s.f_MaxDistance;
            eff.referenceDistance = s.f_ReferenceDistance;
            eff.rollOffFactor = 0.5;
            eff.fadeDistance = s.f_FadeDistance;
            eff.position.set(s.pixelX, s.pixelY, 100);
            channel.addEffect(eff);

            soundSources.push(channel);
        }

    }

    var soundSources: Array<Channel>;

    var busy = false;
    var activated = false;

    function onActivity() {
        if (busy) {
            return;
        }

        if (currentActivity == null) {
            return;
        }

        if (currentActivity == "SellFish") {
            activityButton1.activate();
            activated = true;

            curSellTime = sellTime;
            sellTimeRatio = 1.0;

            selling = true;

            return;
        } else {
            activityButton1.onTap();
        }


        if (currentActivity == "GoFish") {
            busy = true;
            hxd.Res.sound.driveoff.play(false, 0.6);
            new BoatTransition(() -> {
                game.states.setState(new PlayState(Normal));
            }, null, game.s2d);
        }

        if (currentActivity == "TradeItems") {
            busy = true;
            world.filter = new Blur(3);
            worldZoom = 2.0;
            shop.onClose = closeShop;
            shop.show();
        }

        if (currentActivity == "LookOcean") {
            busy = true;
            var prompts = [
                "Man, the ocean's so vast. if I had a better boat I could explore it all",
                "I wonder what's out there, other than hundreds of fish"
            ];

            var text = prompts[Std.int(Math.random() * prompts.length)];

            var p = new TextPrompt(text, container, () -> {
                busy = false;
            });
        }
        
        if (currentActivity == "LookBoat") {
            busy = true;
            var prompts = [
                "It's a sweet boat, looks like a viking ship",
            ];

            var text = prompts[Std.int(Math.random() * prompts.length)];

            var p = new TextPrompt(text, container, () -> {
                busy = false;
            });
        }
    }

    var selling = false;
    var sellTime = 0.2;
    var curSellTime = 0.;
    var sellTimeRatio = 1.0;
    var minSellTimeRatio = 0.2;
    
    var worldZoom = 1.0;

    function closeShop() {
        worldZoom = 1.0;
        world.filter = null;
        shop.close();
        busy = false;
    }

    function onActivityEnd() {
        if(lastActivity == "SellFish") {
            activityButton1.deactivate();
            selling = false;
            finishedSelling = true;
        }

        lastActivity = null;
    }

    var targetX = -2000.;

    function spawnCharacters() {
        for (m in level.l_Entities.all_Merchant) {
            var s = hxd.Res.img.merchant_tilesheet.toSprite2D(characters);
            s.x = m.pixelX;
            s.y = m.pixelY;
            s.animation.play();
        }

        for (m in level.l_Entities.all_FishMonger) {
            var s = hxd.Res.img.fishmonger_tilesheet.toSprite2D(characters);
            s.x = m.pixelX;
            s.y = m.pixelY;
            s.animation.play();
            fishMonger = s;
            fishMonger.animation.play("idle");
        }

        for (m in level.l_Entities.all_Dog) {
            dog = new TownDog(characters);
            dog.x = m.pixelX;
            dog.y = m.pixelY;
        }

        fisher = new TownCharacter(playerLayer);
        fisher.setX(934 + 32);
        fisher.y = 384;

        for (s in level.l_Entities.all_Shop_Sign) {
            var spr = hxd.Res.img.shopsignanimated_tilesheet.toSprite2D(entities);
            spr.x = s.pixelX;
            spr.y = s.pixelY;
            spr.animation.play();
        }
    }

    override function onRender(e:Engine) {
        super.onRender(e);
        var s = game.s2d;
        coinDisplay.x = s.width - 80;
        coinDisplay.y = 16;
    }

    var activityButtonReleased = true;

    override function update(dt:Float) {
        super.update(dt);

        coinDisplay.coins = data.gold;

        var newScale = world.scaleX - (world.scaleX - worldZoom) * 0.33;
        world.setScale(newScale);

        fisher.disableControls = busy;

        var newTargetX = (game.s2d.width * 0.5 - fisher.x * world.scaleX);
        newTargetX = Math.min(0, newTargetX);
        newTargetX = Math.max(-1280 * world.scaleX + game.s2d.width, newTargetX);

        targetX += (newTargetX - targetX);
        targetX = Math.max(-1280 * world.scaleX + game.s2d.width, targetX);

        world.x = Math.round(targetX);

        var newTargetY = (game.s2d.height * 0.5 - (fisher.y - 64) * world.scaleX);
        world.y = (newTargetY);

        parallax1.x = Math.round(-world.x / world.scaleX * 0.9);

        var setActivity = false;
        for (a in level.l_Entities.all_Activity) {
            if (a.pixelX < fisher.x && a.pixelX + a.width > fisher.x) {
                setActivity = true;

                lastActivity = a.f_ID;

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

        var activityButtonDown = (Key.isDown(Key.W) || Key.isDown(Key.UP) || activityButton1.pressed);

        if (currentActivity != null && activityButtonDown) {
            if (!activatePressed && activityButtonReleased) {
                activityButtonReleased = false;
                onActivity();
                activatePressed = true;
            }
        } else {
            if (activatePressed) {
                onActivityEnd();
            }
            activatePressed = false;
        }

        if (!activityButtonDown) {
            activityButtonReleased = true;
        }

        var v = currentActivity != null && !busy;
        var tAlpha = v ? 1.0 : 0.0;

        activityButton1.alpha += (tAlpha - activityButton1.alpha) * 0.2;
        activityButton1.update(dt);

        var l = Manager.get().listener;
        wavesEff.position.set(Math.max(fisher.x, 877), fisher.y, 200);
        townEff.position.set(Math.min(fisher.x, 700), fisher.y, 200);

        l.direction.set(0, 0, 1.0);
        l.up.set(0, 1, 0);
        l.position.set(fisher.x, fisher.y, 0);

        /*
        if (currentActivity == "SellFish" || currentActivity == "TradeItems") {
            coinDisplay.active = true;
        } else {
            coinDisplay.active = false;
        }
        */
        coinDisplay.active = true;

        fishInventory.active = (currentActivity == "SellFish");
        if (fishInventory.active) {
            var b = fishInventory.getBounds();
            fishInventory.y = Math.round((game.s2d.height - b.height) * 0.5);
            fishInventory.x = Math.round((game.s2d.width - b.width) * 0.8);
        }

        if (selling) {
            curSellTime += dt;
            if (curSellTime >= sellTime * sellTimeRatio) {
                curSellTime = .0;

                var f = fishInventory.pullFirstFish();
                if (f == null) {
                    return;
                }

                var point = new Point(f.x, f.y);
                point = fishInventory.localToGlobal(point);
                point = world.globalToLocal(point);

                f.x = point.x;
                f.y = point.y;

                characters.addChild(f);

                sellTimeRatio *= 0.9;
                sellTimeRatio = Math.max(minSellTimeRatio, sellTimeRatio);

                soldFishList.push(f);
                hxd.Res.sound.town.fishwhoos.play(false, 0.2);
            }
        }

        var tx = fishMonger.x + 41;
        var ty = fishMonger.y + 90;
        for (f in soldFishList) {
            var dx = (tx - f.x) * 0.28;
            var dy = (ty - f.y) * 0.15;
            f.x += dx;
            f.y += dy;
            f.rotation = -dx * 0.04;

            if (dx * dx + dy * dy < 0.5 * 0.5) {
                f.remove();
                soldFishList.remove(f);
                var info = Data.fish.get(f.fishKind);


                game.sound.playWobble(hxd.Res.sound.town.sellsound, 0.6);

                data.addSoldFish(info);

                totalSellPrice += info.SellPrice;
                lastSoldFishPrice.text = '+${info.SellPrice}$$';
                lastSoldFishPrice.alpha = 1.0;
            }
        }

        if (totalSellPrice > 0) {
            moneyGottenText.visible = true;
            moneyGottenText.text = '$$$totalSellPrice';
            if (!returnMoneyToBag) {
                var p = fishMonger.localToGlobal();
                moneyGottenText.x = p.x + 32;
                moneyGottenText.y = p.y - 32;
            }

            fishMonger.animation.play("pondering");
            sellingTime += dt;

            if (fishMonger.animation.currentFrame == 4) {
                Newgrounds.instance.unlockMedal(LongDeal);
            }

        } else {
            moneyGottenText.visible = false;
            sellingTime = 0;
        }

        if (finishedSelling && soldFishList.length == 0 && lastSoldFishPrice.alpha <= 0.3) {
            finishedSelling = false;
            if (totalSellPrice > 0) {
                returnMoneyToBag = true;
            }
        }

        lastSoldFishPrice.alpha *= 0.9;

        if (returnMoneyToBag) {
            lastSoldFishPrice.alpha = 0;

            var dx = (coinDisplay.x + 32 - moneyGottenText.x) * 0.3;
            var dy = (coinDisplay.y - moneyGottenText.y) * 0.2;
            moneyGottenText.x += dx;
            moneyGottenText.y += dy;
            if (dx * dx + dy * dy < 0.5 * 0.5) {
                returnMoneyToBag = false;
                data.addGold(totalSellPrice);
                totalSellPrice = 0;
                game.sound.playWobble(hxd.Res.sound.town.coinfinish, 0.3);
            }

            fishMonger.animation.play("accept", false, true, 0, (s) -> {
                fishMonger.animation.play("idle");
            });
        }
    }

    var sellingTime = 0.0;

    var activatePressed = false;

    override function onEvent(e:Event) {
        super.onEvent(e);
        if (!shop.showing) {
            return;
        }

        if (e.kind == EKeyDown) {
            if (e.keyCode == Key.A || e.keyCode == Key.LEFT) {
                shop.directionPressed(Left);
            }
            if (e.keyCode == Key.D || e.keyCode == Key.RIGHT) {
                shop.directionPressed(Right);
            }
            if (e.keyCode == Key.W || e.keyCode == Key.UP) {
                shop.directionPressed(Up);
            }
            if (e.keyCode == Key.S || e.keyCode == Key.DOWN) {
                shop.directionPressed(Down);
            }

            if (e.keyCode == Key.ENTER || e.keyCode == Key.E || e.keyCode == Key.SPACE) {
                shop.usePressed();
            }

            if (e.keyCode == Key.ESCAPE) {
                closeShop();
            }
        }
    }

    override function onLeave() {
        super.onLeave();
        container.remove();

        oceanAmbience.fadeTo(0, 0.3, () -> {
            oceanAmbience.stop();
            oceanAmbience = null;
        });

        townAmbience.fadeTo(0, 0.3, () -> {
            townAmbience.stop();
            townAmbience = null;
        });

        for (s in soundSources) {
            s.fadeTo(0, 0.4, () -> {
                s.stop();
            });
        }
    }
}   