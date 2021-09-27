import hxd.Key;
import hxd.impl.UInt16;

class Const {
    // Pixel scaling for the 2d scene
	public static inline final PIXEL_SIZE = 2;

    // Pixels per unit, in 3d space
    public static inline final PIXEL_SIZE_WORLD = 32;
    public static inline final PPU = 1.0 / PIXEL_SIZE_WORLD;
    public static inline final MAX_MUSEUM_GOLD = 1500;

	public static inline final TICK_RATE = 60;
    public static inline final SEA_WIDTH = 400;
    public static inline final SCREEN_HEIGHT = 310;
    public static inline final SCREEN_WIDTH = 1280 >> 1;

    public static inline final UNITS_PER_METER = 8;

	static var keys = [Key.SPACE, Key.A, Key.S, Key.D, Key.W, Key.UP, Key.DOWN, Key.LEFT, Key.RIGHT, Key.E];
    public static function isAnyKeyDown() {
		for (k in keys) {
			if (Key.isDown(k)) {
                return true;
			}
		}

        return false;
    }
}