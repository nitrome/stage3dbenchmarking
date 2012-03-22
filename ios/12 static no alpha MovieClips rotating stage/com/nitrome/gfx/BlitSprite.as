package com.nitrome.gfx {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Shader;
	import flash.display.ShaderJob;
	import flash.display.Sprite;
	import flash.filters.BitmapFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	* Provides a less cpu intensive version of a Sprite
	* Ideal for particles, but not for complex animated characters or large animations
	* Also operates as a super class to BlitClip
	*
	* @author Aaron Steed, nitrome.com
	*/
	public class BlitSprite extends BlitRect{
		
		public var bitmapData:BitmapData;
		
		// temp vars
		public static var mp:Point = new Point();
		public static var bounds:Rectangle;
		public static var matrix:Matrix = new Matrix();
		
		//public static var RotateCWShader:Class = Data.RotateCWShader;
		
		public function BlitSprite(gfx:DisplayObject = null, colorTransform:ColorTransform = null){
			if(gfx){
				bounds = gfx.getBounds(gfx);
				bitmapData = new BitmapData(Math.ceil(bounds.width), Math.ceil(bounds.height), true, 0x00000000);
				matrix.tx = -bounds.left;
				matrix.ty = -bounds.top;
				bitmapData.draw(gfx, matrix, colorTransform);
				super(bounds.left, bounds.top, Math.ceil(bounds.width), Math.ceil(bounds.height));
			}
		}
		/* Returns a a copy of this object, must be cast into a BlitSprite */
		override public function clone():BlitRect{
			var blit:BlitSprite = new BlitSprite();
			blit.bitmapData = bitmapData.clone();
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
		/* A simple way of combining BlitSprites */
		public function add(blit:BlitSprite):void{
			p.x = blit.dx;
			p.y = blit.dy;
			bitmapData.copyPixels(blit.bitmapData, blit.rect, p, null, null, true);
		}
		/* resizes the data */
		public function resize(dx:int, dy:int, width:int, height:int):void{
			var tempData:BitmapData = new BitmapData(width, height, true, 0x00000000);
			p.x = dx;
			p.y = dy;
			this.width = width;
			this.height = height;
			rect.width = width;
			rect.height = height;
			tempData.copyPixels(bitmapData, bitmapData.rect, p, null, null, true);
			bitmapData = tempData;
		}
		/* Rotates the bitmap CW
		public function rotateCW():void{
			if(width != height) return;
			var shader:Shader = new Shader(new RotateCWShader());
			shader.data.src.input = bitmapData;
			shader.data.width.value = [width];
			var job:ShaderJob;
			job = new ShaderJob(shader, bitmapData, width, height);
			job.start(true);
		}*/
		/* Draws over the current data */
		public function draw(gfx:DisplayObject, colorTransform:ColorTransform = null, blendMode:String = null):void{
			bounds = gfx.getBounds(gfx);
			bitmapData.draw(gfx, new Matrix(1, 0, 0, 1, -bounds.left, -bounds.top), colorTransform, blendMode)
		}
		/* Paints the bitmapData to the destination */
		override public function render(destination:BitmapData, frame:int = 0, alphaBitmapData:BitmapData = null, alphaPoint:Point = null, mask:Rectangle = null):void{
			p.x = x + dx;
			p.y = y + dy;
			destination.copyPixels(bitmapData, mask || rect, p, alphaBitmapData, alphaPoint, true);
		}
		/* Paints a channel from the bitmapData to the destination */
		public function renderChannel(destination:BitmapData, sourceChannel:uint, destChannel:uint, frame:int = 0, mask:Rectangle = null):void{
			p.x = x + dx;
			p.y = y + dy;
			destination.copyChannel(bitmapData, mask || rect, p, sourceChannel, destChannel);
		}
		/* Paints the bitmapData to the destination using the merge method */
		public function renderMerge(destination:BitmapData, redMultiplier:uint, greenMultiplier:uint, blueMultiplier:uint, alphaMultiplier:uint, frame:int = 0, mask:Rectangle = null):void{
			p.x = x + dx;
			p.y = y + dy;
			destination.merge(bitmapData, mask || rect, p, redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier);
		}
		/* Given a plane of multiple bitmaps that have been tiled together, calculate which bitmap(s) this
		 * should appear on and render to as many as required to compensate for tiling
		 *
		 * bitmaps is a 2d Array of tiled bitmapdatas
		 */
		override public function multiRender(bitmaps:Array, scale:int = 2880, frame:int = 0):void{
			var invScale:Number = 1.0 / scale;
			var h:int = bitmaps.length;
			var w:int = bitmaps[0].length;
			// take point position
			p.x = x + dx;
			p.y = y + dy;
			// find bitmap boundaries in tiles
			var leftTileX:int = p.x * invScale;
			var topTileY:int = p.y * invScale;
			var rightTileX:int = (p.x + width) * invScale;
			var bottomTileY:int = (p.y + height) * invScale;
			
			// logically the bitmap will only be painted onto 1, 2 or 4 tiles, we can use conditionals for this
			// to speed things up
			// Of course with the option of scale, this could mean painting to many more bitmaps, and such a
			// task can fuck right off for the time being
			
			// only one tile to paint to
			if(leftTileX == rightTileX && topTileY == bottomTileY){
				if(leftTileX > -1 && leftTileX < w && topTileY > -1 && topTileY < h){
					mp.x = p.x - (scale * leftTileX);
					mp.y = p.y - (scale * topTileY);
					bitmaps[topTileY][leftTileX].bitmapData.copyPixels(bitmapData, rect, mp, null, null, true);
				}
			}
			// two tiles to paint to
			else if(leftTileX == rightTileX && topTileY != bottomTileY){
				if(leftTileX > -1 && leftTileX < w && topTileY > -1 && topTileY < h){
					mp.x = p.x - (scale * leftTileX);
					mp.y = p.y - (scale * topTileY);
					bitmaps[topTileY][leftTileX].bitmapData.copyPixels(bitmapData, rect, mp, null, null, true);
				}
				if(leftTileX > -1 && leftTileX < w && bottomTileY > -1 && bottomTileY < h){
					mp.x = p.x - (scale * leftTileX);
					mp.y = p.y - (scale * bottomTileY);
					bitmaps[bottomTileY][leftTileX].bitmapData.copyPixels(bitmapData, rect, mp, null, null, true);
				}
			} else if(leftTileX != rightTileX && topTileY == bottomTileY){
				if(leftTileX > -1 && leftTileX < w && topTileY > -1 && topTileY < h){
					mp.x = p.x - (scale * leftTileX);
					mp.y = p.y - (scale * topTileY);
					bitmaps[topTileY][leftTileX].bitmapData.copyPixels(bitmapData, rect, mp, null, null, true);
				}
				if(rightTileX > -1 && rightTileX < w && topTileY > -1 && topTileY < h){
					mp.x = p.x - (scale * rightTileX);
					mp.y = p.y - (scale * topTileY);
					bitmaps[topTileY][rightTileX].bitmapData.copyPixels(bitmapData, rect, mp, null, null, true);
				}
			}
			// four tiles to paint to
			else if(leftTileX != rightTileX && topTileY != bottomTileY){
				if(leftTileX > -1 && leftTileX < w && topTileY > -1 && topTileY < h){
					mp.x = p.x - (scale * leftTileX);
					mp.y = p.y - (scale * topTileY);
					bitmaps[topTileY][leftTileX].bitmapData.copyPixels(bitmapData, rect, mp, null, null, true);
				}
				if(rightTileX > -1 && rightTileX < w && topTileY > -1 && topTileY < h){
					mp.x = p.x - (scale * rightTileX);
					mp.y = p.y - (scale * topTileY);
					bitmaps[topTileY][rightTileX].bitmapData.copyPixels(bitmapData, rect, mp, null, null, true);
				}
				if(leftTileX > -1 && leftTileX < w && bottomTileY > -1 && bottomTileY < h){
					mp.x = p.x - (scale * leftTileX);
					mp.y = p.y - (scale * bottomTileY);
					bitmaps[bottomTileY][leftTileX].bitmapData.copyPixels(bitmapData, rect, mp, null, null, true);
				}
				if(rightTileX > -1 && rightTileX < w && bottomTileY > -1 && bottomTileY < h){
					mp.x = p.x - (scale * rightTileX);
					mp.y = p.y - (scale * bottomTileY);
					bitmaps[bottomTileY][rightTileX].bitmapData.copyPixels(bitmapData, rect, mp, null, null, true);
				}
			}
			
		}
		/* Applies a filter to the bitmapdata, the start and finish variables are for the BlitClip class */
		public function applyFilter(filter:BitmapFilter, start:int = 0, finish:int = int.MAX_VALUE):void{
			p = new Point();
			bitmapData.applyFilter(bitmapData, bitmapData.rect, p, filter);
		}
		
	}
	
}