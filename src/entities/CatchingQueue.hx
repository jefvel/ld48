package entities;

import h2d.Bitmap;
import h2d.RenderContext;
import elke.res.TileSheetRes;
import elke.graphics.Animation;
import elke.res.TileSheetRes.TileSheetConfig;
import h2d.Tile;
import h2d.SpriteBatch;
import elke.entity.Entity2D;

enum FishQueueMode {
	InQueue;
	Caught;
	Missed;
}

typedef FishListItem = {
	fish: Fish,
	b: BatchElement,
	mode: FishQueueMode,
}

class CatchingQueue extends Entity2D {
	public var fishList: Array<FishListItem>;

	var rootTile : Tile;

	var sprites: SpriteBatch;
	var fishIconCache: Map<Data.FishKind, Tile>;

	public var bag: Bitmap;

	public var maxWidth = 300.0;

	public function new(?p) {
		super(p);
		rootTile = hxd.Res.img.fishIcons.toTile();
		sprites = new SpriteBatch(rootTile, this);
		fishList = [];
		fishIconCache = new Map<Data.FishKind, Tile>();
		bag = new Bitmap(hxd.Res.img.bag.toTile(), this);
		bag.tile.dx = bag.tile.dy = -16;
		bag.x = -32;
		bag.y = -16;
	}

	public function addFish(f: Fish) {
		var tile : Tile = null;

		if (fishIconCache.exists(f.data.ID)) {
			tile = fishIconCache[f.data.ID];
		} else {
			var icon = f.data.Icon;
			tile = rootTile.sub(
				icon.x * icon.size,
				icon.y * icon.size, 
				icon.size, 
				icon.size, 
				-icon.size >> 1, 
				-icon.size >> 1
			);

			fishIconCache[f.data.ID] = tile;
		}

		var el = new BatchElement(tile);

		el.alpha = 0.0;
		el.x = fishSpacing * fishList.length;
		el.y = 10.0;

		fishList.push({
			fish: f,
			b: el,
			mode: InQueue,
		});
	}

	public function clearFish() {
		fishList = [];
	}


	public function fishCaught(f: Fish) {
		for (fl in fishList) {
			if (f == fl.fish) {
				fl.mode = Caught;
				return;
			}
		}
	}

	public function fishMissed(f: Fish) {
		for (fl in fishList) {
			if (f == fl.fish) {
				fl.mode = Missed;
				return;
			}
		}
	}

	public function moveFishToEnd(f : Fish) {
		for (fl in fishList) {
			if (fl.fish == f) {
				fishList.remove(fl);
				fishList.push(fl);
				return;
			}
		}
	}

	var fishSpacing = 4.0;

	var time = 0.;
	override function update(dt:Float) {
		super.update(dt);
		time += dt;

		sprites.clear();

		var i = 0;
		var freq = 0.4;
		if (fishList.length > 0) {
			fishSpacing = Math.min(16, maxWidth / fishList.length);
		}

		var catchSpeed = 0.2;

		for (fish in fishList) {
			var el = fish.b;

			var targetX:Float = Math.round(i * fishSpacing);
			var targetY:Float = Math.round(Math.sin(time * 0.5 + i * freq) * 2);
			var targetAlpha = 1.0;

			var fadeSpeed = 0.2;
			var moveSpeed = 0.2;

			var removedFromQueue = false;

			if (fish.mode != InQueue) {
				targetAlpha = 0.0;
				fadeSpeed = 0.0;
				moveSpeed = catchSpeed;
			}

			if (fish.mode == Caught) {
				targetX = bag.x;
				targetY = bag.y;
				el.g = 1;
				el.r = el.b = 0;
				moveSpeed = 0.2;
			}

			if (fish.mode == Missed) {
				targetY = 20;
				targetX = el.x;
				el.r = 1;
				el.g = el.b = 0;
			}

			if (fish.mode == InQueue) {
				targetY += Math.min(10, Math.max(0, targetX - el.x));
			}

			el.x += (targetX - el.x) * moveSpeed;
			el.y += (targetY - el.y) * moveSpeed;

			if (fish.mode != InQueue) {
				if (Math.abs(el.y - targetY) < 1) {
					if (fish.mode == Missed) {
						fadeSpeed = 0.1;
					} else {
						fadeSpeed = 1.0;
					}
					removedFromQueue = true;
				} else {
					catchSpeed *= 0.5;
				}
			}

			el.alpha += (targetAlpha - el.alpha) * fadeSpeed;


			if (fish.mode != InQueue) {
				if (el.alpha <= 0.01) {
					fishList.remove(fish);

					if (fish.mode == Caught) {
						bag.scaleX = 1 + Math.random() * 0.3;
						bag.scaleY = 1 + Math.random() * 0.3;
					}
				}
			}


			sprites.add(el, true);

			if (!removedFromQueue) {
				i++;
			}
		}

		bag.scaleX += (1.0 - bag.scaleX) * 0.2;
		bag.scaleY += (1.0 - bag.scaleY) * 0.1;
	}
}