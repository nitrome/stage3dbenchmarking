package  {
	import com.nitrome.util.FPS;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	import starling.display.MovieClip;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	/**
	 * Rubberbanded benchmark - tries to maintain 30fps
	 * 
	 * result:
		DirectX9:
		Moving Rotating Alpha Starling MovieClip Test
		fps: 23
		MovieClips: 1679
		first brake: 1660
		brake: 1682
		release: 1268
		
	 * 
	 * @author Aaron Steed, nitrome.com
	 */
	public class Game extends Sprite {
		
		public static var _root:*;
		public var status:TextField;
		public var speed:int;
		public var brake:Boolean;
		
		public var firstBrake:int;
		public var currentBrake:int;
		public var currentRelease:int;
		
		public var sprites:Vector.<Sprite>;
		public var textures:Vector.<Texture>;
		public var texture:Texture;
		public var atlas:TextureAtlas;
		
		
		// temps
		private var sprite:Sprite;
		private var mc:MovieClip;
		private var displayObject:DisplayObject;
		private var i:int;
		private var length:int;
		
		public static const WIDTH:Number = 320;
		public static const HEIGHT:Number = 480;
		public static const FPS_LIMIT:int = 30;
		public static const DEFAULT_SPEED:int = 20;
		
		public function Game() {
			FPS.start();
			speed = DEFAULT_SPEED;
			sprites = new Vector.<Sprite>();
			
			texture = Texture.fromBitmapData(new AtlasBD(1, 1), false);
			var xml:XML = <TextureAtlas>
				<SubTexture name='_1' x='0'  y='0' width='32' height='32'/>
				<SubTexture name='_2' x='32' y='0' width='32' height='32'/>
				<SubTexture name='_3' x='64' y='0' width='32' height='32'/>
				<SubTexture name='_4' x='96' y='0' width='32' height='32'/>
				<SubTexture name='alpha_1' x='128'  y='0' width='32' height='32'/>
				<SubTexture name='alpha_2' x='160' y='0' width='32' height='32'/>
				<SubTexture name='alpha_3' x='192' y='0' width='32' height='32'/>
				<SubTexture name='alpha_4' x='224' y='0' width='32' height='32'/>
			</TextureAtlas>;
			atlas = new TextureAtlas(texture, xml);
			textures = atlas.getTextures("alpha_");
			
			status = new TextField();
			status.width = 200;
			status.height = 100;
			status.text = "0 fps";
			status.selectable = true;
			status.backgroundColor = 0xFFFFFF;
			status.background = true;
			_root.addChild(status);
			
			_root.addEventListener(Event.ENTER_FRAME, main);
		}
		
		public function main(e:Event):void{
			
			// if fps is stable at 30
			if(FPS.value >= FPS_LIMIT){
				if(!brake){
					currentRelease = numChildren;
					brake = true;
				}
				for(i = 0; i < speed; i++){
					texture = textures[(Math.random() * textures.length) >> 0];
					mc = new MovieClip(Vector.<Texture>([texture]), 30);
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
				removeChildAt(numChildren - 1);
			}
			
			// move movieclips manually
			for(i = 0; i < numChildren; i++){
				displayObject = getChildAt(i);
				displayObject.x++;
				displayObject.rotation += 0.1;
				if(displayObject.x > WIDTH - displayObject.width) displayObject.x = 0;
			}
			
			status.text = "Moving Rotating Alpha Starling MovieClip Test\nfps: " + FPS.value + "\nMovieClips: " + numChildren + "\nfirst brake: " + firstBrake + "\nbrake: " + currentBrake + "\nrelease: " + currentRelease;
		}
		
	}

}