package graphics;

class WaterShader extends hxsl.Shader {
    static var SRC = {
        @:import h3d.shader.Base2d;
        
        @param var texture : Sampler2D;
        @param var speed : Float;
        @param var frequency : Float;
        @param var amplitude : Float;

        @param var size : Vec2;
        @param var textureSize: Vec2;
        
        function fragment() {
            var cellSize = vec2(29);

            calculatedUV *= size / textureSize;
            calculatedUV /= cellSize;

            calculatedUV.x += sin(calculatedUV.x * frequency * 10.0 + time * speed) * amplitude; // wave deform
            calculatedUV.y += sin(calculatedUV.y * frequency * 19.0 + time * speed * 0.3 + 0.4) * amplitude; // wave deform
            
            var sizePerPx = cellSize / (textureSize);

            //sizePerPx *= 2;
            //sizePerPx *= size / textureSize;
            //sizePerPx *= cellSize;
            //sizePerPx.x *= size.x / size.y;

            var px = calculatedUV / sizePerPx;
            var cellRatio = vec2(mod(calculatedUV, sizePerPx) / sizePerPx);

            var cpos = texture.get(calculatedUV).xy;

            var st = px.xy / (sizePerPx / (size.x / textureSize.x));
            var t_i = floor(st);
            var t_f = fract(st);

            //var cellUV = 

            //calculatedUV /= 20;
            //calculatedUV.y /= size.x / textureSize.x * 2;
            pixelColor = vec4(0, 0, 0, 1);

            //pixelColor.rg *= cellRatio;

            var diff = cpos - t_f;
            var minDist = 999.9;

            var waterAlpha = 0.0;

            var len = length(diff);
            var closestPoint = vec2(cpos);
            //minDist = len;
            var res = vec2(8, 8);

            for (y in -1...2) {
                for (x in -1...2) {
                    var neighbor = vec2(float(x), float(y));
                    var cpos = texture.get((t_i + neighbor) / (textureSize)).xy;
                    cpos = 0.5 + 0.3*sin(time + (2.0 * 6.2831*cpos + (t_i.y + y) * 0.9));

                    // var diff = (cpos + neighbor) - (t_f);
                    var diff = neighbor - t_f + cpos;
                    var d = dot(diff, diff);

                    /*
                    var len = length(diff);
                    if (len < minDist) {
                        minDist = len;
                        closestPoint = cpos;
                    }
                    */

                    if (d < res.x) {
                        res.y = res.x;
                        res.x = d;
                    }
                    else if (d < res.y) {
                        res.y = d;
                    }
                }
            }

            //res.x = sqrt(res.x);
            //res.y = sqrt(res.y);

            minDist = sqrt(res.x);

            //pixelColor.rg = t_f.xy;

            pixelColor.rgb = vec3(minDist);

            if (minDist < 0.02) {
                pixelColor.r = 1;
            }

            var d = length(cpos - closestPoint);
            var pd = length(t_f - closestPoint);

            //var faf = (1 - abs(d - pd));


            //pixelColor -= step(.7,abs(sin(27.0*minDist)))*.5;

            /*
            if (mod(time, 3.) < 1)
                pixelColor.gb = vec2(cpos.r, cpos.g);
            else if (mod(time, 3) < 2)
                pixelColor.gb = t_f;
            else 
                pixelColor.rgb = vec3(minDist);
            */

            pixelColor.rgb = vec3(1);
            var dis = sqrt(res.y) - sqrt(res.x);
            pixelColor.a = 1.0 - step(0.08, dis);
            var color = vec3(75  / 256., 128 / 256., 202 / 256.);
            pixelColor.rgb = color;
            pixelColor.a = min(0.7, pixelColor.a);
            pixelColor += 0.1 * (1.0 - step(0.004, dis)) * texture.get(t_i / 32.0 + vec2(0.5)).r;
            pixelColor.a *= min(1., 0.7 - ((st.y * cellSize.x * 1.9 + 32 * sin(st.x * 0.6)) / size.y));
            //pixelColor.a = 1 - step(minDist * minDist * minDist * minDist, 0.1);


            //pixelColor.rg = cellRatio;
            //pixelColor.r = calculatedUV.x;
            // pixelColor *= mod(calculatedUV.x / wrapped.x, 1.0);
        }
    }
}