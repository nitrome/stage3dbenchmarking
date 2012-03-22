package  {
	import com.adobe.utils.AGALMiniAssembler;
	import com.nitrome.util.FPS;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.textures.TextureBase;
	import flash.display3D.VertexBuffer3D;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.text.TextField;
	import flash.display3D.Context3DRenderMode;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Context3DCompareMode;
	
	/**
	 * Rubberbanded benchmark - tries to maintain 30fps
	 * 
	 * result:
		
		Static ND2D SpriteBatch Test
		fps: 25
		Sprites: 3415
		first brake: 3480
		brake: 3416
		release: 3016
		
	 * 
	 * @author Aaron Steed, nitrome.com
	 */
	public class Game {
		
		public var root:MovieClip;
		public var stage:Stage;
		public var context3D:Context3D;
		public var status:TextField;
		public var atlas:BitmapData;
		public var speed:int;
		public var brake:Boolean;
		
		public var program:Program3D;
		
		public var firstBrake:int;
		public var currentBrake:int;
		public var currentRelease:int;
		
		// temps
		private var i:int;
		private var length:int;
		private var indexBuffer:IndexBuffer3D;
		private var stage3D:Stage3D;
		
		public static const WIDTH:Number = 320;
		public static const HEIGHT:Number = 480;
		public static const FPS_LIMIT:int = 30;
		public static const DEFAULT_SPEED:int = 20;
		
		public function Game(root:MovieClip) {
			
			this.root = root;
			stage = root.stage;
			
			FPS.start();
			speed = DEFAULT_SPEED;
			atlas = new AtlasBD(1, 1);
			status = new TextField();
			status.width = 200;
			status.height = 200;
			status.selectable = true;
			status.filters = [new GlowFilter(0xFFFFFF, 1, 4, 4, 2000)];
			root.addChild(status);
			
			// CREATE CONTEXT3D AND THEN WAIT
			
			stage3D = stage.stage3Ds[0];
			
			stage3D.addEventListener(Event.CONTEXT3D_CREATE, context3DCreated);
			stage3D.addEventListener(ErrorEvent.ERROR, context3DError);
			stage3D.requestContext3D(Context3DRenderMode.AUTO);
		}
		
		protected function context3DError(e:ErrorEvent):void {
			throw new Error("The SWF is not embedded properly. The 3D context can't be created. Wrong WMODE? Set it to 'direct'.");
		}
		
		protected function context3DCreated(e:Event):void {
			
			// CONTEXT3D INIT
			stage3D.x = 0;
			stage3D.y = 0;
			context3D = stage3D.context3D;
			context3D.enableErrorChecking = true;
			context3D.setCulling(Context3DTriangleFace.NONE);
			context3D.setDepthTest(false, Context3DCompareMode.ALWAYS);
			context3D.configureBackBuffer(WIDTH, HEIGHT, 1, true);
			trace(context3D.driverInfo);
			
			
			// VERTEX INIT
			
			var vertexBuffer:VertexBuffer3D = context3D.createVertexBuffer(3, 6);
			var vertices:Vector.<Number> = Vector.<Number>([
				-0.3,-0.3,0, 1, 0, 0, // x, y, z, r, g, b
				-0.3, 0.3, 0, 0, 1, 0,
				0.3, 0.3, 0, 0, 0, 1]);
			vertexBuffer.uploadFromVector(vertices, 0, 3);
			
			indexBuffer = context3D.createIndexBuffer(6);
			indexBuffer.uploadFromVector(Vector.<uint>([0, 1, 2, 2, 3, 0]), 0, 6);
			
			
			// SHADER INIT
			
			var av:AGALMiniAssembler = new AGALMiniAssembler();
			av.assemble(Context3DProgramType.VERTEX,
				"m44 op, va0, vc0 \n" + // pos to clipspace
				"mov v0, va1 \n"// copy color
			);
			
			var af:AGALMiniAssembler = new AGALMiniAssembler();
			af.assemble(Context3DProgramType.FRAGMENT, "mov oc, v0");
			
			program = context3D.createProgram();
			program.upload(av.agalcode, af.agalcode);
			
			
			
			
			
			
			
			
			root.addEventListener(Event.ENTER_FRAME, main);
			
			
		}
		
		
		
		
		
		
		public function main(e:Event):void{
			
			context3D.clear(0, 0, 0, 1);
			context3D.setProgram(program);
            context3D.drawTriangles(indexBuffer, 0, 1);
			
			context3D.present();
			
			// if fps is stable at 30
			if(FPS.value >= FPS_LIMIT){
				if(!brake){
					//currentRelease = spriteBatch.numChildren;
					brake = true;
				}
				for(i = 0; i < speed; i++){
					// add
				}
				
			} else {
				if(brake && speed > 1){
					//if(firstBrake == 0) firstBrake = spriteBatch.numChildren;
					//currentBrake = spriteBatch.numChildren;
					brake = false;
					speed--;
				}
				// remove
				
			}
			
			//status.text = "Static ND2D SpriteBatch Test\nfps: " + FPS.value + "\nSprites: " + spriteBatch.numChildren + "\nfirst brake: " + firstBrake + "\nbrake: " + currentBrake + "\nrelease: " + currentRelease;
		}
		
	}

}