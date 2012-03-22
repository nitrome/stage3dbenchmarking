﻿package com.nitrome.gfx {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	* Provides a less cpu intensive version of a Sprite
	* Ideal for particles, but not for complex animated characters or large animations
	* Also operates as a super class to BlitSprite
	*
	* @author Aaron Steed, nitrome.com
	*/
	public class BlitRect {
		
		public var x:int, y:int, width:int, height:int;
		public var dx:int, dy:int;
		public var rect:Rectangle;
		public var col:uint;
		public var totalFrames:int;
		
		public static var p:Point = new Point();
		
		public function BlitRect(dx:int = 0, dy:int = 0, width:int = 1, height:int = 1, col:uint = 0xFF000000){
			x = y = 0;
			this.dx = dx;
			this.dy = dy;
			this.width = width;
			this.height = height;
			this.col = col;
			totalFrames = 1;
			rect = new Rectangle(x, y, width, height);
		}
		/* Returns a a copy of this object */
		public function clone():BlitRect{
			var blit:BlitRect = new BlitRect();
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
		public function render(destination:BitmapData, frame:int = 0, alphaBitmapData:BitmapData = null, alphaPoint:Point = null, mask:Rectangle = null):void{
			rect.x = x + dx;
			rect.y = y + dy;
			destination.fillRect(rect, col);
		}
		/* Given a plane of multiple bitmaps that have been tiled together, calculate which bitmap(s) this
		 * should appear on and render to as many as required to compensate for tiling
		 *
		 * bitmaps is a 2d Array of tiled bitmapdatas
		 */
		public function multiRender(bitmaps:Array, scale:int = 2880, frame:int = 0):void{
			var inv_scale:Number = 1.0 / scale;
			var h:int = bitmaps.length;
			var w:int = bitmaps[0].length;
			// take point position
			p.x = x + dx;
			p.y = y + dy;
			// find bitmap boundaries in tiles
			var leftTileX:int = p.x * inv_scale;
			var topTileY:int = p.y * inv_scale;
			var rightTileX:int = (p.x + width) * inv_scale;
			var bottomTileY:int = (p.y + height) * inv_scale;
			
			// logically the bitmap will only be painted onto 1, 2 or 4 tiles, we can use conditionals for this
			// to speed things up
			// Of course with the option of scale, this could mean painting to many more bitmaps, and such a
			// task can fuck right off for the time being
			
			// only one tile to paint to
			if(leftTileX == rightTileX && topTileY == bottomTileY){
				if(leftTileX > -1 && leftTileX < w && topTileY > -1 && topTileY < h){
					rect.x = p.x - (scale * leftTileX);
					rect.y = p.y - (scale * topTileY);
					bitmaps[topTileY][leftTileX].bitmapData.fillRect(rect, col);
				}
			}
			// two tiles to paint to
			else if(leftTileX == rightTileX && topTileY != bottomTileY){
				if(leftTileX > -1 && leftTileX < w && topTileY > -1 && topTileY < h){
					rect.x = p.x - (scale * leftTileX);
					rect.y = p.y - (scale * topTileY);
					bitmaps[topTileY][leftTileX].bitmapData.fillRect(rect, col);
				}
				if(leftTileX > -1 && leftTileX < w && bottomTileY > -1 && bottomTileY < h){
					rect.x = p.x - (scale * leftTileX);
					rect.y = p.y - (scale * bottomTileY);
					bitmaps[bottomTileY][leftTileX].bitmapData.fillRect(rect, col);
				}
			} else if(leftTileX != rightTileX && topTileY == bottomTileY){
				if(leftTileX > -1 && leftTileX < w && topTileY > -1 && topTileY < h){
					rect.x = p.x - (scale * leftTileX);
					rect.y = p.y - (scale * topTileY);
					bitmaps[topTileY][leftTileX].bitmapData.fillRect(rect, col);
				}
				if(rightTileX > -1 && rightTileX < w && topTileY > -1 && topTileY < h){
					rect.x = p.x - (scale * rightTileX);
					rect.y = p.y - (scale * topTileY);
					bitmaps[topTileY][rightTileX].bitmapData.fillRect(rect, col);
				}
			}
			// four tiles to paint to
			else if(leftTileX != rightTileX && topTileY != bottomTileY){
				if(leftTileX > -1 && leftTileX < w && topTileY > -1 && topTileY < h){
					rect.x = p.x - (scale * leftTileX);
					rect.y = p.y - (scale * topTileY);
					bitmaps[topTileY][leftTileX].bitmapData.fillRect(rect, col);
				}
				if(rightTileX > -1 && rightTileX < w && topTileY > -1 && topTileY < h){
					rect.x = p.x - (scale * rightTileX);
					rect.y = p.y - (scale * topTileY);
					bitmaps[topTileY][rightTileX].bitmapData.fillRect(rect, col);
				}
				if(leftTileX > -1 && leftTileX < w && bottomTileY > -1 && bottomTileY < h){
					rect.x = p.x - (scale * leftTileX);
					rect.y = p.y - (scale * bottomTileY);
					bitmaps[bottomTileY][leftTileX].bitmapData.fillRect(rect, col);
				}
				if(rightTileX > -1 && rightTileX < w && bottomTileY > -1 && bottomTileY < h){
					rect.x = p.x - (scale * rightTileX);
					rect.y = p.y - (scale * bottomTileY);
					bitmaps[bottomTileY][rightTileX].bitmapData.fillRect(rect, col);
				}
			}
		}
		/* Creates an array of bitmaps to render to stitched together to compensate for the minimum bitmap size
		 *
		 * holder is the Sprite that will stand as parent to all these bitmaps
		 */
		public static function createMultiRenderArray(width:int, height:int, holder:Sprite, scale:int = 2880):Array{
			var w:int = Math.ceil(width / scale);
			var h:int = Math.ceil(height / scale);
			var bitmaps:Array = [];
			var r:int, c:int;
			var bitmapdata:BitmapData, bitmap:Bitmap;
			var bitmapWidth:int;
			var bitmapHeight:int = scale;
			for(r = 0; r < height; r += scale){
				if(r + bitmapHeight > height) bitmapHeight = height - r;
				bitmaps[int(r / scale)] = [];
				bitmapWidth = scale;
				for(c = 0; c < width; c += scale){
					if(c + bitmapWidth > width) bitmapWidth = width - c;
					bitmapdata = new BitmapData(bitmapWidth, bitmapHeight, true, 0x00000000);
					bitmap = new Bitmap(bitmapdata);
					bitmap.x = c;
					bitmap.y = r;
					bitmaps[int(r / scale)][int(c / scale)] = bitmap;
					holder.addChild(bitmap);
				}
			}
			return bitmaps;
		}
		
	}
	
}