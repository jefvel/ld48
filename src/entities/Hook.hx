package entities;

import elke.Game;
import h2d.RenderContext;
import gamestates.PlayState;
import elke.graphics.Sprite;
import elke.entity.Entity2D;

class Hook extends Entity2D {
	public var sprite:Sprite;

	var sinking = false;

	var boostTime = 0.0;

	var vx = 0.0;
	var vy = 0.0;

	var sinkSpeed = 2.0;
	var boostMultiplier = 7.0;
	var state:PlayState;
	var moveSpeed = 0.5;

    var maxAx = 0.8;

	var px = 0.0;
	var py = 0.0;

    public var aura : Sprite;

	public function new(state:PlayState, ?p) {
		super(p);
		this.state = state;

        aura = hxd.Res.img.magnetaura_tilesheet.toSprite2D(this);
        aura.visible = false;
        aura.originX = aura.originY = 32;
        aura.animation.play();
        aura.y = 6;

		sprite = hxd.Res.img.hook_tilesheet.toSprite2D(this);
		sprite.originX = 8;
        sprite.originY = 1;
        sprite.animation.play("idle");
	}

    public function reset() {
        sinking = false;
        ax = ay = vx = vy = 0;
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

    var inWater = false;

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

        if (!inWater) {
            if (y > 0) {
                Game.instance.sound.playWobble(hxd.Res.sound.splash);
                inWater = true;
            }
        } else {
            if (y < 0) {
                inWater = false;
            }
        }

        if (state.currentPhase == Sinking) {
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

        if (state.currentPhase == ReelingIn) {
            var dx = state.fisher.x + state.fisher.rodX - x;
            var dy = state.fisher.y + state.fisher.rodY - y;
            x += dx * 0.1;
            y += dy * 0.1;
        }
	}
}
