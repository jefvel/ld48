package entities;

import h2d.filter.Bloom;
import h2d.Text;
import h2d.Bitmap;
import h2d.ScaleGrid;
import elke.entity.Entity2D;

class MedalPopup extends Entity2D {

	var medal : Data.Medals;
	var bg : ScaleGrid;
	var maxWidth = 256;
	var icon: Bitmap;

	var px = 8;
	var py = 8;
	var title : Text;
	var description: Text;

	public function new(medal: Data.Medals, ?p) {
		super(p);
		this.medal = medal;

		bg = new ScaleGrid(hxd.Res.img.medalbg.toTile(), 4, 4, 4, 4, this);
		bg.height = py * 2 + medal.Icon.size;
		bg.width = maxWidth;

		var tile = hxd.Res.img.medals.medals_png.toTile();
		var w = medal.Icon.size;
		icon = new Bitmap(tile.sub(medal.Icon.x * w, medal.Icon.y * w, w, w), this);

		icon.x = px;
		icon.y = py;

		title = new Text(hxd.Res.fonts.equipmentpro_medium_12.toFont(), this);
		title.x = px + icon.x + medal.Icon.size + 4;
		title.y = py;
		title.text = medal.Name;
		description = new Text(hxd.Res.fonts.picory.toFont(), title);
		description.y = title.textHeight + 4;
		description.text = medal.Description;
		description.maxWidth = maxWidth - px * 2 - 4 - medal.Icon.size;

		var b = title.getBounds();
		title.y = Math.round((bg.height - b.height) * 0.5);
		alpha = 0.8;

		hxd.Res.sound.medalunlock.play(false, 0.5);
		f = new Bloom(10, 10.0, 5.0);
		filter = f;
	}

	var fadingIn = true;
	var fadingOut = false;
	var timeLeft = 5.0;
	var offsetX = -6.;
	var spacing = 8;
	var f : h2d.filter.Bloom;

	override function update(dt:Float) {
		super.update(dt);
		f.power *= 0.9;
		f.amount *= 0.88;
		f.radius *= 0.94;

		var s = getScene();
		if (s == null) {
			return;
		}

		var b = getBounds();
		y = s.height - b.height - spacing;

		if (parent != null) {
			parent.addChild(this);
		}

		if (fadingOut) {
			alpha *= 0.9;
			if (alpha < 0.05) {
				remove();
			}
			return;
		}

		offsetX *= 0.9;
		x = Math.round(spacing + offsetX);
		if (fadingIn) {
			alpha += (1 - alpha) * 0.2;
			timeLeft -= dt;
			if (alpha >= 0.99) {
				if (timeLeft <= 0) {
					fadingOut = true;
				}
			}
		}
	}
}