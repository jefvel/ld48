package entities;

import h2d.Text;
import elke.Game;
import elke.sound.Sounds;
import h2d.ScaleGrid;
import h2d.Tile;
import h2d.Bitmap;
import h2d.Object;
import gamestates.PlayState;
import elke.entity.Entity2D;

class Shop extends Entity2D {
    public var container : Object;
    var bg : Bitmap;
    var sign : Bitmap;

    var itemList : ItemList;
    var cursor: ScaleGrid;

    var itemListSelected = true;
    var keeper: ShopKeeper;

    var state : PlayState;

    var goldText: Text;
    var coin: Bitmap;

    var debtText: Text;

    var buttons: ShopButtons;

    public var onClose : Void -> Void;
    public var onWin : Void -> Void;

    public function new(state: PlayState, ?p) {
        super(p);
        bg = new Bitmap(Tile.fromColor(0xf3e181, 1,1, 0.2), this);
        container = new Object(this);
        sign = new Bitmap(hxd.Res.img.shopsign.toTile(), container);
        sign.x = 30;
        sign.y = 30;

        keeper = new ShopKeeper(sign);
        keeper.x = 4;
        keeper.y = sign.tile.height + 80;

        alpha = 0;
        itemList = new ItemList(state, container);
        itemList.y = sign.y + 48;
        itemList.x = sign.x + sign.tile.width + 32;

        buttons = new ShopButtons(container);
        buttons.y = itemList.y + 4;
        buttons.x = itemList.x + 248;

        cursor = new ScaleGrid(hxd.Res.img.frame.toTile(), 4, 4, 4, 4, this);

        cursor.width = 200;
        cursor.height = 43;

        goldText = new Text(hxd.Res.fonts.equipmentpro_medium_12.toFont(), container);
        goldText.textAlign = Right;
        goldText.y = sign.y;

        coin = new Bitmap(hxd.Res.img.coin.toTile(), goldText);
        coin.y = -0;
        coin.x = -goldText.textWidth - 19;

        buttons.goFishBtn.onClick = e -> {
            doClose();
        }

        buttons.payDebtBtn.onClick = e -> {
            tryWin();
        }

        debtText = new Text(hxd.Res.fonts.equipmentpro_medium_12.toFont(), buttons);
        debtText.textAlign = Center;
        debtText.x = Math.round(buttons.payDebtBtn.width * 0.5);
        debtText.y = -debtText.textHeight - 8;

        this.state = state;
    }

    public var showing = false;
    public function show() {
        alpha = -2.5;
        bg.alpha = 0.0;
        container.x = -50;
        showing = true;
        itemList.refreshItems();
        itemListSelected = true;
        itemList.selectedIndex = 0;
        container.addChild(buttons);
    }

    public function close() {
        showing = false;
        buttons.remove();
    }

    public function directionPressed(d: Direction) {
        Game.instance.sound.playWobble(hxd.Res.sound.cursor, 0.5);
        keeper.resetSay();
        if (d == Left || d == Right) {
            itemListSelected = !itemListSelected;
            if (!itemListSelected) {
                buttons.selectedIndex = itemList.selectedIndex;
                if (buttons.selectedIndex >= buttons.buttonsList.length) {
                    buttons.selectedIndex = buttons.buttonsList.length - 1;
                }
            }
        }

        if (itemListSelected) {
            if (d == Up) {
                itemList.selectPrevious();
            }
            if (d == Down) {
                itemList.selectNext();
            }
        } else {
            if (d == Up) {
                buttons.selectPrevious();
            }
            if (d == Down) {
                buttons.selectNext();
            }
        }
    }

    var won = false;
    function tryWin() {
        if (won) {
            return;
        }

        if (state.gold >= state.currentDebt) {
            state.gold -= state.currentDebt;
            Game.instance.sound.playWobble(hxd.Res.sound.purchase, 0.6);
            onWin();
            won = true;
        } else {
            Game.instance.sound.playWobble(hxd.Res.sound.forbidden);
        }
    }

    function doClose() {
        if (won) {
            return;
        }

        onClose();
    }


    public function usePressed() {
        keeper.resetSay();
        if (itemListSelected) {
            var item = itemList.getSelectedItem();
            if (item != null) {
                if (item.info.Price <= state.gold) {
                    purchaseItem(item.info);
                } else {
                    Game.instance.sound.playWobble(hxd.Res.sound.forbidden);
                }
            }
        } else {
            var btn = buttons.getSelectedItem();
            if (btn.name == "exit") {
                doClose();
            }

            if (btn.name == "purchase") {
                tryWin();
            }
        }
    }

    public function purchaseItem(item: Data.Items) {
        var msgs = [
            "Thank you",
            "Good purchase dude",
            "Wise choice!",
            "This will help you a lot.",
            "You wont regret this!",
            "Happy fishing!",
            "Thanks for the purchase",
            "Everyone loves this item, you will too",
            "You're my favourite customer",
        ];

        state.gold -= item.Price;
        state.unlocked[item.Type] ++;
        itemList.refreshItems();
        keeper.say(msgs[Std.int(Math.random() * msgs.length)], 2.0);
        Game.instance.sound.playWobble(hxd.Res.sound.purchase, 0.6);
    }


    public function updateCursor() {
        if (itemListSelected) {
            var item = itemList.getSelectedItem();
            if (item == null) {
                itemListSelected = false;
                return;
            }

            var b = item.localToGlobal();
            cursor.x = b.x;
            cursor.y = b.y;

            cursor.width = item.width;
            cursor.height = item.height;

            keeper.say(item.info.Description);
        } else {
            var item = buttons.getSelectedItem();
            if (item == null) {
                return;
            }

            var b = item.localToGlobal();
            cursor.x = b.x;
            cursor.y = b.y;

            cursor.width = item.width;
            cursor.height = item.height;
            keeper.say(item.description);
        }
    }

    override function update(dt:Float) {
        super.update(dt);
        var s = getScene();
        bg.tile.setSize(s.width, s.height);


        if (showing) {
            visible = true;
            container.x *= 0.8;
            alpha += (1.0 - alpha) * 0.2;
            bg.alpha += (1.0 - alpha) * 0.1;

            goldText.x = itemList.x + 232;
            goldText.text = '${state.gold}';
            coin.x = -55;

            debtText.text = 'Debt: ${state.currentDebt}';

            buttons.payDebtBtn.alpha = (state.gold >= state.currentDebt) ? 1.0 : 0.6;

            updateCursor();
        } else {
            container.x += (20 - container.x) * 0.1;
            alpha += (0.0 - alpha) * 0.4;
            bg.alpha += (1.0 - alpha) * 0.3;

            if (alpha <= 0) {
                visible = false;
                buttons.remove();
            }
        }
    }
}