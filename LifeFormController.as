package
{
	import adobe.utils.ProductManager;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.display.Shape;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author 123
	 */
	public class LifeFormController
	{
		protected var _objects:Vector.<LifeForm>;
		protected var _newObjects:Vector.<LifeForm>;
		protected var _bitmapData:BitmapData;
		protected var _rect:Rectangle;
		
		public function LifeFormController()
		{
			init();
		}
		
		public function init():void
		{
			_objects = new Vector.<LifeForm>();
			_newObjects = new Vector.<LifeForm>();
			_rect = new Rectangle(0, 0, 1200, 800);
			_bitmapData  = new BitmapData(_rect.width, _rect.height, true, 0x000000);
		}
		
		public function update():void
		{
			for (var i:uint = 0; i < _objects.length; i++)
			{
				_objects[i].update();
				_objects[i].checkRange(_rect);
			}
			resolveCollisions();
		}
		
		public function draw():BitmapData
		{
			_bitmapData.fillRect(_rect, 0x000000);
			for (var i:int = _objects.length - 1; i >= 0; i--)
			{
				var obj:LifeForm = _objects[i];
				_bitmapData.copyPixels(obj.bitmapData, obj.rect, new Point(obj.x - obj.radius - 15, obj.y - obj.radius - 15), null, null, true);
				
			}
			//_bitmapData.applyFilter(_bitmapData, _rect, new Point(), new GlowFilter(0x00FFFF, 0.9, 20, 20, 2, 4));
			return _bitmapData;
		}
		
		public function createLifeForm():LifeForm
		{
			var lifeForm:LifeForm = new LifeForm();
			lifeForm.x = Math.random() * _rect.width;
			lifeForm.y = Math.random() * _rect.height;
			lifeForm.isRandomMovement = true;
			_objects.push(lifeForm);
			return lifeForm;
		}
		
		public function collision(obj1:LifeForm, obj2:LifeForm):Point
		{
			var distance:Point = new Point(obj1.x - obj2.x, obj1.y - obj2.y);
			//var distance:Number = Math.sqrt(Math.pow(this.x - lifeForm.x, 2) + Math.pow(this.y - lifeForm.y, 2));
			if (distance.length < obj1.radius + obj2.radius)
			{
				return distance;
			}
			distance.x = -1;
			distance.y = -1;
			return distance;
		}
		
		public function placeObjectsWithoutIntersections(minDistance:Number):Boolean
		{
			for (var i:uint = 0; i < _objects.length; i++)
			{
				_objects[i].update();
				_objects[i].checkRange(_rect);
			}
			return pushAllObjects(minDistance);
		}
		
		public function pushObjects(obj1:LifeForm, obj2:LifeForm, minDistanse:Number):Boolean
		{
			var dist:Point = new Point();
			dist.x = obj1.x - obj2.x;
			dist.y = obj1.y - obj2.y;
			var radius:Number = obj1.radius + obj2.radius;
			
			var length: Number = dist.x * dist.x + dist.y * dist.y - minDistanse; 
			
			//length = Math.min(length, minDistanse);

			if (length < radius * radius)
			{
				dist.normalize(0.5);
				//AB *= (float)((r - Math.Sqrt(d)) * 0.5f);
				obj2.x -= dist.x;
				obj2.y -= dist.y;
				obj1.x += dist.x;
				obj1.y += dist.y;
				return true;	
			}
			return false;
		}
		
		public function clearObjects():void
		{
			_objects = new Vector.<LifeForm>();
		}
		
		public function pushAllObjects(minDistance:Number):Boolean
		{
			var pushed:Boolean = false;
			var objLength:uint = _objects.length;
			
			for (var i:uint = 0; i < objLength - 1; i++)
			{
				for (var j:uint = i + 1; j < objLength; j++)
				{
					if (pushObjects(_objects[i], _objects[j], minDistance))
						pushed = true;
				}
			}
			return pushed;
		}
		
		public function detectCollision(obj1:LifeForm, obj2:LifeForm):int
		{
			var distance:Point = collision(obj1, obj2);
			if (distance.x == -1)
				return 0;
			if (distance.length < obj1.radius + obj2.radius)
			{
				var atan:Number = Math.atan2(obj2.y - obj1.y, obj2.x - obj1.x);
				if (obj1.volume > obj2.volume)
				{
					if (obj2.volume < 150 || obj1.radius > distance.length + obj2.radius) {
						obj1.food += obj2.food;
						obj1.food += obj2.volume;
						obj2.food = 0;
						return -1;
					}else {
						if (obj2.food > 0){
							obj1.food += obj2.food;
							obj2.food = 0;
						}else{
							obj1.food += obj2.volume * 0.1;
							obj2.food -= obj2.volume * 0.1;
						}
						obj2.forceX += Math.cos(atan) / 20;
						obj2.forceY += Math.sin(atan) / 20;
					}
				}else {
					if (obj1.volume < 150 || obj2.radius > distance.length + obj1.radius) {
						obj2.food += obj1.food;
						obj2.food += obj1.volume;
						obj1.food = 0;
						return 1;
					}else {
						if (obj1.food > 0){
							obj2.food += obj1.food;
							obj1.food = 0;
						}else{
							obj2.food += obj1.volume * 0.1;
							obj1.food -= obj1.volume * 0.1;
						}
						obj1.forceX -= Math.cos(atan) / 20;
						obj1.forceY -= Math.sin(atan) / 20;
					}
				}
			}
			return 0;
			//obj2.parent.setChildIndex(obj2, obj2.parent.numChildren - 1);
			//S *= 0.9;
			//S2 = totalS - S - S2;
			//
			//
		}
		
		public function sort():void
		{
			var compare:Function = function(obj1:LifeForm, obj2:LifeForm):Number
			{
				if (obj1.x - obj1.radius < obj2.x - obj2.radius)
					return -1;
				else
					return 1;
			};
			_objects.sort(compare);
		}
		
		protected function resolveCollisions():void
		{
			var i:int, j:int, indexCorrection:int = 0;
			var intervals:Array = [];
			var dist:Point = new Point();
			var radius:Number, length:Number;
			sort();
			for (i = 0; i < _objects.length; i++)
			{
				var newInterval:Interval = new Interval();
				newInterval.b = _objects[i].x - _objects[i].radius;
				newInterval.e = _objects[i].x + _objects[i].radius;
				newInterval.root = _objects[i];
				if (intervals.length == 0)
					intervals.push(newInterval);
				else
				{
					for (j = intervals.length - 1; j >= 0; j--)
					{
						if (intervals[j].e < newInterval.b)
						{
							intervals.splice(j, 1);
							continue;
						}
						else
						{
							var obj1:LifeForm = intervals[j].root;
							var obj2:LifeForm = newInterval.root;
							var collision:int = detectCollision(obj1, obj2);
							if (collision == 1)
							{
								_objects.splice(_objects.indexOf(intervals[j].root), 1);
								intervals.splice(j, 1);
								i--;
								continue;
							}
							else if (collision == -1)
							{
								_objects.splice(_objects.indexOf(newInterval.root), 1);
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