package stringParser.parsers;
import stringParser.core.ILookahead;





class CharListParser extends AbstractCharacterParser
{
	public static function getCharRanges(uppercase:Bool, lowercase:Bool, numbers:Bool, ?additional:Array<String>):Array<String> {
		var ret = [];
		if (uppercase) ret = ret.concat("abcdefghijklmnopqrstuvwxyz".split(""));
		if (lowercase) ret = ret.concat("ABCDEFGHIJKLMNOPQRSTUVWXYZ".split(""));
		if (numbers) ret = ret.concat("0123456789".split(""));
		if (additional!=null) ret = ret.concat(additional);
		return ret;
	}

	private static inline var COLLECTING:String = "collecting";

	@:isVar public var acceptChars(default, set):Array<String>;
	private function set_acceptChars(value:Array<String>):Array<String>{
		if(this.acceptChars!=value){
			this.acceptChars = value;
			if(this.acceptChars!=null){
				_charLookup = new Map();
				for(char in this.acceptChars){
					_charLookup.set(char, true);
				}
			}else{
				_charLookup = null;
			}
		}
		return value;
	}
	
	public var childParsers:Array<ICharacterParser>;

	private var _charLookup:Map<String, Bool>;

	public function new(acceptChars:Array<String>){
		super();
		
		this.acceptChars = acceptChars;
	}


	override public function acceptCharacter(char:String, packetId:String, lookahead:ILookahead):Array<ICharacterParser> {
		var isCollecting:Bool = getVar(packetId, COLLECTING);
		if (_charLookup.exists(char)) {
			setVar(packetId, COLLECTING, true);
			return _selfVector;
		}else{
			if (isCollecting) {
				return childParsers;
			}else {
				return null;
			}
		}
	}

	override public function parseCharacter(char:String, packetId:String, lookahead:ILookahead):Bool{
		return true;
	}
	
	override private function getChildParsers():Null<Array<ICharacterParser>> {
		return childParsers;
	}
}