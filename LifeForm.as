package
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	//import flash.display.Shape;
	//import flash.display.Sprite;
	//import flash.events.Event;
	//import flash.filters.BitmapFilter;
	//import flash.filters.BlurFilter;
	//import flash.filters.DisplacementMapFilter;
	//import flash.filters.GlowFilter;
	//import flash.filters.GradientGlowFilter;
	//import flash.geom.Rectangle;
	//import flash.system.ImageDecodingPolicy;
	//import fl.motion.Color;
	//import flash.geom.ColorTransform;
	//import flash.geom.Point;
	//import flash.display.Bitmap;
	//import flash.geom.Point;
	
	//import flash.
	
	public class LifeForm
	{
		protected static const GROW_SPEED:Number = 0.96;
		
		public var x:Number;
		public var y:Number;
		
		public var radius:Number;
		public var forceX:Number;
		public var forceY:Number;
		public var speedX:Number;
		public var speedY:Number;
		public var volume:Number;
		public var food:Number;
		public var friction:Number;
		public var bitmapData:BitmapData = new BitmapData(20, 20);
		public var rect:Rectangle = new Rectangle();
		public var isDead:Boolean = false;
		public var isRandomMovement:Boolean = false;
		
		protected var _color:uint;
		protected var shape:Shape = new Shape();
		protected var glow:GlowFilter = new GlowFilter();
		protected var matrix:Matrix = new Matrix();
		protected var oldRadius:Number;
		
		public function get color():uint { return _color; }
		public function set color(newColor:uint):void { _color = newColor; changeBitmapData(); }
		
		
		public function LifeForm()
		{
			init();
		}
		
		public function init():void
		{
			x = 0;
			y = 0;
			radius = 20;
			oldRadius = radius;
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
			
			speedX *= friction;
			speedY *= friction;
		}
		
		public function grow():void
		{
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
				volume = radius * radius * Math.PI
				rect.width = (radius << 1) + 30;
				rect.height = (radius << 1) + 30;
				changeBitmapData();
			}
		}
		
		public function update():void
		{
			updatePositions();
			grow();
			if (isRandomMovement)
			{
				forceX += (-1 + Math.random() * 2) * 0.05;
				forceY += (-1 + Math.random() * 2) * 0.05;
			}
		}
		
		protected function changeBitmapData():void
		{
			if (isNaN(radius)) return;
			shape.graphics.clear();
			shape.graphics.beginFill(color, 1);
			shape.graphics.drawCircle(radius + 15, radius + 15, radius);
			shape.graphics.endFill();
			shape.filters = [ glow ];
			bitmapData.lock();
			try {
				//if ((radius << 1) + 30 > rect.width)
				//{
					//rect.width = (radius << 2);
					//rect.height = (radius << 2);
					bitmapData = new BitmapData(rect.width, rect.height, true, 0x000000);
				//}
				bitmapData.fillRect(rect, 0x00000000);
			}
			catch (e:Error)
			{
				bitmapData = new BitmapData(1, 1, true, 0x000000);
			}
			bitmapData.draw(shape);
			bitmapData.unlock();
			//bitmapData.copyPixels(shape
		}
		
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
