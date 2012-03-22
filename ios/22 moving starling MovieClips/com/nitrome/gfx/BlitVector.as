package com.nitrome.gfx {
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	
	/**
	 * This is a means to render character animations via blitting and allow the render order of the characters to
	 * be a controllable part of the rendering engine
	 *
	 * It's halfway to a nested MovieClip, but without the layering
	 *
	 * A BlitVector adds a second dimension to the "frames" variable of the BlitClip, allowing switching between sets
	 * of frames, yet behaving still like a BlitClip and with the same range of methods
	 *
	 * The constructor of the BlitVector expects a series of nested MovieClips on individual frames
	 * The first frame of the MovieClip - like with the BlitClip, must be large enough to encompass all following animations
	 *
	 * @author Aaron Steed, nitrome.com
	 */
	public class BlitVector extends BlitClip{
		
		public var frameSets:Array/*Array*/
		public var currentframeSet:int;
		public var frameLabels:Object;
		public var currentLabel:String;
		
		public function BlitVector(gfx:MovieClip = null, colorTransform:ColorTransform = null, compressFrames:Boolean = true){
			frameSets = [];
			frameLabels = {};
			currentframeSet = 0;
			
			if(gfx){
				bounds = gfx.getBounds(gfx);
				dx = bounds.left;
				dy = bounds.top;
				width = Math.ceil(bounds.width);
				height = Math.ceil(bounds.height);
				rect = new Rectangle(0, 0, width, height);
				
				var i:int, j:int, k:int;
				var movieClip:MovieClip;
				var innerBounds:Rectangle;
				
				for(i = 1; i < gfx.totalFrames + 1; i++){
					gfx.gotoAndStop(i);
					if(gfx.currentFrameLabel){
						frameLabels[gfx.currentFrameLabel] = i - 1;
					}
					// there may be a shape creating a larger bounds for the frameSets
					// so we have to dig through to get to the other stuff
					for(j = 0; j < gfx.numChildren; j++){
						var item:DisplayObject = gfx.getChildAt(j);
						if(item is MovieClip){
							movieClip = item as MovieClip;
							frames = [];
							innerBounds = movieClip.getBounds(movieClip);
							
							
							// this bit is wrong - it only scans clips with their content aligned with the top-left corner
							
							matrix.tx = -bounds.left - innerBounds.left;
							matrix.ty = -bounds.top - innerBounds.top;
							for(k = 1; k < movieClip.totalFrames + 1; k++){
								movieClip.gotoAndStop(k);
								frames[k - 1] = new BitmapData(width, height, true, 0x00000000);
								frames[k - 1].draw(gfx, matrix, colorTransform);
							}
							frameSets[i - 1] = frames;
							break;
						}
					}
				}
				if(compressFrames) compress();
				setFrameSet(0);
			}
		}
		
		/* Switches the property frames to a new set of frames
		 *
		 * accepts either the index of the frame set or the frame label that was found on the frame whilst creating the frameSet */
		public function setFrameSet(obj:Object):void{
			if(obj is String){
				currentframeSet = frameLabels[obj];
				currentLabel = obj as String;
			} else if(obj is Number){
				currentframeSet = obj as int;
				currentLabel = null;
			}
			frames = frameSets[currentframeSet];
			totalFrames = frames.length;
		}
		
		/* Cycles through all the frame sets and compresses all of them
		 *
		 * This is sub-optimal as it does not compare the contents of frameSets against each other*/
		override public function compress():void {
			for(var i:int = 0; i < frameSets.length; i++){
				frames = frameSets[i];
				super.compress();
			}
			frames = frameSets[currentframeSet];
		}
	}

}