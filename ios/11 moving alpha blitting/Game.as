package  {
	import com.nitrome.gfx.BlitSprite;
	import com.nitrome.util.FPS;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	
	/**
	 * Rubberbanded benchmark - tries to maintain 30fps
	 * 
	 * result:
		Moving Alpha Blitting Test
		fps: 30
		copyPixels: 9803
		first brake: 10180
		brake: 9987
		release: 9353
	 * 
	 * @author Aaron Steed, nitrome.com
	 */
	public class Game extends Sprite {
		
		public var _root:MovieClip;
		public var status:TextField;
		public var speed:int;
		public var brake:Boolean;
		
		public var firstBrake:int;
		public var currentBrake:int;
		public var currentRelease:int;
		
		public var bitmapDatas:Vector.<BitmapData>;
		public var points:Vector.<Point>;
		public var canvas:BitmapData;
		public var blitSprites:Vector.<BlitSprite>;
		
		// temps
		private var mc:MovieClip;
		private var displayObject:DisplayObject;
		private var i:int;
		private var length:int;
		private var bitmapData:BitmapData;
		private var point:Point;
		
		public static const WIDTH:Number = 320;
		public static const HEIGHT:Number = 480;
		public static const FPS_LIMIT:int = 30;
		public static const DEFAULT_SPEED:int = 20;
		
		public static const MCS:Array = [AlphaMC1, AlphaMC2, AlphaMC3, AlphaMC4];
		
		public function Game(root:MovieClip) {
			_root = root;
			FPS.start();
			speed = DEFAULT_SPEED;
			points = new Vector.<Point>();
			bitmapDatas = new Vector.<BitmapData>();
			blitSprites = new Vector.<BlitSprite>();
			for(i = 0; i < MCS.length; i++){
				blitSprites[i] = new BlitSprite(new MCS[i]);
			}
			status = new TextField();
			status.width = 200;
			status.height = 100;
			status.text = "0 fps";
			status.selectable = true;
			status.backgroundColor = 0xFFFFFF;
			status.background = true;
			var bitmap:Bitmap = new Bitmap(new BitmapData(WIDTH, HEIGHT, true, 0x00000000));
			canvas = bitmap.bitmapData;
			addChild(bitmap);
			_root.addChild(this);
			_root.addChild(status);
			addEventListener(Event.ENTER_FRAME, main);
		}
		
		public function main(e:Event):void{
			
			// if fps is stable at 30
			if(FPS.value >= FPS_LIMIT){
				if(!brake){
					currentRelease = bitmapDatas.length;
					brake = true;
				}
				length = bitmapDatas.length;
				for(i = 0; i < speed; i++){
					bitmapData = blitSprites[(Math.random() * blitSprites.length) >> 0].bitmapData;
					bitmapDatas.push(bitmapData);
					points.push(new Point(Math.random() * (WIDTH - bitmapData.width), Math.random() * (HEIGHT - bitmapData.height)));
				}
				
			} else if(bitmapDatas.length){
				if(brake && speed > 1){
					if(firstBrake == 0) firstBrake = bitmapDatas.length;
					currentBrake = bitmapDatas.length;
					brake = false;
					speed--;
				}
				bitmapDatas.pop();
				points.pop();
			}
			
			// move movieclips manually
			length = bitmapDatas.length;
			for(i = 0; i < length; i++){
				bitmapData = bitmapDatas[i];
				point = points[i];
				point.x++;
				if(point.x > WIDTH - bitmapData.width) point.x = 0;
				canvas.copyPixels(bitmapData, bitmapData.rect, point, null, null, true);
			}
			
			status.text = "Moving Alpha Blitting Test\nfps: " + FPS.value + "\ncopyPixels: " + length + "\nfirst brake: " + firstBrake + "\nbrake: " + currentBrake + "\nrelease: " + currentRelease;
		}
		
	}

}