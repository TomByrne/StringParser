package stringParser.parsers;
import haxe.ds.StringMap;
import stringParser.core.ILookahead;
import stringParser.core.ParserStorage;



class NumberParser extends AbstractCharacterParser
{
	private static inline var PROGRESS:String = "progress";
	private static inline var COLLECTING:String = "collecting";
	
	private static var startCharMap:StringMap<Bool>;
	private static var charMap:StringMap<Bool>;
	private static var hexCharMap:StringMap<Bool>;
	
	private static function checkMap() {
		if (charMap == null) {
			startCharMap = new StringMap();
			charMap = new StringMap();
			hexCharMap = new StringMap();
			for (char in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]) {
				charMap.set(char, true);
				hexCharMap.set(char, true);
				startCharMap.set(char, true);
			}
			for (char in ["A", "B", "C", "D", "E", "F", "a", "b", "c", "d", "e", "f"]) {
				hexCharMap.set(char, true);
			}
			charMap.set(".", true);
		}
	}


	private var hex:Bool;
	private var _charMap:StringMap<Bool>;

	public function new(hex:Bool) {
		super();
		checkMap();
		this.hex = hex;
		_charMap = ( hex ? hexCharMap : charMap );
	}

	override public function acceptCharacter(storage:ParserStorage, char:String, packetId:String, lookahead:ILookahead, packetChildren:Int):Array<ICharacterParser>{
		var prog:Dynamic = storage.getVar(this, packetId, PROGRESS);
		var progress:Int = ( prog==null ? 0 : cast prog);
		var isCollecting:Bool = ( prog==null ? false : storage.getVar(this, packetId, COLLECTING));
		
		if (progress == 0) {
			var incCurrent = true;
			if (char == "-") {
				if (!hex) {
					char = lookahead.lookahead(1, false);
				}else{
					incCurrent = false;
				}
			}
			if (hex) {
				var start = lookahead.lookahead(3, incCurrent);
				if (start.indexOf("0x") == 0 && _charMap.exists(start.charAt(2))) {
					storage.setVar(this, packetId, PROGRESS, 1);
					storage.setVar(this, packetId, COLLECTING, true);
					return _selfVector;
				}else {
					return null;
				}
			}
			if (startCharMap.exists(char)) {
				storage.setVar(this, packetId, PROGRESS, 1);
				storage.setVar(this, packetId, COLLECTING, true);
				return _selfVector;
			}else {
				return null;
			}
		}
		if (hex && progress == 1) {
			if (char != "x") throw "Something went wrong in the NumberParser";
			storage.setVar(this, packetId, PROGRESS, progress+1);
			return _selfVector;
		}
		if (_charMap.exists(char)) {
			// still parsing
			storage.setVar(this, packetId, PROGRESS, progress+1);
			return _selfVector;
		}else {
			// finished
			storage.setVar(this, packetId, PROGRESS, null);
			if(isCollecting){
				storage.setVar(this, packetId, COLLECTING, false);
				return finishedParsers;
			}else{
				return null;
			}
		}
	}

	override public function parseCharacter(storage:ParserStorage, char:String, packetId:String, lookahead:ILookahead):Bool {
		return true;
	}
	
	override private function getChildParsers():Null<Array<ICharacterParser>> {
		return finishedParsers;
	}
}