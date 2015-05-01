package stringParser.parsers;
import stringParser.core.ILookahead;
import stringParser.core.ParserStorage;





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
	private static inline var FINISHED:String = "finished";

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

	@:isVar public var stopChildrenChars(default, set):Array<String>;
	
	private function set_stopChildrenChars(value:Array<String>):Array<String>{
		if(this.stopChildrenChars!=value){
			this.stopChildrenChars = value;
			if(this.stopChildrenChars!=null){
				_stopCharLookup = new Map();
				for(char in this.stopChildrenChars){
					_stopCharLookup.set(char, true);
				}
			}else{
				_stopCharLookup = null;
			}
		}
		return value;
	}
	
	@:isVar public var childParsers(get, set):Array<ICharacterParser>;
	function get_childParsers():Array<ICharacterParser>{
		return childParsers;
	}
	function set_childParsers(value:Array<ICharacterParser>):Array<ICharacterParser> {
		allChildParsers = null;
		return childParsers = value;
	}
	
	override function set_finishedParsers(value:Array<ICharacterParser>):Array<ICharacterParser> {
		allChildParsers = null;
		return super.set_finishedParsers(value);
	}
	
	public var maxChildren:Int;
	private var allChildParsers:Array<ICharacterParser>;
	

	private var _charLookup:Map<String, Bool>;
	private var _stopCharLookup:Map<String, Bool>;

	public function new(acceptChars:Array<String>, maxChildren:Int = -1, stopChildrenChars:Array<String>=null){
		super();
		
		this.acceptChars = acceptChars;
		this.maxChildren = maxChildren;
		this.stopChildrenChars = stopChildrenChars;
	}


	override public function acceptCharacter(storage:ParserStorage, char:String, packetId:String, lookahead:ILookahead, packetChildren:Int):Array<ICharacterParser> {
		if (storage.getVar(this, packetId, FINISHED)) {
			if ((_stopCharLookup!=null && _stopCharLookup.exists(char)) || (maxChildren != -1 && packetChildren >= maxChildren)) {
				// stop searching for children
				return null;
			}else {
				// keep looking for children
				return getAllChildParsers();
			}
		}
		
		var isCollecting:Bool = storage.getVar(this, packetId, COLLECTING);
		if (_charLookup.exists(char)) {
			storage.setVar(this, packetId, COLLECTING, true);
			return _selfVector;
		}else{
			if (isCollecting) {
				storage.setVar(this, packetId, FINISHED, true);
				return getAllChildParsers();
			}else {
				return null;
			}
		}
	}
	
	inline function getAllChildParsers(){
		if(allChildParsers == null){
			if (childParsers != null) {
				allChildParsers = childParsers.concat(finishedParsers);
			}else {
				allChildParsers = finishedParsers;
			}
		}
		return allChildParsers;
	}

	override public function parseCharacter(storage:ParserStorage, char:String, packetId:String, lookahead:ILookahead):Bool{
		return true;
	}
	
	override private function getChildParsers():Null<Array<ICharacterParser>> {
		return childParsers;
	}
}