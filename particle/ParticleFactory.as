package particle 
{
	import flash.filters.BitmapFilter;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	/**
	 * ...
	 * @author 123
	 */
	public class ParticleFactory
	{
		
		public function ParticleFactory() 
		{
			
		}
		
		/* INTERFACE particle.IFactory */
		
		public static function createCicleParticle(color:uint):Particle 
		{
			return new CircleParticle(color);
		}
		
		public static function createMovingCicleParticle(color:uint, scale:Number):Particle 
		{
			var newParticle:CircleParticle = new CircleParticle(color);
			//newParticle.filters = [ GlowFilter ];
			newParticle.speed.x = -1 + Math.random() * 2;
			newParticle.speed.y = -1 + Math.random() * 2;
			newParticle.scale = scale;
			//var filter:BitmapFilter = new GlowFilter(color, 0.8, 35, 35);
			var filter2:BitmapFilter = new BlurFilter(10, 10, 2);
			newParticle.filters = [ /*filter, */filter2 ];
			return newParticle;
		}
	}

}