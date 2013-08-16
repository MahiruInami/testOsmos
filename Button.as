package
{
	import flash.display.SimpleButton;
	import flash.display.Shape;
	
	
	
	/**
	 * ...
	 * @author 123
	 */
	public class Button extends SimpleButton
	{
		private var upColor:uint = 0xFFCC00;
		private var overColor:uint = 0xCCFF00;
		private var downColor:uint = 0x00CCFF;
		private var size:uint = 150;
		
		
		public function Button(text:String = "Button")
		{
			downState = new ButtonDisplayState(downColor, size);
			overState = new ButtonDisplayState(overColor, size);
			upState = new ButtonDisplayState(upColor, size);
			hitTestState = new ButtonDisplayState(upColor, size);
			
			useHandCursor = true;
		}
	}
}
	import flash.display.Sprite;
	import flash.text.TextFormat;
	import flash.text.TextField;
	
	class ButtonDisplayState extends Sprite
	{
		private var bgColor:uint;
		private var size:uint;
		private var _text:TextField;
		
		public function ButtonDisplayState(bgColor:uint, size:uint)
		{
			this.bgColor = bgColor;
			this.size = size;
			draw();
		}
		
		private function draw():void
		{
			graphics.beginFill(bgColor);
			graphics.drawRoundRect(0, 0, size, size / 4, size / 4, size / 4);
			graphics.endFill();
			
			_text = new TextField();
			_text.textColor = 0x000000;
			_text.text = "Start game";
			var format:TextFormat = new TextFormat();
			format.size = 18;
			_text.setTextFormat(format);
			_text.width = _text.textWidth + 5;
			_text.x = this.width / 2 - _text.width / 2;
			_text.y = this.height / 4;
			addChild(_text);
		}
	}