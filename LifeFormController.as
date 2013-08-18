package
{
	import adobe.utils.ProductManager;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.display.Shape;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author 123
	 */
	public class LifeFormController
	{
		protected var _objects:Vector.<LifeForm>; // objects pool
		protected var _newObjects:Vector.<LifeForm>; // new objects buffer
		protected var _bitmapData:BitmapData; // game field image
		protected var _rect:Rectangle; // game field rectangle
		//protected var _tree:QuadTree;
		
		public function LifeFormController()
		{
			init();
		}
		
		public function init():void
		{
			_objects = new Vector.<LifeForm>();
			_newObjects = new Vector.<LifeForm>();
			_rect = new Rectangle(0, 0, Settings.getSettings().width, Settings.getSettings().height);
			_bitmapData = new BitmapData(_rect.width, _rect.height, true, 0x000000);
		}
		
		/**
		 * update object positions, solve collisions
		 * change colors, add new objects
		 * @param	player
		 */
		public function update(player:LifeForm):void
		{
			simulate(player);
			//add new objects
			placeBOWithoutIntersections(100);
		}
		
		/**
		 * update obj2 color using diffecrence
		 * through obj1.radius amd obj2.radius
		 * @param	obj1
		 * @param	obj2
		 */
		public function updateColors(obj1:LifeForm, obj2:LifeForm):Boolean
		{
			//color mix percent
			var multiplayer:Number;
			if (obj1.radius > (obj2.radius << 1))
				multiplayer = 1.0;
			else if ((obj1.radius << 1) < obj2.radius)
				multiplayer = 0.0;
			else
				multiplayer = 1.5 - obj2.radius / obj1.radius; //get multiplayer, it's between 0.1 and 0.9 
			var newColor:uint = getColorSum(Settings.getSettings().minColor, Settings.getSettings().maxColor, multiplayer, 1 - multiplayer);
			if (newColor == obj2.color) return false;
			obj2.color = newColor;
			return true;
		}
		
		/**
		 * sum of colors
		 * @param	color1
		 * @param	color2
		 * @param	color1Percent - percent of first color
		 * @param	color2Percent - percent of second color
		 * @return return mix of colors
		 */
		protected function getColorSum(color1:uint, color2:uint, color1Percent:Number, color2Percent:Number):uint
		{
			//translate colors in rgb and get mix
			var r:Number = Math.min((color1 >> 16) * color1Percent + (color2 >> 16) * color2Percent, 255);
			var g:Number = Math.min(((color1 & 0x00FF00) >> 8) * color1Percent + ((color2 & 0x00FF00) >> 8) * color2Percent, 255);
			var b:Number = Math.min((color1 & 0x0000FF) * color1Percent + (color1 & 0x0000FF) * color2Percent, 255);
			//get new color by r,g and b components
			var sum:int = (r << 16) + (g << 8) + b;
			return sum;
		}

		/**
		 * draw objects to bitmapData
		 * @return
		 */
		public function draw():BitmapData
		{
			_bitmapData.lock();
			_bitmapData.fillRect(_rect, 0x000000);
			for (var i:int = _objects.length - 1; i >= 0; i--)
			{
				var obj:LifeForm = _objects[i];
				//dont draw body if it's dead
				if (obj.isDead) continue;
				_bitmapData.copyPixels(obj.bitmapData, obj.rect, new Point(obj.x - obj.radius - 15, obj.y - obj.radius - 15), null, null, true);
				
			}
			_bitmapData.unlock();
			return _bitmapData;
		}
		
		/**
		 * add new life form
		 * @return return created object
		 */
		public function createLifeForm():LifeForm
		{
			var lifeForm:LifeForm = new LifeForm();
			//get random coordinates
			lifeForm.x = Math.random() * Settings.getSettings().width;
			lifeForm.y = Math.random() * Settings.getSettings().height;
			//add new object to objects pool
			_objects.push(lifeForm);
			lifeForm.isRandomMovement = true;
			return lifeForm;
		}
		
		public function createBufferLifeForm():void
		{
			var lifeForm:LifeForm;
			if (_newObjects.length > 5)
				lifeForm = _newObjects.shift();
			else
				lifeForm = new LifeForm();
			lifeForm.x = Math.random() * Settings.getSettings().width;
			lifeForm.y = Math.random() * Settings.getSettings().height;
			lifeForm.isRandomMovement = true;
			_newObjects.push(lifeForm);
		}
		
		public function collision(obj1:LifeForm, obj2:LifeForm):Point
		{
			var distance:Point = new Point(obj1.x - obj2.x, obj1.y - obj2.y);
			if (distance.length < obj1.radius + obj2.radius)
			{
				return distance;
			}
			distance.x = -1;
			distance.y = -1;
			return distance;
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
					if (obj2.volume < 150 || obj1.radius > distance.length + obj2.radius)
					{
						obj1.food += obj2.food;
						obj1.food += obj2.volume;
						obj2.food = 0;
						obj2.isDead = true;
						return -1;
					}
					else
					{
						if (obj2.food > 0)
						{
							obj1.food += obj2.food;
							obj2.food = 0;
						}
						else
						{
							obj1.food += obj2.volume * 0.1;
							obj2.food -= obj2.volume * 0.1;
						}
						obj2.forceX += Math.cos(atan) / 20;
						obj2.forceY += Math.sin(atan) / 20;
					}
				}
				else
				{
					if (obj1.volume < 150 || obj2.radius > distance.length + obj1.radius)
					{
						obj2.food += obj1.food;
						obj2.food += obj1.volume;
						obj1.food = 0;
						obj1.isDead = true;
						return 1;
					}
					else
					{
						if (obj1.food > 0)
						{
							obj2.food += obj1.food;
							obj1.food = 0;
						}
						else
						{
							obj2.food += obj1.volume * 0.1;
							obj1.food -= obj1.volume * 0.1;
						}
						obj1.forceX -= Math.cos(atan) / 20;
						obj1.forceY -= Math.sin(atan) / 20;
					}
				}
			}
			return 0;
		}
		
		public function clearObjects():void
		{
			_objects = new <LifeForm>[];
		}
		
		public function placeBOWithoutIntersections(minDistance:Number):void
		{
			for (var i:int = _newObjects.length - 1; i >= 0; i--)
			{
				_newObjects[i].checkRange(_rect);
				for (var j:int = 0; j < _objects.length; j++)
					if (!pushObjects(_newObjects[i], _objects[j], minDistance, true, false))
					{
						var lifeForm:LifeForm = _newObjects.splice(i, 1)[0];
						_objects.push(lifeForm);
						lifeForm.radius = 1;
						lifeForm.food += 100 + Math.random() * 15000;
						break;
					}
			}
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
		
		public function pushObjects(obj1:LifeForm, obj2:LifeForm, minDistanse:Number, pushFirst:Boolean = true, pushSecond:Boolean = true):Boolean
		{
			var dist:Point = new Point();
			dist.x = obj1.x - obj2.x;
			dist.y = obj1.y - obj2.y;
			var radius:Number = obj1.radius + obj2.radius;
			var minSepSq:Number = minDistanse * minDistanse;
			
			var length:Number = dist.x * dist.x + dist.y * dist.y - minSepSq;
			minSepSq = Math.min(length, minSepSq);
					
			length -= minSepSq;
			
			if (length < radius * radius)
			{
				dist.normalize(1);
				if (pushSecond)
				{
					obj2.x -= dist.x;
					obj2.y -= dist.y;
				}
				if (pushFirst)
				{
					obj1.x += dist.x;
					obj1.y += dist.y;
				}
				return true;
			}
			return false;
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
		
		private function qSort(obj:Vector.<LifeForm>, min:int, max:int):void {
			if (min >= max) return;
			var i:int = min;
			var j:int = max;
			var x:LifeForm = obj[Math.round((min + max) / 2)];
			var temp:LifeForm;
			
			do{
				while(obj[i].x - obj[i].radius < x.x - x.radius) i++;
				while(obj[j].x - obj[j].radius > x.x - x.radius) j--;
				if(i <= j){
					temp = obj[j];
					obj[j] = obj[i];
					obj[i] = temp;
					i++; j--;
				}
			}while(i < j);
			if(min < j) qSort(obj, min, j);
			if(i < max) qSort(obj, i, max);
		}

		protected function simulate(player:LifeForm):void
		{
			var i:int, j:int;
			//array with body's intervals;
			var intervals:Array = [];
			var radius:Number, length:Number;
			//var time:Number = getTimer();
			//calculate new positions and forces for bodys
			//and change its color
			length = _objects.length; // this away faster
			for (i = 0; i < length; i++)
			{
				_objects[i].update();
				_objects[i].checkRange(_rect);
				if (_objects[i] != player)
					updateColors(player, _objects[i]);
			}
			//trace(getTimer() - time);
			//qsort is much faster than default vector.sort
			qSort(_objects, 0, length - 1);
			/**
			 * SAP(sweep and prune broadphase algorithm
			 * first, we need sorted body;s array
			 * i sorted by coordinate x minus radius
			 * second, for each body in  array we created intervals
			 * and if we add new interval while previous interval exist in intervals pool
			 * it means that object may intersect and we need to check...
			 */
			for (i = 0; i < _objects.length; i++)
			{
				var newInterval:Interval = new Interval(); // create new interval
				newInterval.b = _objects[i].x - _objects[i].radius; // interval begin
				newInterval.e = _objects[i].x + _objects[i].radius; // interval end
				newInterval.root = _objects[i]; // owner of interval
				if (intervals.length == 0) // if interval's pool is empy just add new interval
					intervals.push(newInterval);
				else
				{
					for (j = intervals.length - 1; j >= 0; j--) // check new interval with other interval for collision
					{
						if (intervals[j].e < newInterval.b) // if begining of new interval greater than
						{									// other interval ending than delete it(intervals sorted...)
							intervals.splice(j, 1);
							continue;
						}
						else
						{
							var obj1:LifeForm = intervals[j].root; 	
							var obj2:LifeForm = newInterval.root;
							var collision:int = detectCollision(obj1, obj2); // check for objects intersection
							if (collision == 1)								
							{
								_objects.splice(_objects.indexOf(intervals[j].root), 1); // if first object is dead delete it
								intervals.splice(j, 1);
								i--;
								continue;
							}
							else if (collision == -1)
							{
								_objects.splice(_objects.indexOf(newInterval.root), 1); // if second object is dead delete it
								i--;
								break;
							}
						}
					}
					intervals.push(newInterval); // add new interval to the pool
				}
			}
			//trace(getTimer() - time);
		}
	}

}

// additional class for SAP
class Interval
{
	public var b:Number, e:Number, index:int;
	public var root:LifeForm;
	
	public function Interval()
	{
	}
}