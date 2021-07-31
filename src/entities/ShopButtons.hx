package entities;

import h2d.ScaleGrid;
import h2d.Text;
import h2d.Interactive;
import h2d.Object;

class Button extends Interactive {
    var text : Text;
    var bg : ScaleGrid;
    public var description = "";
    public function new(text: String, ?p) {
        super(120, 38, p);

        bg = new ScaleGrid(hxd.Res.img.buttonbg.toTile(), 3, 3, 3, 3, this);
        this.text = new Text(hxd.Res.fonts.picory.toFont(), this);
        this.text.text = text;
        this.text.textColor = 0xFFFFFF;
        this.text.textAlign = Center;
        bg.width = width;
        bg.height = height;
        this.text.x = Math.round(width * 0.5);
        this.text.y = Math.round((height - this.text.textHeight) * 0.5);
    }
}

class ShopButtons extends Object {
    public var buttonsList : Array<Button>;
    public var goFishBtn: Button;
    public var selectedIndex = 0;

    public function getSelectedItem() {
        return buttonsList[selectedIndex];
    }

    public function selectPrevious() {
        selectedIndex--;
        if (selectedIndex < 0) {
            selectedIndex = buttonsList.length - 1;
        }
    }

    public function selectNext() {
        selectedIndex++;

        if (selectedIndex >= buttonsList.length) {
            selectedIndex = 0;
        }
    }

    public function new(?p) {
        super(p);

        buttonsList = [];

        var b = new Button("Close Shop", this);
        b.description = "Bring back whatever you manage catch!";
        b.name = "exit";
        buttonsList.push(b);
        goFishBtn = b;

        b.y = 2;
    }
}