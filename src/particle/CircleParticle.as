package particle
{
	/**
	 * ...
	 * @author 123
	 */
	public class CircleParticle extends Particle 
	{
		
		public function CircleParticle(color:uint = 0xFFFFFF) 
		{
			super(color);
		}
		
		override public function draw(color:uint):void
		{
			graphics.clear();
			graphics.beginFill(color);
			graphics.drawCircle(x, y, 10);
			graphics.endFill();
		}
	}

}