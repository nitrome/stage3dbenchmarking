package com.nitrome.gfx {
	import flash.display.BitmapData;
	import flash.geom.Point;
	/**
	 * Traces an outline around a BitmapData and returns the result as a BitmapData with the perimeter illustrated
	 * Or returns a series of points describing the perimiter of a group of pixels
	 *
	 * Caveat: in using a mask to detect pixels, a pixel of value 0x00000000 is invisible to the algorithm
	 * this edge case would require hacking in
	 *
	 * Ported from:
	 * http://devblog.phillipspiess.com/2010/02/23/better-know-an-algorithm-1-marching-squares/
	 *
	 * If you wish to understand the algorithm better or port it, I suggest you look at the original C# code as I've
	 * streamlined a lot of the code to make it run faster in AS3 and removed a lot of the commentary,
	 * although he forgot to include case 0 where the march progresses right and the rule that insists on positions
	 * be inside the image, breaks down when pixels are on the bottom or right of the image
	 *
	 * @author Aaron Steed, nitrome.com
	 */
	public class MarchingSquares {
		
		private static const NONE:int = 0;
		private static const UP:int = 1;
		private static const LEFT:int = 2;
		private static const DOWN:int = 3;
		private static const RIGHT:int = 4;
		
		// utilities
		private var pixels:Vector.<uint>;
		private var bitmapData:BitmapData;
		private var previousStep:int;
		private var nextStep:int;
		private var mask:uint;
		
		public function MarchingSquares() {
			
		}
		
		/* Draws the edges a group of pixels from a given start point. The drawing is inclusive and will describe
		 * the inside edge.
		 *
		 * If no start point is supplied, the march begins from a scan for the start point
		 * Caveat: Marching Squares gets lost if it doesn't start at the top left of a perimeter */
		public function drawPerimeter(bitmapData:BitmapData, mask:uint = 0xFFFFFFFF, resultCol:uint = 0xFFFFFFFF, startPoint:Point = null, output:BitmapData = null):BitmapData{
			
			this.bitmapData = bitmapData;
			this.mask = mask;
			
			if(!output || output.width != bitmapData.width || output.height != bitmapData.height){
				output = new BitmapData(bitmapData.width, bitmapData.height, true, 0x00000000);
			}
			pixels = bitmapData.getVector(bitmapData.rect);
			
			// find the start point
			if(!startPoint) startPoint = findStartPoint(mask);
			if(!startPoint){
				trace("MarchingSquares: no perimeter found for mask " + mask.toString(16));
				return output;
			}
			
			var startX:int = startPoint.x;
			var startY:int = startPoint.y;
			if(startX < 0) startX = 0;
			if(startX > bitmapData.width) startX = bitmapData.width;
			if(startY < 0) startY = 0;
			if(startY > bitmapData.height) startY = bitmapData.height;
			
			var x:int = startX;
			var y:int = startY;
			
			do{
				// evaluate our state, and set up our next direction
				step(x, y);
				
				// because Marching Squares classically tries to contain a pixelated shape, rather
				// than draw the edge, we have to do a fair bit of hacking to force the perimeter
				// drawing onto the actual pixels of the image.
				
				if(nextStep == RIGHT){
					if(previousStep == UP){
						output.setPixel32(x - 1, y, resultCol);
						output.setPixel32(x - 1, y - 1, resultCol);
					}
					output.setPixel32(x, y - 1, resultCol);
				} else if(nextStep == UP){
					if(previousStep != RIGHT) output.setPixel32(x - 1, y, resultCol);
					if(previousStep == LEFT) output.setPixel32(x, y, resultCol);
				} else if(nextStep == LEFT){
					if(previousStep != UP) output.setPixel32(x, y, resultCol);
				} else if(nextStep == DOWN){
					if(previousStep == RIGHT) output.setPixel32(x, y - 1, resultCol);
					output.setPixel32(x, y, resultCol);
				} else {
					output.setPixel32(x, y, resultCol);
				}
				
				if(nextStep == UP) y--;
				else if(nextStep == LEFT) x--;
				else if(nextStep == DOWN) y++;
				else if(nextStep == RIGHT) x++;
				else {
					// something has gone very wrong
					return output;
				}
				
			} while (x != startX || y != startY);
			
			return output;
		}
		
		/* Generates an array of points describing the perimeter of a group of pixels.
		 *
		 * If no start point is supplied, the march begins from a scan for the start point
		 * Caveat: Marching Squares gets lost if it doesn't start at the top left of a perimeter */
		public function walkPerimeter(bitmapData:BitmapData, mask:uint = 0xFFFFFFFF, startPoint:Point = null):Array{
			
			this.bitmapData = bitmapData;
			this.mask = mask;
			
			pixels = bitmapData.getVector(bitmapData.rect);
			
			// find the start point
			if(!startPoint) startPoint = findStartPoint(mask);
			if(!startPoint){
				trace("MarchingSquares: no perimeter found for mask " + mask.toString(16));
				return [];
			}
			
			var startX:int = startPoint.x;
			var startY:int = startPoint.y;
			if(startX < 0) startX = 0;
			if(startX > bitmapData.width) startX = bitmapData.width;
			if(startY < 0) startY = 0;
			if(startY > bitmapData.height) startY = bitmapData.height;
			
			var x:int = startX;
			var y:int = startY;
			
			var points:Array = [];
			
			do{
				// evaluate our state, and set up our next direction
				step(x, y);
				
				points.push(new Point(x, y));
				
				if(nextStep == UP) y--;
				else if(nextStep == LEFT) x--;
				else if(nextStep == DOWN) y++;
				else if(nextStep == RIGHT) x++;
				else {
					// something has gone very wrong
					return points;
				}
				
			} while (x != startX || y != startY);
			
			return points;
		}

		/* Finds the first pixel in the perimeter of the image that is visible to the mask or returns null */
		private function findStartPoint(mask:uint):Point{
			for(var i:int = 0;  i < pixels.length; i++){
				if(pixels[i] & mask){
					return new Point(i % bitmapData.width, int(i / bitmapData.width));
				}
			}
			return null;
		}
		
		/* Determines and sets the state of the 4 pixels that
		 * represent our current state, and sets our current and
		 * previous directions */
		private function step(x:int, y:int):void{
			
			// Store our previous step
			previousStep = nextStep;
			
			// Determine which state we are in
			var state:int = 0;
			
			// up left
			if(y > 0 && x > 0 && (pixels[(x - 1) + (y - 1) * bitmapData.width] & mask)) state |= 1;
			
			// up right
			if(y > 0 && x < bitmapData.width && (pixels[x + (y - 1) * bitmapData.width] & mask)) state |= 2;
			
			// down left
			if(x > 0 && y < bitmapData.height && (pixels[(x - 1) + y * bitmapData.width] & mask)) state |= 4;
			
			// down right
			if(x < bitmapData.width && y < bitmapData.height && pixels[x + y * bitmapData.width] & mask) state |= 8;
			
			// State now contains a number between 0 and 15
			// representing our state.
			// In binary, it looks like 0000-1111 (in binary)
			
			// An example. Let's say the top two pixels are filled,
			// and the bottom two are empty.
			// Stepping through the if statements above with a state
			// of 0b0000 initially produces:
			// Upper Left == true ==>  0001
			// Upper Right == true ==> 0011
			// The others are false, so 0011 is our state
			// (That's 3 in decimal.)

			// Looking at the chart above, we see that state
			// corresponds to a move right, so in our switch statement
			// below, we add a case for 3, and assign Right as the
			// direction of the next step. We repeat this process
			// for all 16 states.
			
			if(state == 0) nextStep = RIGHT;
			else if(state == 1) nextStep = UP;
			else if(state == 2) nextStep = RIGHT;
			else if(state == 3) nextStep = RIGHT;
			else if(state == 4) nextStep = LEFT;
			else if(state == 5) nextStep = UP;
			else if(state == 6){
				if(previousStep == UP){
					nextStep = LEFT;
				} else {
					nextStep = RIGHT;
				}
			}
			else if(state == 7) nextStep = RIGHT;
			else if(state == 8) nextStep = DOWN;
			else if(state == 9){
				if(previousStep == RIGHT){
					nextStep = UP;
				} else {
					nextStep = DOWN;
				}
			}
			else if(state == 10) nextStep = DOWN;
			else if(state == 11) nextStep = DOWN;
			else if(state == 12) nextStep = LEFT;
			else if(state == 13) nextStep = UP;
			else if(state == 14) nextStep = LEFT;
			else nextStep = NONE;
		}
	}
	
}