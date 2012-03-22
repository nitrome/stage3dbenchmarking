package com.nitrome.gfx {
	import com.nitrome.util.clips.stopClips;
	import com.nitrome.util.SWFLoader;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.filters.DisplacementMapFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * Provides a constantly updated bitmapData rendering of given DisplayObject
	 *
	 * @author Aaron Steed, nitrome.com
	 */
	public class BlitStream{
		
		public var type:int;
		public var displayObject:DisplayObject;
		public var contentWidth:Number;
		public var contentHeight:Number;
		public var bitmapData:BitmapData;
		public var matrix:Matrix;
		public var clearFrames:Boolean;
		public var ready:Boolean;
		public var testCard:Boolean;
		public var errorFilter:DisplacementMapFilter;
		public var errorBitmapData:BitmapData;
		public var errorCount:int;
		public var errorSleepCount:int;
		public var errorColorTransform:ColorTransform;
		
		public static var updateList:Array/*BlitStream*/ = [];
		
		// types
		public static const STILL_IMAGE:int = 0;
		public static const ANIMATION:int = 1;
		public static const SWF:int = 2;
		
		public static const ERROR_DELAY:int = 20;
		public static const ERROR_SLEEP_DELAY:int = 90;
		public static const FLICKER_THRESHOLD:Number = 0.1;
		public static const FLICKER_STEP:Number = 0.05;
		
		public function BlitStream(type:int, displayObject:DisplayObject, bitmapData:BitmapData, matrix:Matrix = null, clearFrames:Boolean = true){
			this.type = type;
			this.displayObject = displayObject;
			this.bitmapData = bitmapData;
			this.matrix = matrix;
			this.clearFrames = clearFrames;
			ready = type == STILL_IMAGE || type == ANIMATION;
			if(type == SWF){
				contentWidth = (displayObject as SWFLoader).swfWidth;
				contentHeight = (displayObject as SWFLoader).swfHeight;
			}
			update();
			updateList.push(this);
		}
		
		/* Reads from the source and caches it in the bitmapData */
		public function update():void{
			if(type == SWF){
				ready = (displayObject as SWFLoader).ready;
				testCard = Boolean((displayObject as SWFLoader).testCard);
			}
			if(testCard){
				if(errorSleepCount){
					errorSleepCount--;
					if(errorSleepCount == 0){
						createError();
					}
				} else if(errorCount){
					errorCount--;
					if(errorBitmapData && Math.random() < 0.9){
						errorBitmapData.fillRect(new Rectangle(0, Math.random() * contentHeight, contentWidth, Math.random() * contentHeight * 0.1), 0xFF000000 + (int(Math.random() * 256) << 16) + (int(Math.random() * 256) << 8));
						errorFilter.mapBitmap = errorBitmapData;
					} else {
						errorBitmapData = null;
					}
					
				} else {
					if(errorFilter) errorFilter = null;
					errorCount = ERROR_DELAY + ERROR_DELAY * Math.random();
					errorSleepCount = ERROR_SLEEP_DELAY + ERROR_SLEEP_DELAY * Math.random();
					if(errorCount < 3){
						errorCount = errorSleepCount;
					}
				}
				if(!errorColorTransform) errorColorTransform = new ColorTransform();
				
				if(Game.game.frameCount % 3 == 0){
					var step:Number = Math.random() < 0.5 ? -FLICKER_STEP : FLICKER_STEP;// Math.random() * FLICKER_STEP * 2;
					errorColorTransform.redMultiplier += step;
					errorColorTransform.greenMultiplier += step;
					errorColorTransform.blueMultiplier += step;
					if(errorColorTransform.redMultiplier > 1 + FLICKER_THRESHOLD) errorColorTransform.redMultiplier = 1 + FLICKER_THRESHOLD;
					if(errorColorTransform.greenMultiplier > 1 + FLICKER_THRESHOLD) errorColorTransform.greenMultiplier = 1 + FLICKER_THRESHOLD;
					if(errorColorTransform.blueMultiplier > 1 + FLICKER_THRESHOLD) errorColorTransform.blueMultiplier = 1 + FLICKER_THRESHOLD;
					if(errorColorTransform.redMultiplier < 1 - FLICKER_THRESHOLD) errorColorTransform.redMultiplier = 1 - FLICKER_THRESHOLD;
					if(errorColorTransform.greenMultiplier < 1 - FLICKER_THRESHOLD) errorColorTransform.greenMultiplier = 1 - FLICKER_THRESHOLD;
					if(errorColorTransform.blueMultiplier < 1 - FLICKER_THRESHOLD) errorColorTransform.blueMultiplier = 1 - FLICKER_THRESHOLD;
				}
			} else if(errorFilter){
				errorFilter = null;
			}
			
			if(clearFrames) bitmapData.fillRect(bitmapData.rect, 0x00000000);
			bitmapData.draw(displayObject, matrix, errorColorTransform);
			if(errorFilter){
				bitmapData.applyFilter(bitmapData, bitmapData.rect, new Point(), errorFilter);
			}
		}
		
		/* Creates a template for a distortion in the output image with a timer */
		private function createError():void{
			errorBitmapData = new BitmapData(contentWidth, contentHeight, false, 0xFF000000 + (128 << 16) + (128 << 8));
			errorFilter = new DisplacementMapFilter(errorBitmapData, null, 1, 2, 40, 40);
		}
		
		/* Update the feed from all of the sources */
		public static function update():void{
			for(var i:int = 0; i < updateList.length; i++){
				if(updateList[i].type != STILL_IMAGE){
					updateList[i].update();
				}
			}
		}
		
		/* Used to pause the youtube sources */
		public static function pause():void{
			for(var i:int = 0; i < updateList.length; i++){
			}
		}
		
		/* Used to unpause the youtube sources */
		public static function unpause():void{
			for(var i:int = 0; i < updateList.length; i++){
			}
		}
		
		/* Runs garbage collection on any Loaders and clears the updateList */
		public static function clear():void{
			for(var i:int = 0; i < updateList.length; i++){
				if(updateList[i].type == SWF){
					(updateList[i].displayObject as SWFLoader).destroy();
				}
			}
			updateList.length = 0;
		}
		
	}

}