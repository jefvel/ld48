package graphics;

import elke.T;
import h2d.filter.AbstractMask;
import h2d.RenderContext;
import h2d.Tile;
import h2d.Bitmap;
import h2d.filter.Mask;
import elke.entity.Entity2D;
import elke.graphics.Transition;


private class MaskShader extends h3d.shader.ScreenShader {

	static var SRC = {

		@param var texture : Sampler2D;
		@param var mask : Sampler2D;
		@param var maskMatA : Vec3;
		@param var maskMatB : Vec3;
		@const var smoothAlpha : Bool;

		function fragment() {
			var color = texture.get(input.uv);
			var uv = vec3(input.uv, 1);
			var k = mask.get( vec2(uv.dot(maskMatA), uv.dot(maskMatB)) );
			var alpha = smoothAlpha ? k.a : float((1.0 - k.a)>0);
			output.color = color * alpha;
		}
	};
}

/**
	Performs an arbitrary shape masking of the filtered Object.

	@see `AbstractMask`
**/
class BoatMask extends AbstractMask {

	var pass : h3d.pass.ScreenFx<MaskShader>;
	/**
		Enables masking Object alpha merging. Otherwise causes unsmoothed masking of non-zero alpha areas.
	**/
	public var smoothAlpha(get, set) : Bool;

	/**
		Create new Mask filter.
		@param mask An `Object` that will be used for masking. See `AbstractMask.mask` for limitations.
		@param maskVisible When enabled, masking `Object` will be visible. Hidden otherwise.
		@param smoothAlpha Enables masking Object alpha merging. Otherwise causes unsmoothed masking of non-zero alpha areas.
	**/
	public function new(mask, maskVisible=false, smoothAlpha=false) {
		super(mask);
		pass = new h3d.pass.ScreenFx(new MaskShader());
		this.maskVisible = maskVisible;
		this.smoothAlpha = smoothAlpha;
	}

	function get_smoothAlpha() return pass.shader.smoothAlpha;
	function set_smoothAlpha(v) return pass.shader.smoothAlpha = v;

	override function draw( ctx : RenderContext, t : h2d.Tile ) {
		var mask = getMaskTexture(ctx, t);
		if( mask == null ) {
			if( this.mask == null ) throw "Mask filter has no mask object";
			return null;
		}

		var out = ctx.textures.allocTileTarget("maskTmp", t);
		ctx.engine.pushTarget(out);
		pass.shader.texture = t.getTexture();
		pass.shader.mask = getMaskTexture(ctx, t);
		pass.shader.maskMatA.set(maskMatrix.a, maskMatrix.c, maskMatrix.x);
		pass.shader.maskMatB.set(maskMatrix.b, maskMatrix.d, maskMatrix.y);
		pass.render();
		ctx.engine.popTarget();
		return h2d.Tile.fromTexture(out);
	}
}


enum TransitionState {
	FadingIn;
	FadingOut;
	Standby;
}

class BoatTransition extends Entity2D {
	var bm : Bitmap;
	var bg : Bitmap;

	public var onFadedIn : Void -> Void;
	public var onComplete : Void -> Void;

	public function new(?onFadedIn, ?onComplete, ?p) {
		super(p);

		bg = new Bitmap(Tile.fromColor(0, 1, 1), this);
		bm = new Bitmap(hxd.Res.img.boat_silhouette.toTile(), this);

		var f = new BoatMask(bm, false, false);
		filter = f;

		this.onFadedIn = onFadedIn;
		this.onComplete = onComplete;
	}

	var _scale = 20.0;
	var maxScale = 15.;

	var state = FadingIn;
	var standbyTime = 0.4;

	var fadeInTime = 0.5;
	var fadeOutTime = 0.5;

	var time = 0.0;

	override function update(dt:Float) {
		super.update(dt);
		if (state == FadingIn) {
			time += dt;

			time = Math.min(time, fadeInTime);

			_scale = maxScale * (T.smootherstep(1.0, 0.0, time / fadeInTime));//(0 - _scale) * 0.05;

			if (time >= fadeInTime) {
				time = 0.0;
				state = Standby;
				if (onFadedIn != null) {
					onFadedIn();
				}
			}
		}

		if (state == Standby) {
			standbyTime -= dt;
			if (standbyTime <= 0) {
				state = FadingOut;
			}
		}

		if (state == FadingOut) {
			time += dt;
			time = Math.min(time, fadeInTime);

			_scale = maxScale * (T.smootherstep(0.0, 1.0, time / fadeOutTime));//(0 - _scale) * 0.05;

			if (time > fadeOutTime) {
				remove();
				if (onComplete != null) {
					onComplete();
				}
			}
		}

		_scale = Math.max(0.001, _scale);
	}

	override function sync(ctx:RenderContext) {
		super.sync(ctx);

		var s = getScene();
		bg.tile.setSize(s.width, s.height);

		bm.setScale(_scale);

		var b = bm.getBounds();
		bm.x = Math.round((s.width - b.width) * 0.5);
		bm.y = Math.round((s.height - b.height) * 0.5);

		if (parent != null) {
			parent.addChild(this);
		}
	}
}