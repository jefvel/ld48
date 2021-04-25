package gamestates;

import elke.process.Timeout;
import hxd.snd.Channel;
import h2d.Text;
import h2d.Object;
import h2d.Bitmap;
import elke.gamestate.GameState;

class WonGameState extends GameState {
    var playState : PlayState;
    var container : Object;
    var diploma: Bitmap;

    var daysTxt : Text;
    var winSong : Channel;
    var envelope : Bitmap;

    public function new(playState: PlayState) {
        this.playState = playState;
    }

    override function onEnter() {
        super.onEnter();
        container = new Object(game.s2d);
        diploma = new Bitmap(hxd.Res.img.diploma.toTile(), container);
        var fnt = hxd.Res.fonts.equipmentpro_medium_12.toFont();
        daysTxt = new Text(fnt, diploma);
        daysTxt.textColor = 0x4b314e;
        daysTxt.text = '${playState.currentRound}';
        daysTxt.x = 239;
        daysTxt.y = 104;

        var accTxt = new Text(fnt, diploma);
        accTxt.textColor = 0x4b314e;
        var accuracy = playState.missed == 0 || playState.caught == 0 ? 'Perfect' : '${Math.round((playState.caught / (playState.missed + playState.caught)) * 100)}%';
        accTxt.text = accuracy;
        accTxt.x = 284;
        accTxt.y = 125;

        var comboTxt = new Text(fnt, diploma);
        comboTxt.textColor = 0x4b314e;
        comboTxt.text = '${playState.maxCombo}';
        comboTxt.x = 247;
        comboTxt.y = 145;

        var time = playState.playTime;

        var minutes = Math.floor(time / 60);
        var seconds = Math.floor(time - minutes * 60);

        var s = seconds < 10 ? '0${seconds}': '${seconds}';
        var m = minutes < 10 ? '0${minutes}': '${minutes}';

        var timeTxt = new Text(fnt, diploma);
        timeTxt.textColor = 0x4b314e;
        timeTxt.text = '${m}:${s}';
        timeTxt.x = 211;
        timeTxt.y = 164;

        var goldTxt = new Text(fnt, diploma);
        goldTxt.textColor = 0x4b314e;
        goldTxt.text = '${playState.totalGold}';
        goldTxt.x = 214;
        goldTxt.y = 180;

        positionStuff();

        if (playState.gameMode == Chill) {
            var chill = new Bitmap(hxd.Res.img.chillstamp.toTile(), diploma);
            chill.x = 333;
            chill.y = 96;
        }

        winSong = hxd.Res.sound.winsong.play(true, 0.);
        new Timeout(0.6, () -> {
            winSong.fadeTo(0.5, 1.8);
        });

        new Timeout(3.3, () -> {
            envelopeSliding = true;
        });

        envelope = new Bitmap(hxd.Res.img.envelope.toTile(), diploma);
        envelope.x = 73;
        envelope.y = 30;
    }

    var envelopeSliding = false;

    function positionStuff() {
        diploma.x = Math.round((game.s2d.width - diploma.tile.width) * 0.5);
        diploma.y = Math.round((game.s2d.height - diploma.tile.height) * 0.5);

    }

    override function update(dt:Float) {
        super.update(dt);
        positionStuff();
        if (envelopeSliding) {
            envelope.y += (350 - envelope.y) * 0.03;
        }
    }

    override function onLeave() {
        super.onLeave();
        var f = winSong;
        winSong.fadeTo(0, 0.3, () -> {
            f.stop();
        });
    }
}