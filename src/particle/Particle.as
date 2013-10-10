package particle
{
	import flash.display.Shape;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author 123
	 */
	public class Particle extends Shape
	{
		public var iteration:int;
		public var speed:Point;
		public var friction:Number;
		public var scale:Number;
		public var alphaInc:Number;
		public var isDead:Boolean;
		
		public function Particle(color:uint = 0xFFFFFF) 
		{
			init();
			draw(color);
		}
		
		protected function init():void
		{
			iteration = 0;
			speed = new Point();
			friction = 1;
			scale = 0;
			alphaInc = 0;
		}
		
		public function update():void
		{
			updateParams();
			deadCondition();
		}
		
		protected function deadCondition():void
		{
			if (iteration > 100) isDead = true;
			if (width < 5 && height < 5) isDead = true;
		}
		
		public function updateParams():void
		{
			iteration += 1;
			x += speed.x;
			y += speed.y;
			scaleX *= scale;
			scaleY *= scale;
			alpha += alphaInc;
			
			speed.x *= friction;
			speed.y *= friction;
		}
		
		public function draw(color:uint):void
		{
			graphics.clear();
			graphics.beginFill(color);
			graphics.drawCircle(x, y, 10);
			graphics.endFill();
		}
	}

}