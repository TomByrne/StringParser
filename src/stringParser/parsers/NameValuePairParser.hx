package stringParser.parsers;
import stringParser.core.ILookahead;



class NameValuePairParser extends AbstractCharacterParser
{
	private static inline var STATE:String = "state";
	private static inline var PROGRESS:String = "progress";


	public var nameParser(default, set_nameParser):ICharacterParser;
	private function set_nameParser(value:ICharacterParser):ICharacterParser{
		if(this.nameParser!=value){
			this.nameParser = value;
			_nameParserVector[0] = value;
		}
		return value;
	}

	public var valueParsers(default, set_valueParsers):Array<ICharacterParser>;
	private function set_valueParsers(value:Array<ICharacterParser>):Array<ICharacterParser>{
		if(this.valueParsers!=value){
			this.valueParsers = value;
			if(this.nameFirst){
				_lastParserVector = value;
			}else{
				_firstParserVector = value;
			}
		}
		return value;
	}

	public var nameFirst(default, set_nameFirst):Bool;
	private function set_nameFirst(value:Bool):Bool{
		if(this.nameFirst!=value){
			this.nameFirst = value;
			if(this.nameFirst){
				_firstParserVector = _nameParserVector;
				_lastParserVector = this.valueParsers;
			}else{
				_firstParserVector = this.valueParsers;
				_lastParserVector = _nameParserVector;
			}
		}
		return value;
	}

	private var _nameParserVector:Array<ICharacterParser>;

	private var _firstParserVector:Array<ICharacterParser>;
	private var _lastParserVector:Array<ICharacterParser>;

	public var seperator:String;

	public function new(nameParser:ICharacterParser = null, ?valueParsers:Array<ICharacterParser>, ?seperator:String) {
		super();
		_nameParserVector = [];
		this.nameFirst = true;
		this.nameParser = nameParser;
		this.valueParsers = valueParsers;
		this.seperator = seperator;
	}

	override public function acceptCharacter(char:String, packetId:String, lookahead:ILookahead):Array<ICharacterParser>{
		
		var state:State = getVar(packetId, STATE);
		var prog:Int = getVar(packetId, PROGRESS);
		
		if (state == null) {
			setVar(packetId,STATE,First);
			setVar(packetId,PROGRESS,1);
			return _firstParserVector;
		}else {
			var newState:State = null;
			var ret:Array<ICharacterParser> = null;
			switch(state) {
				case First:
					if (matchToken(char, lookahead, seperator)) {
						newState = Seperator;
						ret = _selfVector;
					}
				case Seperator:
					if (prog == seperator.length) {
						newState = Last;
						ret = _lastParserVector;
					}else {
						ret = _selfVector;
					}
				case Last:
					setVar(packetId,STATE,null);
					setVar(packetId, PROGRESS, null);
					return null;
					
			}
			if (newState!=null) {
				setVar(packetId, STATE, newState);
				setVar(packetId, PROGRESS, 1);
			}else {
				setVar(packetId, PROGRESS, prog+1);
			}
			return ret;
		}
	}

	override public function parseCharacter(char:String, packetId:String, lookahead:ILookahead):Bool{
		return false;
	}
}
private enum State {
	First;
	Seperator;
	Last;
}