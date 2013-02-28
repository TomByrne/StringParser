package stringParser.parsers;
import stringParser.core.ILookahead;





class QuotedStringParser extends AbstractCharacterParser
{
	public static var QUOTE_TYPES:Array<String> = ["'",'"'];
	public static inline var ESCAPE_CHAR:String = "\\";

	private static inline var OPEN:String = "open";
	private static inline var IGNORE_NEXT:String = "ignoreNext";
	private static inline var LAST_CHAR:String = "lastChar";
	private static inline var OPENED_QUOTE:String = "openedQuote";

	@:isVar public var quoteTypes(default, set):Array<String>;
	private function set_quoteTypes(value:Array<String>):Array<String>{
		if(this.quoteTypes!=value){
			this.quoteTypes = value;
			if(this.quoteTypes!=null){
				_quoteLookup = new Map();
				for(char in this.quoteTypes){
					_quoteLookup.set(char, true);
				}
			}else{
				_quoteLookup = null;
			}
		}
		return value;
	}

	private var _quoteLookup:Map<String, Bool>;

	public var escapeChar:String;

	public function new(quoteTypes:Array<String>=null, escapeChar:String = null){
		super();
		
		this.quoteTypes = (quoteTypes==null?QUOTE_TYPES:quoteTypes);
		this.escapeChar = (escapeChar==null?ESCAPE_CHAR:escapeChar);
	}


	override public function acceptCharacter(char:String, packetId:String, lookahead:ILookahead):Array<ICharacterParser>{
		if(!getVar(packetId,OPEN)){
			if(_quoteLookup.exists(char)){
				// first character
				setVar(packetId,OPENED_QUOTE,char);
				setVar(packetId,OPEN,true);
				setVar(packetId,IGNORE_NEXT,true);
				return _selfVector;
			}else{
				return null;
			}
		}else if(escapeChar==null || getVar(packetId,LAST_CHAR)!=escapeChar){
			if(char==getVar(packetId,OPENED_QUOTE)){
				setVar(packetId,OPENED_QUOTE,null);
				setVar(packetId,LAST_CHAR,null);
				setVar(packetId,OPEN,false);
				setVar(packetId,IGNORE_NEXT,true);
				return _selfVector;
			}
		}
		setVar(packetId,LAST_CHAR,char);
		return _selfVector;
	}

	override public function parseCharacter(char:String, packetId:String, lookahead:ILookahead):Bool{
		if(getVar(packetId,IGNORE_NEXT)){
			setVar(packetId,IGNORE_NEXT,false);
			return false;
		}else{
			return true;
		}
	}
}