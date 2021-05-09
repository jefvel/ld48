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
            calculatedUV *= size / textureSize;

            var wrapped = calculatedUV / textureSize;
            var cellSize = vec2(128);
            var sizePerPx = cellSize / (textureSize);
            sizePerPx *= 2;
            //sizePerPx *= size / textureSize;
            //sizePerPx *= cellSize;
            //sizePerPx.x *= size.x / size.y;

            var cellRatio = vec2(mod(calculatedUV, sizePerPx) / sizePerPx);

            var px = calculatedUV / sizePerPx;

            var cpos = texture.get(calculatedUV / cellSize * 2).xy;
            var t_i = floor(px.xy / sizePerPx);
            var t_f = fract(px.xy / sizePerPx);

            //var cellUV = 

            //calculatedUV /= 20;
            //calculatedUV.y /= size.x / textureSize.x * 2;
            //calculatedUV.y += sin(calculatedUV.y * frequency * 10.0 + time * speed) * amplitude; // wave deform
            pixelColor = vec4(1);

            //pixelColor.rg *= cellRatio;

            var diff = cpos - t_f;
            var minDist = 999.9;

            var len = length(diff);

            for (y in -1...2) {
                for (x in -1...2) {
                    var neighbor = vec2(float(x), float(y)) * sizePerPx;
                    var cpos = texture.get((calculatedUV + neighbor) / cellSize * 2).xy;
                    var diff = cpos - (t_f + neighbor);
                    minDist = min(minDist, length(diff));
                }
            }

            pixelColor.rgb = vec3(minDist * 2.5);
            if (minDist < sizePerPx.x / 5.0) {
                pixelColor.rgb = vec3(1, 0 ,0 );
            }

            //pixelColor.rg = cellRatio;
            //pixelColor.r = calculatedUV.x;
            // pixelColor *= mod(calculatedUV.x / wrapped.x, 1.0);
        }
    }
}