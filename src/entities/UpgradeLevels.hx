package entities;

import h2d.Text;
import h2d.RenderContext;
import h2d.Bitmap;
import elke.entity.Entity2D;

class UpgradeLevels extends Entity2D {
	var barsMap:Map<Data.Items_Type, ProgressDots>;
	var labelsMap:Map<Data.Items_Type, Text>;
	var data: GameSaveData;

	public function new(data: GameSaveData, ?p) {
		super(p);
		barsMap = new Map();
		labelsMap = new Map();
		this.data = data;

		loadBars();
	}

	function loadBars() {
		var i = 0;
		var t = hxd.Res.img.itemicons.toTile();

		for (key => value in data.unlocked) {
			if (!Data.items.all.filter(f -> f.Type == key)[0].ItemType.ShowLevel) {
				continue;
			}

			var category = Data.items.all.filter(f -> f.Type == key)[0].ItemType;
			var max = Data.items.all.filter(f -> f.Type == key).length;

			var bar = new ProgressDots(max, this);
			if (category.Icon != null) {
				var i = category.Icon;
				var icon = new Bitmap(t.sub(i.x * i.size, i.y * i.size, i.size, i.size), bar);

				icon.x = -i.size - 4;
			}

			bar.value = value;
			barsMap[key] = bar;

			var text = new Text(hxd.Res.fonts.picory.toFont(), bar);
			text.x = bar.width + 4;
			text.y = Math.round((bar.height - text.textHeight) * 0.5);
			labelsMap[key] = text;

			bar.y = i * 18;
			i ++;
		}
	}

	override function sync(ctx:RenderContext) {
		super.sync(ctx);

		var unlocked = data.unlocked;
		var length = Data.itemCategories.get(Line).Values[unlocked.get(Line)].Value;
		var pole = Data.itemCategories.get(Pole).Values[unlocked.get(Strength)].Value;
		var sinkSpeed = Data.itemCategories.get(Weight).Values[unlocked.get(Speed)].Value;
		var boostDepth = Data.itemCategories.get(Weight).Values[unlocked.get(Speed)].SecondaryValue;
		for (key => value in data.unlocked) {
			var label = labelsMap[key];
			if (label == null) {
				continue;
			}

			label.text = switch (key) {
				case Speed: 'Boost to ${Math.round(boostDepth / Const.UNITS_PER_METER)} m';
				case Line: 'Reel length ${Math.round(length / Const.UNITS_PER_METER)} m';
				case Strength: 'Max weight ${pole} kg';
				default: '';
			}
		}

	}

	public override function update(dt:Float) {
		super.update(dt);
		for (key => value in data.unlocked) {
			var bar = barsMap[key];
			if (bar == null) {
				continue;
			}

			bar.value = data.unlocked[key];
		}
	}
}