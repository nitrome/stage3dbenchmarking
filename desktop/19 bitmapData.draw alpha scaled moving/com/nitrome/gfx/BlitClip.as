package com.nitrome.gfx {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Shader;
	import flash.display.ShaderJob;
	import flash.filters.BitmapFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	* Provides a less cpu intensive version of a MovieClip
	* Ideal for particles, but not for complex animated characters or large animations
	* Expands on BlitSprite by hosting an array of bitmapdatas as frames
	*
	* @author Aaron Steed, nitrome.com
	*/
	public class BlitClip extends BlitSprite{
		
		public var frames:Array/*BitmapData*/;
		
		public function BlitClip(gfx:MovieClip = null, colorTransform:ColorTransform = null, compressFrames:Boolean = true){
			frames = [];
			if(gfx){
				super(gfx, colorTransform);
				frames[0] = bitmapData;
				matrix.tx = -bounds.left;
				matrix.ty = -bounds.top;
				for (var i:int = 2; i < gfx.totalFrames + 1; i++){
					gfx.gotoAndStop(i);
					frames[i - 1] = new BitmapData(width, height, true, 0x00000000);
					frames[i - 1].draw(gfx, matrix, colorTransform);
				}
				totalFrames = gfx.totalFrames;
				if(compressFrames) compress();
			}
		}
		
		/* Returns a a copy of this object, must be cast into a BlitClip */
		override public function clone():BlitRect {
			var blit:BlitClip = new BlitClip();
			blit.bitmapData = bitmapData.clone();
			blit.totalFrames = totalFrames;
			blit.frames.push(blit.bitmapData);
			for(var i:int = 1; i < totalFrames; i++){
				blit.frames.push(frames[i].clone());
			}
			blit.x = x;
			blit.y = y;
			blit.dx = dx;
			blit.dy = dy;
			blit.width = width;
			blit.height = height;
			blit.rect = new Rectangle(0, 0, width, height);
			blit.col = col;
			return blit;
		}
		/* A simple way of combining BlitClips */
		public function addBlitClip(blit:BlitClip):void{
			p.x = blit.dx;
			p.y = blit.dy;
			for(var i:int = 0; i < blit.totalFrames; i++){
				frames[i].copyPixels(blit.frames[i], blit.frames[i].rect, p, null, null, true);
			}
		}
		/* Rotates all frames CW
		override public function rotateCW():void{
			if(width != height) return;
			var shader:Shader = new Shader(new BlitSprite.RotateCWShader());
			for(var i:int = 0; i < totalFrames; i++){
				shader.data.src.input = frames[i];
				shader.data.width.value = [width];
				var job:ShaderJob;
				job = new ShaderJob(shader, frames[i], width, height);
				job.start(true);
			}
		}*/
		
		/* Create an animation consisting of a static fading image */
		public static function fadeClip(gfx:DisplayObject, colorTransform:ColorTransform = null, steps:int = 10):BlitClip{
			
			var clip:BlitClip = new BlitClip();
			bounds = gfx.getBounds(gfx);
			clip.bitmapData = clip.frames[0] = new BitmapData(Math.ceil(bounds.width), Math.ceil(bounds.height), true, 0x00000000);
			matrix.tx = -bounds.left;
			matrix.ty = -bounds.top;
			clip.bitmapData.draw(gfx, matrix, colorTransform);
			clip.dx = bounds.left;
			clip.dy = bounds.top;
			clip.width = Math.ceil(bounds.width);
			clip.height = Math.ceil(bounds.height);
			clip.totalFrames = steps;
			clip.rect = new Rectangle(0, 0, clip.width, clip.height);
			
			var alphaStep:Number = 1.0 / steps;
			var fadeTransform:ColorTransform = new ColorTransform();
			var bitmapData:BitmapData;
			for(var i:int = 1; i < steps; i++){
				bitmapData = clip.bitmapData.clone();
				fadeTransform.alphaMultiplier -= alphaStep;
				bitmapData.colorTransform(bitmapData.rect, fadeTransform);
				clip.frames[i] = bitmapData;
			}
			
			return clip;
		}
		
		/* Create a BlitClip from a sprite sheet */
		public static function clipFromSheet(sheet:BitmapData, dx:int, dy:int, frameHeight:int, frameWidth:int):BlitClip{
			var x:int;
			var clip:BlitClip = new BlitClip();
			clip.totalFrames = 0;
			clip.width = frameWidth;
			clip.height = frameHeight;
			var rect:Rectangle = new Rectangle(0, 0, frameHeight, frameWidth);
			var point:Point = new Point();
			for(x = 0; x < sheet.width; x += frameWidth, clip.totalFrames++){
				rect.x = x;
				clip.frames[clip.totalFrames] = new BitmapData(frameWidth, frameHeight, true, 0x00000000);
				clip.frames[clip.totalFrames].copyPixels(sheet, rect, point, null, null, true);
			}
			rect.x = 0;
			clip.rect = rect;
			clip.dx = dx;
			clip.dy = dy;
			return clip;
		}
		
		/* Paints the bitmapData to the destination */
		override public function render(destination:BitmapData, frame:int = 0, alphaBitmapData:BitmapData = null, alphaPoint:Point = null, mask:Rectangle = null):void{
			p.x = x + dx;
			p.y = y + dy;
			destination.copyPixels(frames[frame], mask || rect, p, alphaBitmapData, alphaPoint, true);
		}
		/* Paints a channel from the bitmapData to the destination */
		override public function renderChannel(destination:BitmapData, sourceChannel:uint, destChannel:uint, frame:int = 0, mask:Rectangle = null):void{
			p.x = x + dx;
			p.y = y + dy;
			destination.copyChannel(frames[frame], mask || rect, p, sourceChannel, destChannel);
		}
		/* Paints the bitmapData to the destination using the merge method */
		override public function renderMerge(destination:BitmapData, redMultiplier:uint, greenMultiplier:uint, blueMultiplier:uint, alphaMultiplier:uint, frame:int = 0, mask:Rectangle = null):void{
			p.x = x + dx;
			p.y = y + dy;
			destination.merge(frames[frame], mask || rect, p, redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier);
		}
		/* Given a plane of multiple bitmaps that have been tiled together, calculate which bitmap(s) this
		 * should appear on and render to as many as required to compensate for tiling
		 *
		 * Assumes that bitmaps is a 2d array of tiled bitmapdatas
		 */
		override public function multiRender(bitmaps:Array, scale:int = 2880, frame:int = 0):void {
			super.multiRender(bitmaps, scale, frame);
		}
		/* Does a comparison on all frames so that multiple identical frames can be reduced to one reference */
		public function compress():void{
			if(frames.length < 2) return;
			var i:int, j:int;
			for(i = 0; i < frames.length; i++){
				for(j = i + 1; j < frames.length; j++){
					if(frames[i].compare(frames[j]) == 0) frames[i] = frames[j];
				}
			}
		}
		/* Applies a filter to a range of frames */
		override public function applyFilter(filter:BitmapFilter, start:int = 0, finish:int = int.MAX_VALUE):void {
			p = new Point();
			if(finish > totalFrames) finish = totalFrames - 1;
			for(var i:int = start; i <= finish; i++){
				frames[i].applyFilter(frames[i], frames[i].rect, p, filter);
			}
		}
		
	}
	
}