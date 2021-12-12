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
	var moveSpeed = 1.;

    var maxAx = 0.8;

	var px = 0.0;
	var py = 0.0;

    public var centerX = 3.;
    public var centerY = 10.;

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
        vy = -Math.random() * 3 - 15;
        vx = 5 + 8 * (Math.random() - 0.5);
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
            var nx = state.fisher.x + state.fisher.rodX;
            var ny = state.fisher.y + state.fisher.rodY;
            var dx = nx - x;
            var dy = ny - y;

            x += (dx) * 0.8;
            y += (dy) * 0.8;

            if (dx * dx + dy * dy < 3 * 3) {
                var goalRot = Math.sin(t * 1.6) * 0.4;
                sprite.rotation += (goalRot - sprite.rotation) * 0.1;
            } else {
                sprite.rotation = Math.atan2(dy, dx) + Math.PI * 0.5;
            }

			return;
		} 

        if (!inWater) {
            if (y > 0) {
                Game.instance.sound.playWobble(hxd.Res.sound.splash);
                var s = new Splash(x, y, state.world);
                inWater = true;
            }
        } else {
            if (y < 0) {
                inWater = false;
            }
        }

        if (state.currentPhase == Sinking) {
            if (y > 0) {
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
            } else {
                ay = 0.7;
            }

            ax *= 0.4;
            ay *= 0.4;

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

            if (y > 0) {
                sprite.rotation = 0.6 * ax;
            } else {
                sprite.rotation = Math.atan2(vy, vx) - Math.PI * 0.5;
            }
        }

        if (state.currentPhase == ReelingIn) {
            var dx = state.fisher.x + state.fisher.rodX - x;
            var dy = state.fisher.y + state.fisher.rodY - y;
            x += dx * 0.1;
            y += dy * 0.1;

            sprite.rotation *= 0.7;
            for (f in state.caughtFish) {
                var dx = x + centerX - f.x;
                var dy = y + centerY - f.y;

                if (Math.abs(dx) > 0.423 || Math.abs(dy) > 0.423) {
				    f.rot = Math.atan2(dy, dx);
                    f.rotation = f.rot;
                }

                f.x = x + centerX;
                f.y = y + centerY;
            }
        }

        if (state.currentPhase == Catching) {
            var dx = state.fisher.x + state.fisher.rodX - x;
            var dy = state.fisher.y + state.fisher.rodY - y;
            x += dx;
            y += dy;
        }
	}
}
