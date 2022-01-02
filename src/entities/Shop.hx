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

    var data : GameSaveData;

    var buttons: ShopButtons;

    var descriptionPadding = 8;
    var categoryDescription : Text;
    var descriptionBg: ScaleGrid;
    var levels:UpgradeLevels;

    public var onClose : Void -> Void;
    public var onWin : Void -> Void;

    public function new(data: GameSaveData, ?p) {
        super(p);

        data = GameSaveData.getCurrent();
        bg = new Bitmap(Tile.fromColor(0xf3e181, 1,1, 0.2), this);
        container = new Object(this);
        sign = new Bitmap(hxd.Res.img.shopsign.toTile(), container);
        sign.x = 15;
        sign.y = 19;

        keeper = new ShopKeeper(sign);
        keeper.x = 4;
        keeper.y = sign.tile.height + 80;

        alpha = 0;
        itemList = new ItemList(data, container);
        itemList.y = sign.y + sign.tile.height;
        itemList.x = sign.x; // + sign.tile.width + 32;

        descriptionBg = new ScaleGrid(hxd.Res.img.descriptionbg.toTile(), 4, 6, 4, 4, container);
        descriptionBg.x = itemList.x;
        descriptionBg.y = itemList.y + 140 - 3;
        descriptionBg.width = 140;
        descriptionBg.height = 100;

        container.addChild(itemList);

        categoryDescription = new Text(hxd.Res.fonts.picory.toFont(), container);
        categoryDescription.maxWidth = 140 - descriptionPadding * 2;
        categoryDescription.x = itemList.x + descriptionPadding;
        categoryDescription.y = itemList.y + 140 + descriptionPadding;

        buttons = new ShopButtons(container);

        cursor = new ScaleGrid(hxd.Res.img.frame.toTile(), 4, 4, 4, 4, this);

        cursor.width = 200;
        cursor.height = 43;

        buttons.goFishBtn.onClick = e -> {
            doClose();
        }

        this.data = data;

        levels = new UpgradeLevels(data, container);
        levels.y = categoryDescription.y + 40;
        levels.x = 311;
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

        var s = getScene();
        buttons.x = s.width - 128; //itemList.x + 248;
        buttons.y = s.height - 48;//itemList.y + 4;
    }

    public function close() {
        showing = false;
        buttons.remove();
    }

    public function directionPressed(d: Direction) {
        Game.instance.sound.playWobble(hxd.Res.sound.cursor, 0.5);
        keeper.resetSay();
        if (d == Up || d == Down) {
            itemListSelected = !itemListSelected;
            if (!itemListSelected) {
                buttons.selectedIndex = itemList.selectedIndex;
                if (buttons.selectedIndex >= buttons.buttonsList.length) {
                    buttons.selectedIndex = buttons.buttonsList.length - 1;
                }
            }
        }

        if (itemListSelected) {
            if (d == Left) {
                itemList.selectPrevious();
            }
            if (d == Right) {
                itemList.selectNext();
            }
        } else {
            if (d == Left) {
                buttons.selectPrevious();
            }
            if (d == Right) {
                buttons.selectNext();
            }
        }
    }

    function doClose() {
        onClose();
    }

    public function usePressed() {
        keeper.resetSay();
        if (itemListSelected) {
            var item = itemList.getSelectedItem();
            if (item != null && item.maxed) {
                return;
            }

            if (item != null) {
                if (item.info.Price <= data.gold) {
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

        data.gold -= item.Price;
        if (!item.OneTimePurchase) {
            data.unlocked[item.Type] ++;
        } else {
            data.unlockedOneTimePurchases[item.ID] = true;
        }

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

        var selected = itemList.getSelectedItem();
        if (selected != null) {
            categoryDescription.text = selected.info.ItemType.Description;
        } else {
            categoryDescription.text = "";
        }

        descriptionBg.height = 3 + descriptionPadding * 2 + categoryDescription.textHeight; 

    }
}