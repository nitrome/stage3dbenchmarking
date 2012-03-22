package com.nitrome.gfx {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.filters.DisplacementMapFilter;
	import flash.filters.DisplacementMapFilterMode;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * Filter manager for flags wobbling in the wind
	 *
	 * @author Aaron Steed, nitrome.com
	 */
	public class FlagWaver {
		
		private var target:DisplayObject;
		private var filter:DisplacementMapFilter;
		private var mapFrames:Vector.<BitmapData>;
		
		private var frame:int;
		
		public function FlagWaver(target:DisplayObject, frequency:int, speed:int, amplitude:Number) {
			this.target = target;
			mapFrames = new Vector.<BitmapData>();
			
			var bounds:Rectangle = target.getBounds(target);
			var mapBitmapData:BitmapData = new BitmapData(Math.ceil(bounds.width), Math.ceil(bounds.height), true, 0xFF808000);
			
			var step:Number = mapBitmapData.width / frequency;
			var rStep:Number = (Math.PI * 2) / step;
			var rOffsetStep:Number = (Math.PI * 2) / mapBitmapData.width;
			var freqDilationStep:Number = 1.0 / mapBitmapData.width;
			
			var x:Number, r:Number, col:uint, displacement:int;
			
			// frames
			for(var t:int = mapBitmapData.width; t > 0; t -= speed){
				// number of waves
				for(var f:int = 0; f < frequency; f++){
					// displacement map colouring (reduced at left of flag by freqDilationStep to keep still at the flag pole)
					for(x = step * f, r = rOffsetStep * t; x < step * (f + 1); x++, r += rStep){
						displacement = 128 + Math.sin(r) * 128 * freqDilationStep * x;
						col = 0xFF800000 + (displacement << 8);
						mapBitmapData.fillRect(new Rectangle(x, 0, 1, mapBitmapData.height), col);
					}
				}
				mapFrames.push(mapBitmapData.clone());
				mapBitmapData.fillRect(mapBitmapData.rect, 0x00000000);
			}
			
			filter = new DisplacementMapFilter(null, new Point(), 0, BitmapDataChannel.GREEN, 0, amplitude, DisplacementMapFilterMode.CLAMP);
			update();
		}
		
		/* Advance the filter animation */
		public function update():void{
			filter.mapBitmap = mapFrames[frame];
			target.filters = [filter];
			frame++;
			if(frame >= mapFrames.length) frame = 0;
		}
		
	}

}