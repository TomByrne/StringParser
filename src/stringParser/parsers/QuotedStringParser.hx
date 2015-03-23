package stringParser.parsers;
import stringParser.core.ILookahead;





class QuotedStringParser extends AbstractCharacterParser
{
	public static var QUOTE_TYPES:Array<String> = ["'",'"'];
	public static inline var ESCAPE_CHAR:String = "\\";

	private static inline var OPEN:String = "open";
	private static inline var TO_IGNORE:String = "toIgnore";
	private static inline var LAST_CHAR:String = "lastChar";
	private static inline var OPENED_QUOTE:String = "openedQuote";

	@:isVar public var openQuoteTypes(default, set):Array<String>;
	private function set_openQuoteTypes(value:Array<String>):Array<String>{
		if(this.openQuoteTypes!=value){
			this.openQuoteTypes = value;
			if(this.openQuoteTypes!=null){
				_openQuoteLookup = new Map();
				for(str in this.openQuoteTypes){
					var char = (str.length>1 ? str.charAt(0) : str);
					_openQuoteLookup.set(char, str);
				}
			}else{
				_openQuoteLookup = null;
			}
		}
		return value;
	}

	@:isVar public var closeQuoteTypes(default, set):Array<String>;
	private function set_closeQuoteTypes(value:Array<String>):Array<String>{
		if(this.closeQuoteTypes!=value){
			this.closeQuoteTypes = value;
			if(this.closeQuoteTypes!=null){
				_closeQuoteLookup = new Map();
				for (str in this.closeQuoteTypes) {
					var char = (str.length>1 ? str.charAt(0) : str);
					_closeQuoteLookup.set(str, str);
				}
			}else{
				_closeQuoteLookup = null;
			}
		}
		return value;
	}

	private var _openQuoteLookup:Map<String, String>;
	private var _closeQuoteLookup:Map<String, String>;

	public var escapeChar:String;

	public function new(openQuoteTypes:Array<String>=null, closeQuoteTypes:Array<String>=null, escapeChar:String = null){
		super();
		
		this.openQuoteTypes = (openQuoteTypes==null?QUOTE_TYPES:openQuoteTypes);
		this.closeQuoteTypes = closeQuoteTypes;
		this.escapeChar = (escapeChar==null?ESCAPE_CHAR:escapeChar);
	}


	override public function acceptCharacter(char:String, packetId:String, lookahead:ILookahead):Array<ICharacterParser>{
		if (!getVar(packetId, OPEN)) {
			var matched:String = doesMatch(_openQuoteLookup, char, lookahead);
			if(matched!=null){
				// first character
				setVar(packetId,OPENED_QUOTE,matched);
				setVar(packetId,OPEN,true);
				setVar(packetId,TO_IGNORE,matched.length);
				return _selfVector;
			}else{
				return null;
			}
		}else if(escapeChar==null || getVar(packetId,LAST_CHAR)!=escapeChar){
			var matched:String;
			if (_closeQuoteLookup != null) {
				matched = doesMatch(_closeQuoteLookup, char, lookahead);
			}else {
				matched = getVar(packetId, OPENED_QUOTE);
				if (lookahead.lookahead(matched.length) != matched) {
					matched = null;
				}
			}
			if(matched!=null){
				setVar(packetId,OPENED_QUOTE,null);
				setVar(packetId,LAST_CHAR,null);
				setVar(packetId,OPEN,false);
				setVar(packetId,TO_IGNORE,matched.length);
				return _selfVector;
			}
		}
		setVar(packetId,LAST_CHAR,char);
		return _selfVector;
	}
	
	function doesMatch(lookup:Map<String, String>, char:String, lookahead:ILookahead):Null<String>
	{
		if (!lookup.exists(char)) {
			return null;
		}else {
			var str = lookup.get(char);
			if (str.length == 1) return str;
			
			return (lookahead.lookahead(str.length) == str ? str : null);
		}
	}

	override public function parseCharacter(char:String, packetId:String, lookahead:ILookahead):Bool {
		var ignore:Null<Int> = getVar(packetId, TO_IGNORE);
		if (ignore != null && ignore > 0) {
			ignore--;
			setVar(packetId,TO_IGNORE,ignore);
			return false;
		}else{
			return true;
		}
	}
}