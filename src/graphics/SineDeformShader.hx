package graphics;

class SineDeformShader extends hxsl.Shader {
	static var SRC = {
		@:import h3d.shader.Base2d;
		@param var texture:Sampler2D;
		@param var speed:Float;
		@param var frequency:Float;
		@param var amplitude:Float;
		function fragment() {
            var yy = calculatedUV.y;
			calculatedUV.x += (0.1 + calculatedUV.y) * sin(calculatedUV.y * frequency * 10.0 + time * speed) * amplitude; // wave deform
			calculatedUV.y += sin(calculatedUV.x * frequency * 11.0 + time * speed * 0.3 + 0.4) * amplitude * 0.5; // wave deform
			pixelColor = texture.get(calculatedUV);
            //pixelColor.a = max(pixelColor.r, max(pixelColor.g, max(pixelColor.b, pixelColor.a)));
            pixelColor.a *= 1 - smoothstep(0.3, 0.8, yy);
		}
	}
}
