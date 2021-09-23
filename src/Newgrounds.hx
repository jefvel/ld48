import entities.MedalPopup;
import elke.Game;
import h2d.Object;
#if js
import io.newgrounds.NG;
import io.newgrounds.objects.Medal;
#end

class Newgrounds {
	public static var instance(get, null) : Newgrounds;

	public var isLocal = false;

	static final DEFAULT_SESSION_ID = "default-session";
	static final ENCRYPTION_KEY = "CWqDisAEYYSzTBep/1ZdDg==";

	static var _instance: Newgrounds;
	var container: Object;
	function new() {
		init();
		this.container = Game.instance.s2d;
	}

	var failedLogin = false;

	function init() {
		#if js
		NG.createAndCheckSession("51922:damEMud8", DEFAULT_SESSION_ID, (e) -> {
			failedLogin = true;
		});

		NG.core.initEncryption(ENCRYPTION_KEY);

		refreshNGMedals();

		#else
		isLocal = true;
		#end
	}

	function checkSession() {
		#if js
		if (!NG.core.loggedIn) {
			NG.core.requestLogin(() -> {
				trace("Logged in");
			},
			() -> {
				trace("Pending login");
			},
			(e) -> {
				trace("Could not login");
				trace(e);
			},
			() -> {
				trace("Cancelled login");
			});
		}
		#end
	}

	function refreshNGMedals(?onComplete: Void -> Void) {
		#if js
		NG.core.requestMedals(() -> {
			if (onComplete != null) {
				onComplete();
			}
		});
		#end
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
		}

		#if js
		if (NG.core.loggedIn) {
			var ngMedal = NG.core.medals.get(m.NewgroundsID);
			if (ngMedal == null) {
				refreshNGMedals(() -> {
					var ngMedal = NG.core.medals.get(m.NewgroundsID);
					if (ngMedal != null) {
						if (unlockNgMedal(ngMedal)) {
							if (showMedalPopup) {
								showMedalToast(m);
							}
						}
					}
				});
			} else {
				if (unlockNgMedal(ngMedal)) {
					if (showMedalPopup) {
						showMedalToast(m);
					}
				}
			}
		}
		#else
		if (showMedalPopup) {
			showMedalToast(m);
		}
		#end

		unlockedMedals[medal] = true;
	}

	public function submitHighscore(scoreboardID: Int, totalScore: Int) {
		#if js
		if (NG.core.loggedIn) {
			NG.core.calls.scoreBoard.postScore(scoreboardID, totalScore);
		}
		#end
	}

	function showMedalToast(m: Data.Medals) {
		var t = new MedalPopup(m, container);
	}

	#if js
	function unlockNgMedal(m:Medal) {
		if (m.unlocked) {
			return false;
		}

		#if debug
		m.sendDebugUnlock();
		#else
		m.sendUnlock();
		#end

		return true;
	}
	#end

	public static function get_instance() {
		if (_instance == null) {
			_instance = new Newgrounds();
		}

		return _instance;
	}
}