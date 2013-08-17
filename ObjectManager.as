package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	public class ObjectManager extends Bitmap
	{
		protected var _objectController:LifeFormController;
		protected var _bitmap:Bitmap;
		protected var _player:LifeForm;
		protected var _gameState:int;
		protected var _counter:int;
		
		public function get gameState():int { return _gameState; }
		
		public function ObjectManager()
		{
			_objectController = new LifeFormController();
			_player = null;
			_gameState = -1;
			_counter = 0;
		}
		
		public function addLifeForm():void
		{
			_objectController.createLifeForm();
		}
		
		public function initPlayerLifeForm():void
		{
			_player = _objectController.createLifeForm();
			_player.color = Settings.getSettings().playerColor;
			_player.isRandomMovement = false;
		}
		
		public function addForceToPlayer(force:Point):void
		{
			var degree:Number = Math.atan2(_player.y - force.y, _player.x - force.x);
			_player.forceX += Math.cos(degree) * (Math.abs(_player.x - force.x)) * 0.001;
			_player.forceY += Math.sin(degree) * (Math.abs(_player.y - force.y)) * 0.001;
		}
		
		public function generateObjects(num:int):void
		{
			_objectController.clearObjects();
			for (var i:int = 0; i < num; i++)
				_objectController.createLifeForm();
			_objectController.placeObjectsWithoutIntersections(50);
		}
		
		public function initGame():void
		{
			generateObjects(Settings.getSettings().enemyNumber);
			initPlayerLifeForm();
			_gameState = 0;
			//if (_player)
			//	_player.init();
		}
		
		public function clear():void
		{
			_player = null;
			_gameState = 0;
			_objectController.clearObjects();
		}

		public function update():void
		{
			if (_gameState == Settings.PLACING)
			{
				if (!_objectController.placeObjectsWithoutIntersections(50)) _gameState = Settings.PLAYING;
				
			}else if (_gameState == Settings.PLAYING)
			{
				if (_counter > 50)
				{
					_objectController.createBufferLifeForm();
					_counter = 0;
				}
				_objectController.update(_player);
				if (_player.isDead) _gameState = Settings.LOOSE;
				if (_player.volume > Settings.WIN_VOLUME) _gameState = Settings.WIN;
				_counter += 1;
			}
			bitmapData = _objectController.draw();
			//var bitData:BitmapData = _objectController.draw();
			//this.graphics.beginBitmapFill(bitData);
			//this.graphics.endFill();
			//_bitmap.bitmapData = bitData;
		}
	}
}
