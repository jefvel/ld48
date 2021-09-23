package entities;

import h2d.Text;
import h2d.Tile;
import h2d.TileGroup;
import h2d.ScaleGrid;
import elke.entity.Entity2D;

class FishInventory extends Entity2D {
	var data : GameSaveData;
	var bg : ScaleGrid;
	var padding = 3;
	var w = 128;
	var h = 128;

	var fishes:TileGroup;
	var tile: Tile;
	public var active = false;

	var tileMap : Map<Data.FishKind, Tile>;
	var title : Text;

	var emptyText: Text;

	public function new(data: GameSaveData,?p) {
		super(p);
		this.data = data;

		bg = new ScaleGrid(hxd.Res.img.inventorybg.toTile(), 4, 4, 4, 4, this);
		bg.width = w + padding * 2;
		bg.height = h + padding * 2;

		tile = hxd.Res.img.fishIcons.toTile();
		fishes = new TileGroup(tile, this);
		fishes.x = fishes.y = padding;
		alpha = 0;

		tileMap = new Map<Data.FishKind, Tile>();

		for (fish in Data.fish.all) {
			tileMap.set(fish.ID, tile.sub(
				fish.Icon.x * fish.Icon.size,
				fish.Icon.y * fish.Icon.size,
				fish.Icon.size,
				fish.Icon.size
			));
		}

		title = new Text(hxd.Res.fonts.picory.toFont(), this);
		title.y = -14;
		title.x = 2;
		title.text = "Your Fish Inventory";

		emptyText = new Text(title.font, this);
		emptyText.text = "-- Empty --";
		emptyText.alpha = 0.6;
		emptyText.textAlign = Center;
		emptyText.x = w >> 1;
		emptyText.y = h >> 1;
	}

    public function pullFirstFish() {
		var id = data.ownedFish.shift();
		if (id == null) {
			return null;
		}

		var f = new BasicFish(id, tileMap.get(id), this);
		f.x = padding + 16;
		f.y = padding + 16;

		return f;
    }

	public override function update(dt:Float) {
		super.update(dt);

		var targetAlpha = 0.;
		if (active) {
			targetAlpha = 1.0;
		}

		this.alpha += (targetAlpha - this.alpha) * 0.2;

		if (!active) {
			return;
		}

		fishes.clear();

		var fx = 0;
		var fy = 0;

		var spacing = 8;
		var fishPerRow = Math.floor((w - padding - 16) / spacing);
		for (f in data.ownedFish) {
			if(!Data.fish.get(f).CanDonate) {
				continue;
			}

			var t = tileMap.get(f);
			fishes.add(fx * spacing, fy * spacing * 2 + 4, t);
			fx ++;

			if (fx >= fishPerRow) {
				fx = 0;
				fy ++;
			}
		}

		emptyText.visible = data.ownedFish.length == 0;
	}
}