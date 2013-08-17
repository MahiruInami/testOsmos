package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	public class ObjectManager extends Sprite
	{
		protected var _objectController:LifeFormController;
		protected var _bitmap:Bitmap;
		protected var _player:LifeForm;
		protected var _gameState:int;
		protected var _counter:int;
		
		public function get gameState():int { return _gameState; }
		
		public function ObjectManager()
		{
			// constructor code
			mouseEnabled = false;
			_objectController = new LifeFormController();
			_bitmap = new Bitmap();
			addChild(_bitmap);
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
			_player.color = 0x00FF00;
			_player.isRandomMovement = false;
			//_player.x = 300;
			//_player.y = 200;
			//_player.speedY = 0.5;
			//_player.food += 1;
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
			//while (_objectController.placeObjectsWithoutIntersections(50));
			initPlayerLifeForm();
			_gameState = 0;
		}

		//public function spawnObject():void
		//{
			//var lifeForm:LifeForm = new LifeForm(Settings.getSettings().minColor, Settings.getSettings().maxColor, _player.radius - 2 + Math.random() * (_player.radius + 4));
			//lifeForm.x = Math.random() * 1200;
			//lifeForm.y = Math.random() * 800;
			//_newObjects.push(lifeForm);
			//addChild(lifeForm);
		//}
		//
		//public function pushNewObjects():void
		//{
			//if (_newObjects.length == 0)
				//return;
			//var minSeparation:Number = 100;
			//var dist:Point = new Point();
			//var radius:Number, length:Number, minSepSq:Number;
			//var pushed:Boolean = false;
			//var objLength:uint = _objects.length;
			//
			//for (var i:uint = 0; i < _newObjects.length; i++)
			//{
				//pushed = false;
				//for (var j:uint = 0; j < objLength; j++)
				//{
					//dist.x = _objects[j].x - _newObjects[i].x;
					//dist.y = _objects[j].y - _newObjects[i].y;
					//
					//radius = _objects[j].radius + _newObjects[i].radius;
					//
					//length = dist.x * dist.x + dist.y * dist.y - minSeparation;
					//minSepSq = Math.min(length, minSeparation);
					//
					//length -= minSepSq;
					//
					//if (length < radius * radius)
					//{
						//dist.normalize(2);
						// AB *= (float)((r - Math.Sqrt(d)) * 0.5f);
						//_newObjects[i].x -= dist.x;
						//_newObjects[i].y -= dist.y;
						//pushed = true;
					//}
				//}
				//placeObjectOnMap(_newObjects[i]);
				//if (!pushed)
				//{
					//addChild(_newObjects[i]);
					//_newObjects[i].eat(_newObjects[i].volume);
					//_newObjects[i].radius = 1;
					//_objects.push(_newObjects.splice(i, 1)[0]);
					//i--;
				//}
			//}
		//}
		//
		//public function generateCircles(minColor:uint = 0x6666FF, maxColor:uint = 0xFF6666, minRadius:Number = 15, maxRadius:Number = 30, playerRadius:Number = 20, circlesNumber:Number = 150):LifeForm
		//{
			//_objects = new Vector.<LifeForm>;
			//removeChildren();
			//var maxHeight:Number = 800, maxWidth:Number = 1200;
			//var lifeForm:LifeForm;
			//for (var i:int = 0; i < circlesNumber; i++)
			//{
				//if (i == 0)
				//{
					//lifeForm = new LifeForm(Settings.getSettings().playerColor, Settings.getSettings().playerColor, playerRadius);
					//lifeForm.isPlayer = true;
					//_player = lifeForm;
				//}
				//else
					//lifeForm = new LifeForm(minColor, maxColor, minRadius + Math.random() * (maxRadius - minRadius));
				//lifeForm.x = Math.random() * maxWidth;
				//lifeForm.y = Math.random() * maxHeight;
				//_objects.push(lifeForm);
				//addChild(lifeForm);
			//}
			//return _player;
		//}

		public function update():void
		{
			if (_gameState == Settings.PLACING)
			{
				if (!_objectController.placeObjectsWithoutIntersections(1000)) _gameState = Settings.PLAYING;
				
			}else if (_gameState == Settings.PLAYING)
			{
				if (_counter > 50)
				{
					_objectController.createBufferLifeForm();
					_counter = 0;
				}
				_objectController.update();
				_objectController.updateEnemyColors(_player);
				if (_player.isDead) _gameState = Settings.LOOSE;
				if (_player.volume > Settings.WIN_VOLUME) _gameState = Settings.WIN;
				_counter += 1;
			}
			var bitData:BitmapData = _objectController.draw();
			_bitmap.bitmapData = bitData;
		}
	}
}
