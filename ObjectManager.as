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
		//protected var _rect:Rectangle;
		
		public function get gameState():int { return _gameState; }
		
		public function ObjectManager()
		{
			_objectController = new LifeFormController();
			_player = null;
			_gameState = -1;
			_counter = 0;
			//_rect = new Rectangle(0, 0, 500, 400);
			bitmapData = new BitmapData(Settings.getSettings().width, Settings.getSettings().height, true, 0xffffff);
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
			var degree:Number = Math.atan2(_player.y /*- _rect.y */- force.y, _player.x /*- _rect.x */- force.x);
			_player.forceX += Math.cos(degree) * (Math.abs(_player.x/* - _rect.x*/ - force.x)) * 0.001;
			_player.forceY += Math.sin(degree) * (Math.abs(_player.y/* - _rect.y*/ - force.y)) * 0.001;
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
			//_rect.x = _player.x - 250;
			//_rect.y = _player.y - 250;
			//if (_player.x - 250 < 0)
				//_rect.x = 0;
			//if (_player.x + 250 > Settings.getSettings().width)
				//_rect.x = Settings.getSettings().width - 500;
			//if (_player.y - 200 < 0)
				//_rect.y = 0;
			//if (_player.y + 200 > Settings.getSettings().height)
				//_rect.y = Settings.getSettings().height - 400;
			//bitmapData.lock();
			//bitmapData.fillRect(_rect, 0xffffff);
			//bitmapData.copyPixels(_objectController.draw(), _rect, new Point());
			//bitmapData.unlock();
			bitmapData = _objectController.draw();
		}
	}
}
