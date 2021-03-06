package stringParser.parsers;
import stringParser.core.ILookahead;
import stringParser.core.ParserStorage;

class WhitespaceParser extends AbstractCharacterParser
{
	public static var instance(get, null):WhitespaceParser;
	private static function get_instance():WhitespaceParser{
		if(instance==null){
			instance = new WhitespaceParser();
		}
		return instance;
	}

	public static var WHITESPACE_CHARS:Array<String> = [" ","\n","\r","\t"];



	@:isVar public var characters(default, set):Array<String>;
	private function set_characters(value:Array<String>):Array<String>{
		if(this.characters!=value){
			this.characters = value;
			if(this.characters!=null){
				_charLookup = new Map();
				for(char in this.characters){
					_charLookup.set(char, true);
				}
			}else{
				_charLookup = null;
			}
		}
		return value;
	}

	private var _charLookup:Map<String, Bool>;

	public function new(?characters:Array<String>) {
		super(false);
		this.characters = (characters==null?WHITESPACE_CHARS:characters);
	}
	
	override public function ignore(storage:ParserStorage, packetId:String):Bool {
		return true;
	}

	override public function acceptCharacter(storage:ParserStorage, char:String, packetId:String, lookahead:ILookahead, packetChildren:Int):Array<ICharacterParser>{
		return _charLookup.exists(char)?_selfVector:null;
	}

	override public function parseCharacter(storage:ParserStorage, char:String, packetId:String, lookahead:ILookahead):Bool{
		return false;
	}
}