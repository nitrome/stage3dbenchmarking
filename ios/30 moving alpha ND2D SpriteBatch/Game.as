package  {
	import com.nitrome.util.FPS;
	import de.nulldesign.nd2d.display.Node2D;
	import de.nulldesign.nd2d.display.Scene2D;
	import de.nulldesign.nd2d.display.Sprite2D;
	import de.nulldesign.nd2d.display.Sprite2DBatch;
	import de.nulldesign.nd2d.display.Sprite2DCloud;
	import de.nulldesign.nd2d.display.World2D;
	import de.nulldesign.nd2d.materials.texture.SpriteSheet;
	import de.nulldesign.nd2d.materials.texture.Texture2D;
	import de.nulldesign.nd2d.materials.texture.TextureAtlas;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.display3D.Context3DRenderMode;
	
	/**
	 * Rubberbanded benchmark - tries to maintain 30fps
	 * 
	 * result:
		
		Moving Alpha ND2D SpriteBatch Test
		fps: 23
		Sprites: 2823
		first brake: 2900
		brake: 2848
		release: 2392
		
	 * 
	 * @author Aaron Steed, nitrome.com
	 */
	public class Game extends World2D{
		
		public static var _root:*;
		public var status:TextField;
		public var speed:int;
		public var brake:Boolean;
		
		public var firstBrake:int;
		public var currentBrake:int;
		public var currentRelease:int;
		
		public var spriteBatch:Sprite2DBatch;
		public var spriteSheet:SpriteSheet;
		
		// temps
		private var i:int;
		private var length:int;
		private var sprite:Sprite2D;
		private var node:Node2D;
		
		public static const WIDTH:Number = 320;
		public static const HEIGHT:Number = 480;
		public static const FPS_LIMIT:int = 30;
		public static const DEFAULT_SPEED:int = 20;
		
		public function Game() {
			super(Context3DRenderMode.AUTO, 30);
		}
		
		override protected function addedToStage(event:Event):void {
			super.addedToStage(event);
			
			FPS.start();
			speed = DEFAULT_SPEED;
			
			var bd:BitmapData = new AtlasBD(1, 1);
			var scene:Scene2D = new Scene2D();
			setActiveScene(scene);
			
			
			var texture:Texture2D = Texture2D.textureFromBitmapData(bd);
			spriteSheet = new SpriteSheet(256, 32, 32, 32, 30, true);
			spriteBatch = new Sprite2DBatch(texture);
			spriteBatch.setSpriteSheet(spriteSheet);
			scene.addChild(spriteBatch);
			
			_root.addChild(this);
			
			status = new TextField();
			status.width = 200;
			status.height = 100;
			status.text = "0 fps";
			status.selectable = true;
			status.backgroundColor = 0xFFFFFF;
			status.background = true;
			_root.addChild(status);
			
			_root.addEventListener(Event.ENTER_FRAME, main);
			start();
		}
		
		
		public function main(e:Event):void{
			
			// if fps is stable at 30
			if(FPS.value >= FPS_LIMIT){
				if(!brake){
					currentRelease = spriteBatch.numChildren;
					brake = true;
				}
				for(i = 0; i < speed; i++){
					sprite = new Sprite2D();
					spriteBatch.addChild(sprite);
					sprite.spriteSheet.frame = 4 + Math.random() * 4;
					sprite.x = Math.random() * (WIDTH - 32);
					sprite.y = Math.random() * (HEIGHT - 32);
				}
				
			} else if(spriteBatch.numChildren){
				if(brake && speed > 1){
					if(firstBrake == 0) firstBrake = spriteBatch.numChildren;
					currentBrake = spriteBatch.numChildren;
					brake = false;
					speed--;
				}
				spriteBatch.removeChildAt(spriteBatch.numChildren - 1);
			}
			
			for(i = 0; i < spriteBatch.numChildren; i++){
				node = spriteBatch.children[i];
				node.x++;
				if(node.x > WIDTH - 32) node.x = 0;
			}
			
			status.text = "Moving Alpha ND2D SpriteBatch Test\nfps: " + FPS.value + "\nSprites: " + spriteBatch.numChildren + "\nfirst brake: " + firstBrake + "\nbrake: " + currentBrake + "\nrelease: " + currentRelease;
		}
		
	}

}