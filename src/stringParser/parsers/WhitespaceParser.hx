package stringParser.parsers;
import stringParser.core.ILookahead;

class WhitespaceParser extends AbstractCharacterParser
{
	public static var instance(get, null):WhitespaceParser;
	private static function get_instance():WhitespaceParser{
		if(instance==null){
			instance = new WhitespaceParser();
		}
		return instance;
	}

	public static inline var WHITESPACE_CHARS:Array<String> = [" ","\n","\r","\t"];



	@:isVar public var characters(default, setCharacters):Array<String>;
	private function setCharacters(value:Array<String>):Array<String>{
		if(this.characters!=value){
			this.characters = value;
			if(this.characters!=null){
				_charLookup = new Hash();
				for(char in this.characters){
					_charLookup.set(char, true);
				}
			}else{
				_charLookup = null;
			}
		}
		return value;
	}

	private var _charLookup:Hash<Bool>;

	public function new(?characters:Array<String>) {
		super();
		this.characters = (characters==null?WHITESPACE_CHARS:characters);
	}

	override public function acceptCharacter(char:String, packetId:String, lookahead:ILookahead):Array<ICharacterParser>{
		return _charLookup.exists(char)?_selfVector:null;
	}

	override public function parseCharacter(char:String, packetId:String, lookahead:ILookahead):Bool{
		return false;
	}
}