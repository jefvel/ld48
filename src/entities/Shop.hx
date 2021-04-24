package entities;

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

    public function new(state: PlayState, ?p) {
        super(p);
        bg = new Bitmap(Tile.fromColor(0xFFFFFF, 1,1, 0.2), this);
        container = new Object(this);
        sign = new Bitmap(hxd.Res.img.shopsign.toTile(), container);
        sign.x = 30;
        sign.y = 30;
        alpha = 0;
        itemList = new ItemList(state, container);
        itemList.y = sign.y + 8;
        itemList.x = sign.x + sign.tile.width + 32;
        cursor = new ScaleGrid(hxd.Res.img.frame.toTile(), 4, 4, 4, 4, this);

        cursor.width = 200;
        cursor.height = 43;
    }

    public var showing = false;
    public function show() {
        alpha = -2.5;
        bg.alpha = 0.0;
        container.x = -20;
        showing = true;
        itemList.refreshItems();
    }

    public function close() {
        showing = false;
    }

    public function directionPressed(d: Direction) {
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
            var bounds = item.getBounds();
            cursor.width = item.width;
            cursor.height = item.height;
        }
    }

    override function update(dt:Float) {
        super.update(dt);
        var s = getScene();
        bg.tile.setSize(s.width, s.height);

        if (showing) {
            visible = true;
            container.x *= 0.4;
            alpha += (1.0 - alpha) * 0.2;
            bg.alpha += (1.0 - alpha) * 0.1;
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