package com.nitrome.gfx {
	import com.nitrome.gfx.BlitRect;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * A hacky method for fading squares of colour
	 *
	 * @author Aaron Steed, nitrome.com
	 */
	public class FadingBlitRect extends BlitRect{
		
		public var frames:Array;
		
		public function FadingBlitRect(dx:int = 0, dy:int = 0, width:int = 1, height:int = 1, totalFrames:int = 1, col:uint = 0xFF000000){
			super(dx, dy, width, height, col);
			frames = [];
			this.totalFrames = totalFrames;
			var step:int = 255 / totalFrames;
			for(var i:int = 0; i < totalFrames; i++){
				frames[i] = new BitmapData(width, height, true, col - 0x01000000 * i * step);
			}
		}
		
		override public function render(destination:BitmapData, frame:int = 0, alphaBitmapData:BitmapData = null, alphaPoint:Point = null, mask:Rectangle = null):void {
			p.x = x + dx;
			p.y = y + dy;
			destination.copyPixels(frames[frame], rect, p, alphaBitmapData, alphaPoint, true);
		}
		/* Paints a channel from the bitmapData to the destination */
		public function renderChannel(destination:BitmapData, sourceChannel:uint, destChannel:uint, frame:int = 0):void{
			p.x = x + dx;
			p.y = y + dy;
			destination.copyChannel(frames[frame], rect, p, sourceChannel, destChannel);
		}
		/* Paints the bitmapData to the destination using the merge method */
		public function renderMerge(destination:BitmapData, redMultiplier:uint, greenMultiplier:uint, blueMultiplier:uint, alphaMultiplier:uint, frame:int = 0):void{
			p.x = x + dx;
			p.y = y + dy;
			destination.merge(frames[frame], rect, p, redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier);
		}
		
	}

}