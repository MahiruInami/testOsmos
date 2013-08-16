package
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	public class ObjectManager extends Sprite
	{
		
		protected var _objects:Vector.<LifeForm>;
		protected var _newObjects:Vector.<LifeForm>;
		protected var _winingVolume:Number;
		protected var _player:LifeForm = null;
		/**
		 * game states:
		 * 0 - play
		 * 1 - lose
		 * 2 - win
		 */
		protected var _gameState:int;
		
		public function get getGameState():int
		{
			return _gameState;
		}
		
		//protected var _quadtree:QuadTreeNode;
		
		public function ObjectManager()
		{
			// constructor code
			mouseEnabled = false;
			_objects = new Vector.<LifeForm>;
			_newObjects = new Vector.<LifeForm>;
			//_quadtree = new QuadTreeNode(0, 0, 1200, 800);
			_gameState = 0;
			_winingVolume = 300 * 300 * Math.PI;
			//addChild(_quadtree);
		}
		
		public function addObject(lifeForm:LifeForm):void
		{
			if (lifeForm == null)
				return;
			_objects.push(lifeForm);
			//_quadtree.addObject(lifeForm);
			if (lifeForm.isPlayer)
				_player = lifeForm;
			addChild(lifeForm);
		}
		
		public function spawnObject():void
		{
			var lifeForm:LifeForm = new LifeForm(Settings.getSettings().minColor, Settings.getSettings().maxColor, _player.radius - 2 + Math.random() * (_player.radius + 4));
			lifeForm.x = Math.random() * 1200;
			lifeForm.y = Math.random() * 800;
			_newObjects.push(lifeForm);
			//addChild(lifeForm);
		}
		
		public function pushNewObjects():void
		{
			if (_newObjects.length == 0)
				return;
			var minSeparation:Number = 100;
			var dist:Point = new Point();
			var radius:Number, length:Number, minSepSq:Number;
			var pushed:Boolean = false;
			var objLength:uint = _objects.length;
			
			for (var i:uint = 0; i < _newObjects.length; i++)
			{
				pushed = false;
				for (var j:uint = 0; j < objLength; j++)
				{
					dist.x = _objects[j].x - _newObjects[i].x;
					dist.y = _objects[j].y - _newObjects[i].y;
					
					radius = _objects[j].radius + _newObjects[i].radius;
					
					length = dist.x * dist.x + dist.y * dist.y - minSeparation;
					minSepSq = Math.min(length, minSeparation);
					
					length -= minSepSq;
					
					if (length < radius * radius)
					{
						dist.normalize(2);
						// AB *= (float)((r - Math.Sqrt(d)) * 0.5f);
						_newObjects[i].x -= dist.x;
						_newObjects[i].y -= dist.y;
						pushed = true;
					}
				}
				placeObjectOnMap(_newObjects[i]);
				if (!pushed)
				{
					addChild(_newObjects[i]);
					_newObjects[i].eat(_newObjects[i].volume);
					_newObjects[i].radius = 1;
					_objects.push(_newObjects.splice(i, 1)[0]);
					i--;
				}
			}
		}
		
		public function generateCircles(minColor:uint = 0x6666FF, maxColor:uint = 0xFF6666, minRadius:Number = 15, maxRadius:Number = 30, playerRadius:Number = 20, circlesNumber:Number = 150):LifeForm
		{
			_objects = new Vector.<LifeForm>;
			removeChildren();
			var maxHeight:Number = 800, maxWidth:Number = 1200;
			var lifeForm:LifeForm;
			for (var i:int = 0; i < circlesNumber; i++)
			{
				if (i == 0)
				{
					lifeForm = new LifeForm(Settings.getSettings().playerColor, Settings.getSettings().playerColor, playerRadius);
					lifeForm.isPlayer = true;
					_player = lifeForm;
				}
				else
					lifeForm = new LifeForm(minColor, maxColor, minRadius + Math.random() * (maxRadius - minRadius));
				lifeForm.x = Math.random() * maxWidth;
				lifeForm.y = Math.random() * maxHeight;
				_objects.push(lifeForm);
				addChild(lifeForm);
			}
			return _player;
		}
		
		public function pushCircles(minDistance:Number):Boolean
		{
			var center:Point = new Point(500, 300);
			
			var minSeparation:Number = minDistance * minDistance;
			var dist:Point = new Point();
			var radius:Number, length:Number, minSepSq:Number;
			var pushed:Boolean = false;
			var objLength:uint = _objects.length;
			
			for (var i:uint = 0; i < objLength - 1; i++)
			{
				for (var j:uint = i + 1; j < objLength; j++)
				{
					dist.x = _objects[j].x - _objects[i].x;
					dist.y = _objects[j].y - _objects[i].y;
					
					radius = _objects[j].radius + _objects[i].radius;
					
					length = dist.x * dist.x + dist.y * dist.y - minSeparation;
					minSepSq = Math.min(length, minSeparation);
					
					length -= minSepSq;
					
					if (length < (radius * radius) - 0.01)
					{
						dist.normalize(0.5);
						// AB *= (float)((r - Math.Sqrt(d)) * 0.5f);
						_objects[j].x += dist.x;
						_objects[j].y += dist.y;
						_objects[i].x -= dist.x;
						_objects[i].y -= dist.y;
						pushed = true;
						
					}
				}
			}
			return pushed;
		}
		
		public function placeObjectOnMap(obj:LifeForm):Boolean
		{
			if (obj.x >= 1200 - obj.radius)
			{
				obj.x = 1200 - obj.radius;
				obj.speed.x = -obj.speed.x
			}
			else if (obj.x <= obj.radius)
			{
				obj.x = obj.radius;
				obj.speed.x = -obj.speed.x
			}
			if (obj.y >= 800 - obj.radius)
			{
				obj.y = 800 - obj.radius;
				obj.speed.y = -obj.speed.y
			}
			else if (obj.y <= obj.radius)
			{
				obj.y = obj.radius;
				obj.speed.y = -obj.speed.y
			}
			return false;
		}
		
		public function calculatePositions():void
		{
			for (var i:int = 0; i < _objects.length; i++)
			{
				_objects[i].calculate();
				_objects[i].calculateColor(_player);
				placeObjectOnMap(_objects[i]);
			}
		}
		
		public function simulate():void
		{
			//moving all circles
			//var bit:Bitmap;
			//bit.bitmapData.copyPixels
			if (_gameState)
				return;
			calculatePositions();
			pushNewObjects();
			sort();
			if (_player == null || _player.parent == null)
			{
				_gameState = 1;
				trace("null");
			}
			if (_winingVolume < _player.volume)
			{
				_gameState = 2;
				trace("low");
			}
		}
		
		public function arrangeObjects():void
		{
			//for (var i:int = 0; i < objects.length; i++) {
			//	
			//}
		}
		
		protected function sort():void
		{
			var i:int, j:int, indexCorrection:int = 0;
			var intervals:Array = [];
			var dist:Point = new Point();
			var radius:Number, length:Number;
			var compare:Function = function(obj1:LifeForm, obj2:LifeForm):Number
			{
				if (obj1.x - obj1.radius < obj2.x - obj2.radius)
				{
					return -1;
				}
				else //if(obj1.x + obj1.radius > obj2.x + obj2.radius) 
					return 1;
				//return 0;
			};
			_objects.sort(compare);
			for (i = 0; i < _objects.length; i++)
			{
				indexCorrection = 0;
				var newInterval:Interval = new Interval();
				newInterval.b = _objects[i].x - _objects[i].radius;
				newInterval.e = _objects[i].x + _objects[i].radius;
				newInterval.root = _objects[i];
				if (intervals.length == 0)
				{
					intervals.push(newInterval);
				}
				else
				{
					for (j = intervals.length - 1; j >= 0; j--)
					{
						if (intervals[j].e < newInterval.b)
						{
							intervals.splice(j, 1);
							//j--;
							continue;
						}
						else
						{
							var obj1:LifeForm = intervals[j].root;
							var obj2:LifeForm = newInterval.root;
							var collision:Number = LifeForm.calculateCollision(obj1, obj2);
							if (collision == -1)
							{
								//delete obj1
								_objects.splice(_objects.indexOf(intervals[j].root), 1);
								intervals.splice(j, 1);
								removeChild(obj1);
								//newInterval.b = newI
								//j--;
								i--;
								continue;
							}
							else if (collision == 1)
							{
								//delete obj2
								_objects.splice(_objects.indexOf(newInterval.root), 1);
								removeChild(obj2);
								i--;
								break;
							}
						}
					}
					intervals.push(newInterval);
				}
			}
		}
	}
}

class Interval
{
	public var b:Number, e:Number, index:int;
	public var root:LifeForm;
	
	public function Interval()
	{
	}
}

/*
   public function resolveCollision(_objArray:Vector.<LifeForm>):void {
   for(var i:int = _objArray.length - 1; i >= 1 ; i--)
   for (var j:int = i - 1; j >= 0; j--) {

   }
 */ /**/
