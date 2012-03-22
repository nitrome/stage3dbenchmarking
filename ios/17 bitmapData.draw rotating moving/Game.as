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
		Moving Rotating bitmapData.draw Test
		fps: 21
		bitmapData.draw: 805
		first brake: 580
		brake: 809
		release: 452
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
		
		public var movieClips:Vector.<MovieClip>;
		public var canvas:BitmapData;
		
		// temps
		private var mc:MovieClip;
		private var displayObject:DisplayObject;
		private var i:int;
		private var length:int;
		
		public static const WIDTH:Number = 320;
		public static const HEIGHT:Number = 480;
		public static const FPS_LIMIT:int = 30;
		public static const DEFAULT_SPEED:int = 20;
		
		public static const MCS:Array = [NoAlphaMC1, NoAlphaMC2, NoAlphaMC3, NoAlphaMC4];
		
		public function Game(root:MovieClip) {
			_root = root;
			FPS.start();
			speed = DEFAULT_SPEED;
			movieClips = new Vector.<MovieClip>();
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
					currentRelease = movieClips.length;
					brake = true;
				}
				for(i = 0; i < speed; i++){
					mc = new MCS[(Math.random() * MCS.length) >> 0];
					mc.x = Math.random() * (WIDTH - mc.width);
					mc.y = Math.random() * (HEIGHT - mc.height);
					movieClips.push(mc);
				}
				
			} else if(movieClips.length){
				if(brake && speed > 1){
					if(firstBrake == 0) firstBrake = movieClips.length;
					currentBrake = movieClips.length;
					brake = false;
					speed--;
				}
				movieClips.pop();
			}
			
			length = movieClips.length;
			for(i = 0; i < length; i++){
				mc = movieClips[i];
				mc.x++;
				mc.rotation++;
				if(mc.x > WIDTH - mc.width) mc.x = 0;
				canvas.draw(mc, mc.transform.matrix);
			}
			
			status.text = "Moving Rotating bitmapData.draw Test\nfps: " + FPS.value + "\nbitmapData.draw: " + length + "\nfirst brake: " + firstBrake + "\nbrake: " + currentBrake + "\nrelease: " + currentRelease;
		}
		
	}

}