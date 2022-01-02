package entities;

import h2d.ScaleGrid;
import h2d.Text;
import h2d.Bitmap;
import h2d.Object;
import elke.entity.Entity2D;

class Item extends Object {
    var bg : ScaleGrid;
    var coinBg: ScaleGrid;
    public var info: Data.Items;
    public var icon: Bitmap;
    var itemTypeText: Text;
    var text : Text;
    var costText : Text;
    public var maxed: Bool = false;

    public var available = false;
    public var isSelected = false;

    public var width = 140;
    public var height = 140;

    public function new(i: Data.Items, ?p) {
        super(p);
        this.info = i;
        bg = new ScaleGrid(hxd.Res.img.itembg.toTile(), 4, 4, 4, 32, this);
        coinBg = new ScaleGrid(hxd.Res.img.coinbg.toTile(), 4, 4, 4, 4, this);
        coinBg.width = width;
        coinBg.height = 32;
        coinBg.y = height - 32;
        bg.width = width;
        bg.height = height;
        var t = hxd.Res.loader.load(i.Icon.file).toTile();
        var s = t.sub(i.Icon.size * i.Icon.x, i.Icon.size * i.Icon.y, i.Icon.size, i.Icon.size);

        icon = new Bitmap(s, this);
        icon.y = 4;
        icon.x = 3;

        itemTypeText = new Text(hxd.Res.fonts.futilepro_medium_12.toFont(), this);
        itemTypeText.text = i.ItemType.Name;
        itemTypeText.x = 8;
        //icon.x + s.width + 4;
        itemTypeText.y = 7;
        itemTypeText.alpha = 0.6;

        icon.x = 6;
        icon.y = itemTypeText.y + itemTypeText.textHeight + 6;

        text = new Text(hxd.Res.fonts.picory.toFont(), this);
        text.text = i.Name;
        text.x = icon.x + s.width + 4;
        text.y = icon.y + 2;//itemTypeText.y + itemTypeText.textHeight + 2;//Math.round((height - text.textHeight) * 0.5);
        text.maxWidth = 90;

        coin = new Bitmap(hxd.Res.img.coin.toTile(), this);
        var cp = (32 + coin.tile.height) * 0.5;
        coin.x = cp - 16;
        coin.y = Math.round(height - cp) - 1;
        costText = new Text(hxd.Res.fonts.equipmentpro_medium_12.toFont(), this);
        costText.textAlign = Left;
        costText.text = '${i.Price}';
        costText.x = coin.x + coin.tile.width + 4;//width - 9;
        costText.y = Math.round(height - (32 + costText.textHeight) * 0.5) - 1;
    }
    var coin: Bitmap;

    var ty = 0.;
    public function update(dt: Float) {
        if (!available) {
            coinBg.visible = false;
            costText.textColor = 0xff7777;
        } else {
            coinBg.visible = true; 
            costText.textColor = 0x222222;
        }

        if (maxed) {
            coinBg.visible = true;
            if (coinBg.color == null) {
                coinBg.color = new h3d.Vector();
            }

            coinBg.color.set(0.2, 0.7, 0.3);
            costText.text = "Maxed";
            costText.textColor = 0xffffff;
            coin.visible = false;
            costText.x = width * 0.5;
            costText.alpha = 0.9;
            costText.textAlign = Center;
        }

        var ta = isSelected ? 1. : 0.7;
        alpha += (ta - alpha) * 0.3;

        var targetY = isSelected ? 0. : 8.;
        ty += (targetY - ty) * 0.34;
        y = Math.round(ty);
    }
}

class ItemList extends Entity2D {
    var data : GameSaveData;
    public var items: Array<Item>;
    public var selectedIndex = 0;
    var container : Object;

    public function new(data: GameSaveData,?p) {
        super(p);
        items = [];

        this.data = data;
        container = new Object(this);

    }

    public function getSelectedItem() {
        return items[selectedIndex];
    }

    public function selectPrevious() {
        selectedIndex--;
        if (selectedIndex < 0) {
            selectedIndex = items.length - 1;
        }
    }

    public function selectNext() {
        selectedIndex++;

        if (selectedIndex >= items.length) {
            selectedIndex = 0;
        }
    }

    var tx = 0.;
    override function update(dt:Float) {
        super.update(dt);
        var selected = items[selectedIndex];

        for (i in items) {
            var canAfford = data.gold >= i.info.Price;
            i.available = canAfford;
            i.isSelected = selected == i;
            i.update(dt);
        }

        if (selected != null) {
            container.x = -selected.x;
            tx += (-selected.x - tx) * 0.4;
            container.x = Math.round(tx);
        } else {
            container.x = 0;
        }
    }

    public function refreshItems() {
        container.removeChildren();
        items = [];

        var unlocked = data.unlocked;
        for (i in Data.items.all) {
            if (i.Disabled) {
                continue;
            }

            var upgradeIndex = 0;
            if (unlocked.exists(i.Type)) {
                upgradeIndex = unlocked.get(i.Type);
            }

            var maxed =  i.ItemType.Values.length - 1 == i.UpgradeIndex && upgradeIndex == i.UpgradeIndex; 
            var purchasedOneTimePurchase = i.OneTimePurchase && data.unlockedOneTimePurchases.exists(i.ID);
            if (purchasedOneTimePurchase) {
                continue;
            }

            if (i.UpgradeIndex == upgradeIndex + 1 || maxed) {
                var item = new Item(i, container);
                item.maxed = maxed;
                item.x = items.length * (item.width + 8) + 4;
                items.push(item);
            }
        }

        if (selectedIndex >= items.length) {
            selectedIndex = items.length - 1;
        }
    }
}