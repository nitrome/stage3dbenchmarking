package  {
	import flash.display.Sprite;
	import flash.display.Stage;
	import starling.core.Starling;
	
	/**
	 * ...
	 * @author Aaron Steed, nitrome.com
	 */
	public class Startup extends Sprite {
		private var starling:Starling;
		
		public function Startup(stage:Stage) {
			starling = new Starling(Game, stage);
			starling.start();
		}
		
	}

}