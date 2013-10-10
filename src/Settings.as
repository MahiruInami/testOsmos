package  
{
	/**
	 * ...
	 * @author 123
	 */
	public class Settings 
	{
		private var _minColor:uint, _maxColor:uint, _playerColor:uint, _enemyNumber:uint;
		private var _width:uint, _height:uint;
		private static var settings : Settings = new Settings();
		
		public function get minColor():uint { return _minColor; }
		public function get maxColor():uint { return _maxColor; }
		public function get playerColor():uint { return _playerColor; }
		public function get enemyNumber():uint { return _enemyNumber; }
		
		public function Settings() 
		{
			if(settings) throw new Error("Singleton and can only be accessed through Singleton.getInstance()"); 
			_width = 1200;
			_height = 800;
			_minColor = 0x0000FF;
			_maxColor = 0xFF0000;
			_playerColor = 0x00FF00;
			_enemyNumber = 120;
		}
		
		public static function getSettings() : Settings{
            return settings;
        }

		public function parseConfig(data:String):void {
			var string:String = data;
			var i:int, j:int;
			//trace(e.target.data.user);
			//trace(string);
			//find user settings
			var regExp:RegExp = new RegExp("user: {[^}]*");
			var userSettings:Array = string.match(regExp);
			var params:Array;
			var values:Array;
			for (i = 0; i < userSettings.length; i++) {
				//find color settings
				regExp = /color:\s[^\]]*/i;
				params = userSettings[i].match(regExp);
				for (j = 0; j < params.length; j++) {
					//take parameters
					regExp = /(\.|\d)+/g;
					values = params[j].match(regExp);
					_playerColor = (0xFF0000 * Number(values[0])) + (0x00FF00 * Number(values[1])) + (0x0000FF * Number(values[2]));
				}
			}
			
			//find enemy setings
			regExp = /enemy:\s{[^}]*/;
			userSettings = string.match(regExp);
			for (i = 0; i < userSettings.length; i++) {
				//find color settings
				regExp = /color\d:\s[^\]]*/g;
				params = userSettings[i].match(regExp);
				for (j = 0; j < params.length; j++) {
					//take parameters
					regExp = /\d\.\d/g;
					values = params[j].match(regExp);
					if(j == 0)
					_minColor = (0xFF0000 * Number(values[0])) + (0x00FF00 * Number(values[1])) + (0x0000FF * Number(values[2]));
					else
					_maxColor = (0xFF0000 * Number(values[0])) + (0x00FF00 * Number(values[1])) + (0x0000FF * Number(values[2]));
				}
				//find enemy number
				regExp = /enemyNumber:\s\d*/g;
				params = userSettings[i].match(regExp);
				trace("enemy");
				for (j = 0; j < params.length; j++) {
					//take parameters
					regExp = /\d+/g;
					values = params[j].match(regExp);
					_enemyNumber = values[0];
				}
			}
			trace(_playerColor);
			trace(_minColor);
			trace(_maxColor);
			trace(_enemyNumber);
		}
		
	}

}