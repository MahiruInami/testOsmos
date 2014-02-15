package
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class LifeForm
	{
		protected static const GROW_SPEED:Number = 0.96;
		
		public var x:Number; //coordinates
		public var y:Number;
		
		public var radius:Number; // body radius, dont change it inside
		public var forceX:Number; // how fast speed changes
		public var forceY:Number;
		public var speedX:Number; //body movement speed
		public var speedY:Number;
		public var volume:Number; // body volume radius^2 * PI, dont change it inside
		public var food:Number; // food increase or decrease volume
		public var friction:Number; // movement friction
		public var bitmapData:BitmapData = new BitmapData(20, 20); // body image
		public var rect:Rectangle = new Rectangle(); // body AABB
		public var isDead:Boolean = false; // is body dead?
		public var isRandomMovement:Boolean = false; // shall body move randomly?
		
		protected var _color:uint; // body color
		protected var shape:Shape = new Shape(); // for draw body image
		protected var glow:GlowFilter = new GlowFilter(); // glow effect
		protected var _matrix:Matrix = new Matrix();
		
		public function get color():uint { return _color; } 
		public function set color(newColor:uint):void { _color = newColor; changeBitmapData(); } // if color changed redraw image
		
		
		public function LifeForm()
		{
			init();
		}
		
		/**
		 * set default values
		 */
		public function init():void
		{
			x = 0;
			y = 0;
			radius = 20;
			friction = 0.98;
			forceX = 0;
			forceY = 0;
			speedX = 0;
			speedY = 0;
			color = 0x0000FF;
			food = 0;
			volume = radius * radius * Math.PI;
			isRandomMovement = false;
			rect = new Rectangle(0, 0, (radius << 1) + 30, (radius << 1) + 30);
			shape = new Shape();
			glow = new GlowFilter(0xFFFFFF * Math.random(), 0.9, 15, 15, 2, 4);
			bitmapData = new BitmapData(rect.width, rect.height, true, 0x000000);
			
			changeBitmapData();
		}
		
		public function updatePositions():void
		{
			speedX += forceX;
			speedY += forceY;
			
			forceX = 0;
			forceY = 0;
			
			x += speedX;
			y += speedY;
			
			//speed decreased by friction
			speedX *= friction;
			speedY *= friction;
		}
		
		/**
		 * increase or decrease radius when food isn't 0
		 */
		public function grow():void
		{
			//is amount of food > 0.1, it's to reduce grow iterations
			if (Math.abs(food) > 0.1)
			{
				var growing:Number = food - food * GROW_SPEED;
				if (growing < 0.1)
				{
					radius = Math.sqrt((volume + food) / Math.PI);
					food = 0;
				}else {
					food *= GROW_SPEED;
					radius = Math.sqrt((volume + growing) / Math.PI);
				}
				//calculate new volume
				volume = radius * radius * Math.PI
				rect.width = (radius << 1) + 30; // get new AABB
				rect.height = (radius << 1) + 30;
				changeBitmapData(); // redraw
			}
		}
		
		/**
		 * update lifeForm parameters
		 */
		public function update():void
		{
			updatePositions();
			grow();
			//if body move randomly, add random force
			if (isRandomMovement)
			{
				forceX += (-1 + Math.random() * 2) * 0.05;
				forceY += (-1 + Math.random() * 2) * 0.05;
			}
		}
		
		protected function changeBitmapData():void
		{
			if (isNaN(radius)) return;
			//this is bottleneck
			//we need redraw object every time when it change
			//size or player object change size
			shape.graphics.clear();
			shape.graphics.beginFill(color, 1);
			shape.graphics.drawCircle(radius + 15, radius + 15, radius);
			shape.graphics.endFill();
			
			
			try {
				
				bitmapData = new BitmapData(rect.width, rect.height, true, 0x000000);
				bitmapData.lock();
				bitmapData.fillRect(rect, 0x00000000);
			}
			catch (e:Error)
			{
				bitmapData = new BitmapData(1, 1, true, 0x000000);
				bitmapData.lock();
			}
			
			bitmapData.draw(shape);
			bitmapData.applyFilter(bitmapData, rect, new Point(), glow);
			bitmapData.unlock();
		}
		
		/**
		 * check intersections with screen
		 * @param	rect
		 */
		public function checkRange(rect:Rectangle):void
		{
			if (x >= rect.width - radius)
			{
				x = rect.width - radius;
				speedX = -speedX;
			}
			else if (x <= radius)
			{
				x = radius;
				speedX = -speedX;
			}
			if (y >= rect.height - radius)
			{
				y = rect.height - radius;
				speedY = -speedY;
			}
			else if (y <= radius)
			{
				y = radius;
				speedY = -speedY;
			}
		}
	}
}
