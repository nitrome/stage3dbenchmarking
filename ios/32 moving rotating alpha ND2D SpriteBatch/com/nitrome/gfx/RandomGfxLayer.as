package com.nitrome.gfx {
	import com.nitrome.util.array.randomiseArray;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	/**
	 * A layer in the background that selects random elements to show
	 *
	 * @author Aaron Steed, nitrome.com
	 */
	public class RandomGfxLayer extends MovieClip {
		
		public var canvas:MovieClip;
		public var slices:Vector.<Vector.<MovieClip>>;
		public var bitmap:Bitmap;
		
		public static const WIDTH:Number = Game.WIDTH;
		public static const HEIGHT:Number = Game.HEIGHT;
		public static const SLICE_WIDTH:Number = 500;
		public static const SLICE_HEIGHT:Number = 900;
		public static const INV_SLICE_WIDTH:Number = 1 / SLICE_WIDTH;
		public static const INV_SLICE_HEIGHT:Number = 1 / SLICE_HEIGHT;
		public static const FLOOR_Y:Number = 800;
		public static const PIPE_END_Y:Number = 20;
		public static const SKY_SLICE_FRAME_BEGIN:Number = 8;
		public static const CLOUD_FRAME_BEGIN:Number = 9;
		
		public static var matrix:Matrix = new Matrix();
		
		public function RandomGfxLayer(){
			slices = Vector.<Vector.<MovieClip>>([
				Vector.<MovieClip>([sliceLayer._0, sliceLayer._1, sliceLayer._2]),
				Vector.<MovieClip>([sliceLayer._3, sliceLayer._4, sliceLayer._5])
			]);
			bitmap = new Bitmap(new BitmapData(Game.WIDTH, Game.HEIGHT, true, 0x00000000));
			addChild(bitmap);
		}
		
		public function reset():void{
			canvas = parent as MovieClip;
			x = 0;
			y = FLOOR_Y - height;
			var r:int, c:int;
			for(r = 0; r < slices.length; r++){
				for(c = 0; c < slices[r].length; c++){
					setSlice(slices[r][c]);
				}
			}
			canvas.clouds.x = 0;
			canvas.clouds.y = FLOOR_Y - (SLICE_HEIGHT * (PIPE_END_Y + 5));
			updateBitmap();
		}
		
		/* Choose a graphic for a slice based on the current height */
		private function setSlice(slice:MovieClip):void{
			var mapX:int = (x + slice.x) * INV_SLICE_WIDTH;
			// mapY we want to read from the bottom of the map upwards
			var yPos:Number = -(y + slice.y - (FLOOR_Y - SLICE_HEIGHT));
			var mapY:int = yPos * INV_SLICE_HEIGHT;
			var frame:int;
			if(mapY == 0){
				slice.gotoAndStop(1 + (mapX  % 2));
			} else if(mapY == PIPE_END_Y){
				slice.gotoAndStop(5 + ((Math.random() * 3) >> 0));
			} else if(mapY > PIPE_END_Y){
				frame = SKY_SLICE_FRAME_BEGIN + (mapY - (PIPE_END_Y + 1));
				if(frame > slice.totalFrames) frame = slice.totalFrames;
				slice.gotoAndStop(frame);
			} else {
				slice.gotoAndStop(3 + ((Math.random() * 2) >> 0));
			}
		}
		
		/* Effects the scrolling */
		public function update():void{
			while(x + width < -canvas.x + Game.WIDTH){
				x += SLICE_WIDTH;
				// pass frames back
				slices[0][0].gotoAndStop(slices[0][1].currentFrame);
				slices[0][1].gotoAndStop(slices[0][2].currentFrame);
				setSlice(slices[0][2]);
				slices[1][0].gotoAndStop(slices[1][1].currentFrame);
				slices[1][1].gotoAndStop(slices[1][2].currentFrame);
				setSlice(slices[1][2]);
				// clouds
				canvas.clouds.x = x;
			}
			while(y + height < -canvas.y + Game.HEIGHT){
				y += SLICE_HEIGHT;
				// pass frames back
				slices[0][0].gotoAndStop(slices[1][0].currentFrame);
				slices[0][1].gotoAndStop(slices[1][1].currentFrame);
				slices[0][2].gotoAndStop(slices[1][2].currentFrame);
				setSlice(slices[1][0]);
				setSlice(slices[1][1]);
				setSlice(slices[1][2]);
			}
			while(x > -canvas.x){
				x -= SLICE_WIDTH;
				// pass frames forward
				slices[0][2].gotoAndStop(slices[0][1].currentFrame);
				slices[0][1].gotoAndStop(slices[0][0].currentFrame);
				setSlice(slices[0][0]);
				slices[1][2].gotoAndStop(slices[1][1].currentFrame);
				slices[1][1].gotoAndStop(slices[1][0].currentFrame);
				setSlice(slices[1][0]);
				// clouds
				canvas.clouds.x = x;
			}
			while(y > -canvas.y){
				y -= SLICE_HEIGHT;
				// pass frames forward
				slices[1][0].gotoAndStop(slices[0][0].currentFrame);
				slices[1][1].gotoAndStop(slices[0][1].currentFrame);
				slices[1][2].gotoAndStop(slices[0][2].currentFrame);
				setSlice(slices[0][0]);
				setSlice(slices[0][1]);
				setSlice(slices[0][2]);
			}
			
			updateBitmap();
		}
		
		/* Rendering is passed to a bitmap to reduce vsynch tearing */
		private function updateBitmap():void{
			bitmap.x = -parent.x - x;
			bitmap.y = -parent.y - y;
			matrix.tx = -bitmap.x;
			matrix.ty = -bitmap.y;
			bitmap.bitmapData.fillRect(bitmap.bitmapData.rect, 0x00000000);
			sliceLayer.visible = true;
			bitmap.bitmapData.draw(sliceLayer, matrix);
			sliceLayer.visible = false;
		}
		
	}

}