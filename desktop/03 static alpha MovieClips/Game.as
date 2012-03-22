package  {
	import com.nitrome.util.FPS;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	
	/**
	 * Rubberbanded benchmark - tries to maintain 30fps
	 * 
	 * result:
		Static Alpha MovieClip Test
		fps: 31
		MovieClips: 3257
		first brake: 1700
		brake: 3473
		release: 3389
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
		private var i:int;
		
		public static const WIDTH:Number = 550;
		public static const HEIGHT:Number = 550;
		public static const FPS_LIMIT:int = 30;
		public static const DEFAULT_SPEED:int = 20;
		
		public static const MCS:Array = [AlphaMC1, AlphaMC2, AlphaMC3, AlphaMC4];
		
		public function Game(root:MovieClip) {
			_root = root;
			FPS.start();
			speed = DEFAULT_SPEED;
			status = new TextField();
			status.width = 200;
			status.height = 200;
			status.text = "0 fps";
			status.selectable = true;
			status.filters = [new GlowFilter(0xFFFFFF, 1, 4, 4, 2000)];
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
			
			status.text = "Static Alpha MovieClip Test\nfps: " + FPS.value + "\nMovieClips: " + numChildren + "\nfirst brake: " + firstBrake + "\nbrake: " + currentBrake + "\nrelease: " + currentRelease;
		}
		
	}

}