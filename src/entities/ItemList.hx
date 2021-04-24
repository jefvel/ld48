package entities;

import h2d.Text;
import h2d.Bitmap;
import h2d.Object;
import gamestates.PlayState;
import elke.entity.Entity2D;

class Item extends Object {
    public var info: Data.Items;
    public var icon: Bitmap;
    var text : Text;
    var costText : Text;

    public var width = 240;
    public var height = 40;

    public function new(i: Data.Items, ?p) {
        super(p);
        this.info = i;
        var t = hxd.Res.loader.load(i.Icon.file).toTile();
        var s = t.sub(i.Icon.size * i.Icon.x, i.Icon.size * i.Icon.y, i.Icon.size, i.Icon.size);

        icon = new Bitmap(s, this);
        icon.y = 4;
        icon.x = 3;

        text = new Text(hxd.Res.fonts.picory.toFont(), this);
        text.text = i.Name;
        text.x = icon.x + s.width + 4;
        text.y = Math.round((height - text.textHeight) * 0.5);

        costText = new Text(hxd.Res.fonts.m5x7_medium_12.toFont(), this);
        costText.textAlign = Right;
        costText.text = '${i.Price}';
        costText.x = width - 9;
        costText.y = Math.round((height - costText.textHeight) * 0.5);
    }
}

class ItemList extends Entity2D {
    var state : PlayState;
    public var items: Array<Item>;
    public var selectedIndex = 0;
    var container : Object;

    public function new(state: PlayState,?p) {
        super(p);
        items = [];

        this.state = state;
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

    override function update(dt:Float) {
        super.update(dt);
        for (i in items) {
            var canAfford = state.gold >= i.info.Price;
            i.alpha = canAfford ? 1.0 : 0.5;
        }
    }

    public function refreshItems() {
        container.removeChildren();
        items = [];

        var unlocked = state.unlocked;
        for (i in Data.items.all) {
            var upgradeIndex = 0;
            if (unlocked.exists(i.Type)) {
                upgradeIndex = unlocked.get(i.Type);
            }

            if (i.UpgradeIndex == upgradeIndex + 1) {
                var item = new Item(i, container);
                item.y = items.length * item.height + 4;
                items.push(item);
            }
        }

        if (selectedIndex >= items.length) {
            selectedIndex = items.length - 1;
        }
    }
}