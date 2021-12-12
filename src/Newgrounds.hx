import entities.MedalPopup;
import elke.Game;
import h2d.Object;
#if js
import io.newgrounds.NG;
import io.newgrounds.objects.Medal;
#end

class Newgrounds {
	public static var instance(get, null) : Newgrounds;
	var newgrounds: elke.things.Newgrounds;

	static var _instance: Newgrounds;
	var container: Object;
	function new() {
		newgrounds = elke.things.Newgrounds.initializeAndLogin();
		this.container = Game.instance.s2d;
	}

	public function unlockMedal(medal: Data.MedalsKind) {
		var unlockedMedals = GameSaveData.getCurrent().unlockedMedals;
		var m = Data.medals.get(medal);
		if (m == null) {
			return;
		}

		var showMedalPopup = true;
		if (unlockedMedals[medal]) {
			showMedalPopup = false;
			return;
		}

		newgrounds.unlockMedal(m.NewgroundsID);

		unlockedMedals[medal] = true;
		showMedalToast(m);
	}

	public function submitHighscore(scoreboardID: Int, totalScore: Int) {
		#if js
		newgrounds.submitHighscore(scoreboardID, totalScore);
		#end
	}

	function showMedalToast(m: Data.Medals) {
		var t = new MedalPopup(m, container);
	}

	public static function get_instance() {
		if (_instance == null) {
			_instance = new Newgrounds();
		}

		return _instance;
	}
}