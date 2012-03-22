package  {
	import com.nitrome.util.FPS;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	
	/**
	 * Rubberbanded benchmark - tries to maintain 30fps
	 * 
	 * result:
		Moving MovieClip Test
		fps: 28
		MovieClips: 4155
		first brake: 4140
		brake: 4165
		release: 3773
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
		
		// temps
		private var mc:MovieClip;
		private var displayObject:DisplayObject;
		private var i:int;
		
		public static const WIDTH:Number = 320;
		public static const HEIGHT:Number = 480;
		public static const FPS_LIMIT:int = 30;
		public static const DEFAULT_SPEED:int = 20;
		
		public static const MCS:Array = [NoAlphaMC1, NoAlphaMC2, NoAlphaMC3, NoAlphaMC4];
		
		public function Game(root:MovieClip) {
			_root = root;
			FPS.start();
			speed = DEFAULT_SPEED;
			status = new TextField();
			status.width = 200;
			status.height = 100;
			status.text = "0 fps";
			status.selectable = true;
			status.backgroundColor = 0xFFFFFF;
			status.background = true;
			_root.addChild(this);
			_root.addChild(status);
			addEventListener(Event.ENTER_FRAME, main);
		}
		
		public function main(e:Event):void{
			
			// if fps is stable at 30
			if(FPS.value >= FPS_LIMIT){
				if(!brake){
					currentRelease = numChildren;
					brake = true;
				}
				for(i = 0; i < speed; i++){
					mc = new MCS[(Math.random() * MCS.length) >> 0];
					mc.x = Math.random() * (WIDTH - mc.width);
					mc.y = Math.random() * (HEIGHT - mc.height);
					addChild(mc);
				}
				
				
			} else if(numChildren){
				if(brake && speed > 1){
					if(firstBrake == 0) firstBrake = numChildren;
					currentBrake = numChildren;
					brake = false;
					speed--;
				}
				removeChildAt(numChildren-1);
			}
			
			// move movieclips manually
			for(i = 0; i < numChildren; i++){
				displayObject = getChildAt(i);
				displayObject.x++;
				if(displayObject.x > WIDTH - displayObject.width) displayObject.x = 0;
			}
			
			status.text = "Moving MovieClip Test\nfps: " + FPS.value + "\nMovieClips: " + numChildren + "\nfirst brake: " + firstBrake + "\nbrake: " + currentBrake + "\nrelease: " + currentRelease;
		}
		
	}

}