package
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.filters.GlowFilter;
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
		public var color:uint;
		public var food:Number;
		public var friction:Number;
		public var bitmapData:BitmapData;
		protected var shape:Shape;
		protected var glow:GlowFilter;
		public var isRandomMovement:Boolean;
		
		public var rect:Rectangle;
		
		public function LifeForm()
		{
			init();
		}
		
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
			rect = new Rectangle(0, 0, radius * 2 + 30, radius * 2 + 30);
			shape = new Shape();
			glow = new GlowFilter(0xFFFFFF * Math.random(), 0.9, 15, 15, 2, 4);
			bitmapData = new BitmapData((radius << 2), (radius << 2), true, 0x000000);
			
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
				rect.width = (radius << 2) + 30;
				rect.height = (radius << 2) + 30;
				changeBitmapData();
			}
		}
		
		public function update():void
		{
			updatePositions();
			grow();
			if (isRandomMovement)
			{
				speedX += (-1 + Math.random() * 2) * 0.1;
				speedY += (-1 + Math.random() * 2) * 0.1;
			}
		}
		
		protected function changeBitmapData():void
		{
			if (isNaN(radius)) return;
			try{
				bitmapData = new BitmapData(rect.width, rect.height, true, 0x000000);
			}
			catch (e:Error)
			{
				bitmapData = new BitmapData(1, 1, true, 0x000000);
			}
			bitmapData.fillRect(rect, 0x00000000);
			shape.graphics.clear();
			shape.graphics.beginFill(color, 1);
			shape.graphics.drawCircle(radius + 15, radius + 15, radius);
			shape.graphics.endFill();
			shape.filters = [ glow ];
			bitmapData.draw(shape);
			//bitmapData.applyFilter(bitmapData, _rect, new Point(), glow);
			//bitmapData.fillRect(_rect, 0xFFFFFF);
		}
		
		public function checkRange(rect:Rectangle):void
		{
			if (x >= rect.width - radius)
			{
				x = rect.width - radius;
				speedX= -speedX
			}
			else if (x <= radius)
			{
				x = radius;
				speedX = speedX;
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
		//protected var friction:Number;
		//internal var isPlayer:Boolean = false;
		//protected var _radius:Number;
		//protected var _speed:Point;
		//protected var _mass:Number;
		//protected var _force:Point;
		//protected var _image:Bitmap;
		//protected var _color:uint;
		//protected var _volume:Number;
		//public var _food:Number;
		//
		//public var isGrow:Boolean;
		//
		//private var _min:uint, _max:uint;
		//
		//[Embed(source="/assets/lifeForm2.png")]
		//protected var image:Class;
		//
		//public function get mass():Number
		//{
			//return _mass;
		//}
		//
		//public function get volume():Number {
			//return _volume;
		//}
		//
		//public function get radius():Number
		//{
			//return _radius;
		//}
		//
		//public function set radius(r:Number):void
		//{
			//_radius = r;
			//_mass = Math.PI * r * r;
			///*_image.width = _radius * 2;
			//_image.x = -r;
			//_image.y = -r;
			//_image.scaleY = _image.scaleX;*/
			//_volume = r * r * Math.PI;
			//redraw();
		//}
		//
		//public function redraw():void
		//{
			//if (isNaN(_radius)) return;
			//graphics.clear();
			//graphics.beginFill(_color);
			//graphics.drawCircle(0, 0, _radius);
			//graphics.endFill();
		//}
		//
		//public function get speed():Point
		//{
			//return _speed;
		//}
		//
		//public function set speed(newSpeed:Point):void
		//{
			//_speed = newSpeed;
		//}
		//
		//public function LifeForm(minColor:uint, maxColor:uint, r:Number = 25, friction:Number = 0.98)
		//{
			//mouseEnabled = false;
			// constructor code
			//_mass = Math.PI * r * r;
			//speed = new Point();
			//_radius = r;
			//_volume = r * r * Math.PI;
			//this.friction = friction;
			//_force = new Point();
			//_color = sumColor(minColor, maxColor);
			//_min = minColor;
			//_max = maxColor;
			//_food = 0;
			//
			//redraw();
			//
			//var blur:BitmapFilter = new GlowFilter(_color, 0.9, 15, 15, 2, 4);
			//filters = [ blur ];
			///*_image = new image();
			//addChild(_image);
			//_image.x = -r;
			//_image.y = -r;
			//_image.width = r * 2;
			//_image.height = r * 2;
			//var colTransf:ColorTransform = new ColorTransform();
			//colTransf.color = _color;
			//_image.transform.colorTransform = colTransf;*/
		//}
		//
		//public function addForce(force:Point):void
		//{
			//_force.x += force.x / _mass;
			//_force.y += force.y / _mass;
			//rotation = angelRadian * 180 / Math.PI;
		//}
		//
		//public function calculate():void
		//{
			//var gradus:Number = this.rotation / 180 * Math.PI;
			//_speed.x += _force.x;
			//_speed.y += _force.y;
			//if (speed.x > 2)
				//speed.x = 2;
			//else if (speed.x < -1.5)
				//speed.x = -2;
			//if (speed.y > 2)
				//speed.y = 2;
			//else if (speed.y < -1.5)
				//speed.y = -2;
			//x += speed.x;
			//y += speed.y;
			//_force.x = 0;
			//_force.y = 0;
			//_speed.x *= friction;
			//_speed.y *= friction;
			//
			//if (_food > 1)
			//{
				//var foodPart:Number = _food - _food * 0.9;
				//_volume += _food - _food * 0.9;
				//_food *= 0.9;
				//radius = Math.sqrt(_volume / Math.PI);
			//}else {
				//_food = 0;
			//}
		///*this.graphics.clear();
		   //this.graphics.beginFill(0xFFFFFF);
		   //var rect:Rectangle = getAABB();
		   //this.graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
		 //this.graphics.endFill();*/
		//}
		//
		//public function calculateColor(player:LifeForm):void
		//{
			//if (isPlayer || player == null)
				//return;
			//var dif:Number = radius - player.radius;
			//var multiplayer:Number;
			//if (player.radius > radius * 2)
				//multiplayer = 1.0;
			//else if (player.radius * 2 < radius)
				//multiplayer = 0.0;
			//else
				//multiplayer = 1.5 - radius / player.radius;
			//var newColor:uint = sumColor(_min, _max, multiplayer, 1 - multiplayer);
			//if (newColor == _color) return;
			///*var newColorTrans:ColorTransform = new ColorTransform();
			//newColorTrans.color = newColor; // 0xB160B4;
			//_image.transform.colorTransform = newColorTrans;*/
			//_color = newColor;
			//redraw();
		//}
		//
		//public function eat(volume:Number):void
		//{
			//_food += volume;
		//}
		//
		//private function sumColor(color1:uint, color2:uint, color1Percent:Number = 0.5, color2Percent:Number = 0.5):uint
		//{
			//var r:Number = Math.min((color1 >> 16) * color1Percent + (color2 >> 16) * color2Percent, 255);
			//var g:Number = Math.min(((color1 & 0x00FF00) >> 8) * color1Percent + ((color2 & 0x00FF00) >> 8) * color2Percent, 255);
			//var b:Number = Math.min((color1 & 0x0000FF) * color1Percent + (color1 & 0x0000FF) * color2Percent, 255);
			//var sum:int = (r << 16) + (g << 8) + b;
			//return sum;
		//}
		//
		//public function getAABB():Rectangle
		//{
			//return getRect(this);
		//}
		//
		//public function detectCollision(lifeForm:LifeForm):Number
		//{
			//if (lifeForm != this)
			//{
				//if (this.hitTestObject(lifeForm))
				//{
					//var distance:Number = Math.sqrt(Math.pow(this.x - lifeForm.x, 2) + Math.pow(this.y - lifeForm.y, 2));
					//if (distance < this.radius + lifeForm.radius)
					//{
						//return distance;
					//}
				//}
			//}
			//return -1;
		//}
		//
		//public static function calculateCollision(obj1:LifeForm, obj2:LifeForm):Number
		//{
			//var distance:Number = obj1.detectCollision(obj2);
			//var S:Number = obj1.radius * obj1.radius * Math.PI;
			//var S2:Number = obj2.radius * obj2.radius * Math.PI;
			//var totalS:Number = S + S2;
			//var atan:Number;
			//if (S > S2)
			//{
				//to do:
				//remove magic numbers
				//if (distance >= 0 && obj1.radius >= distance + obj2.radius)
				//{
					//obj1.radius = Math.sqrt(totalS / Math.PI);
					//return 1;
				//}
				//else if (distance >= 0 && distance < obj1.radius + obj2.radius)
				//{
					//obj2.isGrow = false;
					//atan = Math.atan2(obj1.y - obj2.y, obj1.x - obj2.x);
					//obj2.speed.x += Math.cos(atan)/5;
					//obj2.speed.y += Math.sin(atan)/5;
					//obj1.parent.setChildIndex(obj1, obj1.parent.numChildren - 1);
					//S2 *= 0.9;
					//S = totalS - S2 - S;
					//if (obj2._food > 0) {
						//obj1.eat(obj2._food);
						//obj2._food = 0;
					//}else {
						//obj1.eat(S);
						//obj2.radius = Math.sqrt((S2 - 1) / Math.PI);
					//}
					//obj2.radius = Math.sqrt(S2 / Math.PI);
					//obj1.radius = Math.sqrt(S / Math.PI);
					//push away
					//if(!obj2.isPlayer){
						//obj2.x -= Math.cos(atan);
						//obj2.x -= Math.sin(atan);
						//
						//obj1.speed.x += Math.cos(atan);
						//obj1.speed.x += Math.sin(atan);
					//}
				//}
			//}
			//else
			//{
				//if (distance >= 0 && obj2.radius >= distance + obj1.radius)
				//{
					//obj2.radius = Math.sqrt(totalS / Math.PI);
					//return -1;
				//}
				//else if (distance >= 0 && distance < obj1.radius + obj2.radius)
				//{
					//obj1.isGrow = false;
					//atan = Math.atan2(obj2.y - obj1.y, obj2.x - obj1.x);
					//obj1.speed.x += Math.cos(atan) / 5;
					//obj1.speed.y += Math.sin(atan) / 5;
					//obj2.parent.setChildIndex(obj2, obj2.parent.numChildren - 1);
					//S *= 0.9;
					//S2 = totalS - S - S2;
					//if (obj1._food > 0) {
						//obj2.eat(obj1._food);
						//obj1._food = 0;
					//}else {
						//obj2.eat(S2);
						//obj1.radius = Math.sqrt((S - 1) / Math.PI);
					//}
					//
					//push away
					//if(!obj1.isPlayer){
						//obj1.x -= Math.cos(atan);
						//obj1.y -= Math.sin(atan);
						//
						//obj2.speed.x += Math.cos(atan);
						//obj2.speed.x += Math.sin(atan);
					//}
				//}
			//}
			//return 0;
		//}
	}

}
