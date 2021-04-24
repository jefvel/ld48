package entities;

import h2d.RenderContext;
import gamestates.PlayState;
import elke.graphics.Sprite;
import elke.entity.Entity2D;

class Hook extends Entity2D {
	var sprite:Sprite;

	var sinking = false;

	var boostTime = 0.0;

	var vx = 0.0;
	var vy = 0.0;

	var sinkSpeed = 2.0;
	var boostMultiplier = 7.0;
	var state:PlayState;
	var moveSpeed = 0.1;

    var maxAx = 0.5;

	var px = 0.0;
	var py = 0.0;

	public function new(state:PlayState, ?p) {
		super(p);
		this.state = state;

		sprite = hxd.Res.img.hook_tilesheet.toSprite2D(this);
		sprite.originX = 8;
        sprite.originY = 1;
		sprite.animation.stop();
		sprite.animation.currentFrame = 0;
	}

	public function start() {
		sinking = true;
		px = x;
        py = y;
	}

    override function sync(ctx:RenderContext) {
        super.sync(ctx);

		state.rope.toX = x;
		state.rope.toY = y;
    }

    var ax = 0.0;
    var ay = 0.0;
    var t = 0.0;
	override function update(dt:Float) {
		super.update(dt);

        t += dt;

		if (!sinking) {
            sprite.rotation = Math.sin(t * 1.6) * 0.4;
			return;
		} 

		if (state.leftPressed) {
			ax -= moveSpeed;
		}
		if (state.rightPressed) {
			ax += moveSpeed;
		}

		if (state.upPressed) {
			ay -= moveSpeed;
		}
		if (state.downPressed) {
			ay += moveSpeed;
		}

        ax *= 0.9;
        ay *= 0.9;

        ax = Math.min(Math.max(ax, -maxAx), maxAx);
        ay = Math.min(Math.max(ay, -maxAx), maxAx);

		vx += ax;
		vy += ay;

		vx *= 0.9;
		vy *= 0.9;

		px += vx;
		py += vy;

        py += Math.min(0, (state.reelLength - state.currentDepth) - py) * 0.08;

		y = state.currentDepth + py;
		x = px;

        px = Math.max(10, px);
        px = Math.min(Const.SEA_WIDTH - 10, px);

        py = Math.max(-Const.SCREEN_HEIGHT * 0.5, py);
        py = Math.min(Const.SCREEN_HEIGHT * 0.5, py);

        sprite.rotation = 0.6 * ax;
	}
}
