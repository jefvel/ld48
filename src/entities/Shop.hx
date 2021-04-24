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
        cursor = new ScaleGrid(hxd.Res.img.frame.toTile(), 4, 4, 4, 4, this);

        cursor.width = 200;
        cursor.height = 43;

        goldText = new Text(hxd.Res.fonts.equipmentpro_medium_12.toFont(), container);
        goldText.textAlign = Right;
        goldText.y = sign.y;
        coin = new Bitmap(hxd.Res.img.coin.toTile(), goldText);
        coin.y = -0;
        coin.x = -goldText.textWidth - 4;
        
        this.state = state;
    }

    public var showing = false;
    public function show() {
        alpha = -2.5;
        bg.alpha = 0.0;
        container.x = -50;
        showing = true;
        itemList.refreshItems();
    }

    public function close() {
        showing = false;
    }

    public function directionPressed(d: Direction) {
        Game.instance.sound.playWobble(hxd.Res.sound.cursor, 0.5);
        keeper.resetSay();
        if (d == Left || d == Right) {
            itemListSelected = !itemListSelected;
        }

        if (itemListSelected) {
            if (d == Up) {
                itemList.selectPrevious();
            }
            if (d == Down) {
                itemList.selectNext();
            }
        }
    }

    public function usePressed() {
        keeper.resetSay();
        if (itemListSelected) {
            var item = itemList.getSelectedItem();
            if (item != null) {
                if (item.info.Price <= state.gold) {
                    purchaseItem(item.info);
                }
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

            goldText.x = itemList.x + 240;
            goldText.text = '${state.gold}';
            coin.x = -49;

            updateCursor();
        } else {
            container.x += (20 - container.x) * 0.1;
            alpha += (0.0 - alpha) * 0.4;
            bg.alpha += (1.0 - alpha) * 0.3;

            if (alpha <= 0) {
                visible = false;
            }
        }
    }
}