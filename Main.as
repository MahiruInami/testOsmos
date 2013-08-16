package
{
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.utils.getTimer;
	import particle.ParticleController;
	
	/**
	 * ...
	 * @author 123
	 */
	//TODO: FIX MOUSE ERROR WHEN MINIMIZE WINDOW
	// IMPLEMENT SPATIAL HASHING or UNIFORM GRID
	//
	[SWF(width="1200",height="800",backgroundColor="#000000",frameRate="45")]
	public class Main extends Sprite
	{
		
		[Embed(source = "/assets/logo.png")]
		private static var _logoClass:Class;
		[Embed(source = "/assets/gameOverLogo.png")]
		private static var _gameOverLogoClass:Class;
		[Embed(source = "/assets/victoryLogo.png")]
		private static var _victoryLogoClass:Class;
		
		private var _player:LifeForm;
		private var _manager:ObjectManager;
		private var _startButton:Button;
		private var _render:Sprite;
		private var _mouseDown:Boolean = false;
		private var _force:Number = 1.01;
		private var _cursorPosition:Point = new Point();
		private var _particleManager:ParticleController;
		private var _pushing:Boolean;
		private var _iteration:int;
		
		private var _bitData:BitmapData;

		private var scanX:int;
		
		public function Main():void
		{
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			this.mouseEnabled = false;
			
			//stage.mouseEnabled = false;
			// entry point
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			initMainMenu();
		}
		
		private function initScreen(initClass:Class):void
		{
			_render = new Sprite();
			addChild(_render);
			
			_startButton = new Button();
			_startButton.x = stage.stageWidth / 2 - _startButton.width / 2;
			_startButton.y = stage.stageHeight / 2;
			_startButton.addEventListener(MouseEvent.CLICK, startNewGame);
			addChild(_startButton);
			
			var _logo:* = new initClass();
			_logo.x = stage.stageWidth / 2 - _logo.width / 2;
			_logo.y = stage.stageHeight / 8;
			addChild(_logo);
			_bitData = new BitmapData(stage.stageWidth, stage.stageHeight, false, 0x000000);
			_bitData.draw(stage);
			
			_particleManager = new ParticleController();
			addChild(_particleManager);
			setChildIndex(_particleManager, numChildren - 1);
			scanX = 0;
			
			addEventListener(Event.ENTER_FRAME, mainLoop);
		}
		
		private function initMainMenu():void {
			initScreen(_logoClass);
		}
		
		private function initGameOverScreen():void {
			initScreen(_gameOverLogoClass);
		}
		
		private function initVictoryScreen():void {
			initScreen(_victoryLogoClass);
		}
		
		private function initGameScreen():void
		{
			_iteration = 0;
			_manager = new ObjectManager();
			_player = _manager.generateCircles(Settings.getSettings().minColor, Settings.getSettings().maxColor, 15, 30, 20, 
			Settings.getSettings().enemyNumber);
			_pushing = true;
			//stage.quality = "low";
			//addChild(_particleManager);
			addChild(_manager);
			addEventListener(Event.ENTER_FRAME, gameLoop);
			//stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, true);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			//addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			//addEventListener(MouseEvent.MOUSE_UP, onMouseUp);

			//drawGrid();
		}

		private function onMouseDown(e:MouseEvent):void
		{
			_mouseDown = true;
			_force = 0.005;
		}
		
		private function onMouseUp(e:MouseEvent):void
		{
			_mouseDown = false;
		}

		public function addForce():void
		{
			if (_mouseDown)
			{
				//var objPoint:Point = new Point(player.x, player.y);
				//var degree:Number = Math.atan2(player.y - _cursorPosition.y, player.x - _cursorPosition.x);
				_player.speed.x += (_player.x - stage.mouseX) * _force;
				_player.speed.y += (_player.y - stage.mouseY) * _force;
			}
		}
		
		private function startNewGame(e:MouseEvent):void
		{
			_startButton.removeEventListener(MouseEvent.CLICK, startNewGame);
			removeEventListener(Event.ENTER_FRAME, mainLoop);
			this.removeChildren();
			_startButton = null;
			_particleManager = null;
			LoadConfigXML("config.txt");
			//var start:Node = new Node();
			//var end:Node = start;
			//for (var i:int = 0; i < 100; i++) {
				//var addNode:Node = new Node();
				//end.push(addNode);
				//end = addNode;
			//}
			//trace(start);
			//trace(end);
			//end = null;
		}
		
		public function gameLoop(e:Event):void
		{
			if (_pushing) {
				_pushing = _manager.pushCircles(20);
				_manager.calculatePositions();
			}
			else {
				//var time:int = getTimer();
				_iteration++;
				if (_iteration > 50){_manager.spawnObject(); _iteration = 0;}
				addForce();
				//_manager.pushCircles(20);
				//_manager.calculatePositions();
				_manager.simulate();
				//trace(getTimer() - time);
			}	
			var gameState:int = _manager.getGameState;
			if (gameState > 0) {
				removeEventListener(Event.ENTER_FRAME, gameLoop);
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				this.removeChildren();
				if(gameState == 1)
					initGameOverScreen();
				else
					initVictoryScreen();
			}
			//_particleManager.update();
			//_particleManager.addCircleParticle(Math.random() * _bitData.width, Math.random() * _bitData.height, 0x00FFFF * ( 1 - Math.random() * 0.5));
		}
		
		public function mainLoop(e:Event):void
		{
			//manager.simulate();
			//add particle manager
			
			_particleManager.update();
			_particleManager.addCircleParticle(Math.random() * _bitData.width, Math.random() * _bitData.height, 0x00FFFF * ( 1 - Math.random() * 0.5));
			//_particleManager.addParticle(particle);
			
			/*scanX += 6;
			
			if (scanX > stage.stageWidth) scanX = 0;
			
			for (var ypos:Number = 0; ypos < _bitData.height; ypos += 5) {
				var xpos:Number = scanX;
				if (xpos > 0) */
				//for (var i:int = 0; i < 70; i++ ){
					//
					//var xpos:Number = Math.random() * _bitData.width;
					//var ypos:Number = Math.random() * _bitData.height;
					//var col:Number = _bitData.getPixel(xpos, ypos);
					//
					//trace(col);
					//if (col > 0x000000 && col < 0x002BFF) {
						//particle = new SpaceParticle();
						//particle.x = xpos;/*Math.random() * stage.stageWidth;*/
						//particle.y = ypos;/* Math.random() * stage.stageHeight;*/
						//_particleManager.addParticle(particle);
					//}
				//}
		}
		
		public function LoadConfigXML(configPath:String):void
		{
			var xmlURL:String = configPath;
 
			var configRequest:URLRequest = new URLRequest();
			configRequest.url = xmlURL;
 
			var assetLoader:URLLoader = new URLLoader();
			assetLoader.addEventListener(Event.COMPLETE, parseConfig);
			assetLoader.load(configRequest);
		}
		
		private function parseConfig(e:Event):void {
			Settings.getSettings().parseConfig(e.target.data);
			initGameScreen();
		}
	
	}
}