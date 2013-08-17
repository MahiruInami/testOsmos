package particle 
{
	import flash.display.Sprite;
	/**
	 * ...
	 * @author 123
	 */
	public class ParticleController extends Sprite
	{
		private var _particles:Vector.<Particle>;
		private var _utilizedParticles:Vector.<Particle>;
		
		public function get numParticles():int { return _particles.length; }
		private const MAX_PARTICLES:int = 2500;
		
		public function ParticleController() 
		{
			_particles = new Vector.<Particle>();
			this.mouseChildren = false;
			this.mouseEnabled = false;
		}
		
		public function addCircleParticle(xPos:int, yPos:int, color:uint = 0xFFFFFF):void
		{
			if (_particles.length > MAX_PARTICLES) _particles.shift();
			var _particle:Particle = ParticleFactory.createMovingCicleParticle(color, 0.98);
			_particle.x = xPos;
			_particle.y = yPos;
			addChild(_particle);
			_particles.push(_particle);
		}
		
		public function update():void
		{
			for (var i:int = _particles.length - 1; i >= 0; i--)
			{
				_particles[i].update();
				if (_particles[i].isDead) {
					removeChild(_particles[i]);
					_particles.splice(i, 1);
					//i--;
				}
			}
		}
	}

}