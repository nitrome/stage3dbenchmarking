package com.nitrome.gfx {
	import com.nitrome.engine.Building;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Shader;
	import flash.display.ShaderJob;
	import flash.geom.ColorTransform;
	
	/**
	 * A special BlitClip that behaves as if it can rotate
	 *
	 * (what it actually does is cache rotated versions of all the frames and switches between them)
	 *
	 * @author Aaron Steed, nitrome.com
	 */
	public class BlitClipRotater extends BlitClip{
		
		public var rotation:int;
		
		public var frameRotations:Array/*Array*/;
		
		// rotation frames
		public static const UP:int = 0;
		public static const RIGHT:int = 1;
		public static const DOWN:int = 2;
		public static const LEFT:int = 3;
		
		public function BlitClipRotater(gfx:MovieClip = null, colorTransform:ColorTransform = null){
			super(gfx, colorTransform);
			frameRotations = [];
			frameRotations[0] = frames;
			
			// copy and rotate the frames
			var i:int, j:int;
			var shader:Shader = new Shader(new BlitSprite.RotateCWShader());
			var temp:Shader = new Shader(new Building.MirrorShader());
			for(i = 1; i < 4; i++){
				frameRotations[i] = [];
				for(j = 0; j < totalFrames; j++){
					frameRotations[i][j] = frameRotations[i - 1][j].clone();
					shader.data.src.input = frameRotations[i][j];
					shader.data.width.value = [width];
					var job:ShaderJob;
					job = new ShaderJob(shader, frameRotations[i][j], width, height);
					job.start(true);
				}
			}
		}
		
		public function setRotation(r:int):void{
			rotation = r;
			frames = frameRotations[r];
		}
		
	}

}