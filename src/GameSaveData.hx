class GameSaveData {
	public var currentRound = 0;

	public var totalGold = 0;
	public var gold = 0;

	public var missed = 0;
	public var caught = 0;

	public var bestMaxCombo = 0;

	public var playTime = 0.0;

	public var currentDebt = 15000;
	public var totalSoldFish = 0;
	public var totalSoldFishValue = 0;

	public var ownedFish : Array<Data.FishKind> = [
		Basic, Basic, Basic, Basic2, Basic2, Eel,
		Basic, Basic, Basic, Basic2, Basic2, Eel,
		Basic, Basic, Basic, Basic2, Basic2, Eel,
		Basic, Basic, Basic, Basic2, Basic2, Eel,
	];

	public var unlocked:Map<Data.Items_Type, Int>;


	public function new() {
		unlocked = new Map<Data.Items_Type, Int>();
		unlocked.set(Line, 0);
		unlocked.set(Strength, 0);
		unlocked.set(MoneyMultiplier, 0);
		unlocked.set(Speed, 0);
		unlocked.set(Magnet, 0);
		unlocked.set(Protection, 0);
	}

	public function addGold(amount) {
		gold += amount;
		totalGold += amount;
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
			current = new GameSaveData();
		}

		return current;
	}
}