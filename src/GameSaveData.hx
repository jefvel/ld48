import hxd.Save;
import elke.Game;

class GameSaveData {
	public var currentRound = 1;

	public var totalGold = 0;
	public var gold = 0;

	public var museumGold = 0;

	public var missed = 0;
	public var caught = 0;

	public var bestMaxCombo = 0;

	public var playTime = 0.0;

	public var currentDebt = 15000;
	public var totalSoldFish = 0;
	public var totalSoldFishValue = 0;

	public var unlockedMedals = new Map<Data.MedalsKind, Bool>();
	public var personalHighscore = 0;
	public var interactedWith : Array<String> = [];

	public var ownedFish : Array<Data.FishKind> = [
		// Basic, Basic, Basic, Basic2, Basic2, Eel,
		// Basic, Basic, Basic, Basic2, Basic2, Eel,
		// Basic, Basic, Basic, Basic2, Basic2, Eel,
		// Basic, Basic, Basic, Basic2, Basic2, Eel,
	];

	public var donatedFish: Array<Data.FishKind> = [];

	public var unlocked:Map<Data.Items_Type, Int>;

	public var talkedToMuseumLady = 0;

	// Dog stuff
	public var caughtBone = false;
	public var dogHasBone = false;
	
	public var hasDonatedAllFish = false;

	public function new() {
		unlocked = new Map<Data.Items_Type, Int>();
		unlocked.set(Line, 0);
		unlocked.set(Strength, 0);
		unlocked.set(MoneyMultiplier, 0);
		unlocked.set(Speed, 0);
		unlocked.set(Magnet, 0);
		unlocked.set(Protection, 0);
	}

	#if debug
	static inline final hash = false;
	#else
	static inline final hash = true;
	#end

	public function save() {
		Save.save(current, "save", hash);
	}

	public static function load() {
		current = Save.load(new GameSaveData(), "save", hash);
	}

	public function addGold(amount) {
		gold += amount;
		totalGold += amount;

		Newgrounds.instance.submitHighscore(Data.scoreboards.get(MostFishSold).NewgroundsID, totalGold * 100);
	}

	public function addSoldFish(f: Data.Fish) {
		totalSoldFish ++;
		totalSoldFishValue += f.SellPrice;
	}

	static var current: GameSaveData;
	public static function reset() {
		current = null;
		return getCurrent();
	}

	public static function getCurrent() {
		if (current == null) {
			load();
		}

		return current;
	}
}