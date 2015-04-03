package stringParser.parsers;
import stringParser.core.ILookahead;



class NameValuePairParser extends AbstractCharacterParser
{
	private static inline var STATE:String = "state";
	private static inline var PROGRESS:String = "progress";


	@:isVar public var nameParser(default, set):ICharacterParser;
	private function set_nameParser(value:ICharacterParser):ICharacterParser{
		if(this.nameParser!=value){
			this.nameParser = value;
			_nameParserVector = ( value==null ? finishedParsers : [value].concat(finishedParsers));
			if(this.nameFirst){
				_firstParserVector = _nameParserVector;
			}else{
				_lastParserVector = _nameParserVector;
			}
		}
		return value;
	}

	@:isVar public var valueParsers(default, set):Array<ICharacterParser>;
	private function set_valueParsers(value:Array<ICharacterParser>):Array<ICharacterParser>{
		if(this.valueParsers!=value){
			this.valueParsers = value;
			_valueParserVector = ( value==null ? finishedParsers : value.concat(finishedParsers));
			if(this.nameFirst){
				_lastParserVector = _valueParserVector;
			}else{
				_firstParserVector = _valueParserVector;
			}
		}
		return value;
	}

	@:isVar public var nameFirst(default, set):Bool;
	private function set_nameFirst(value:Bool):Bool{
		if(this.nameFirst!=value){
			this.nameFirst = value;
			if(this.nameFirst){
				_firstParserVector = _nameParserVector;
				_lastParserVector = _valueParserVector;
			}else{
				_firstParserVector = _valueParserVector;
				_lastParserVector = _nameParserVector;
			}
		}
		return value;
	}

	private var _nameParserVector:Array<ICharacterParser>;
	private var _valueParserVector:Array<ICharacterParser>;

	private var _firstParserVector:Array<ICharacterParser>;
	private var _lastParserVector:Array<ICharacterParser>;
	private var _allParsers:Array<ICharacterParser>;

	public var seperator:String;

	public function new(nameParser:ICharacterParser = null, ?valueParsers:Array<ICharacterParser>, ?seperator:String) {
		super();
		_nameParserVector = finishedParsers;
		_valueParserVector = finishedParsers;
		this.nameFirst = true;
		this.nameParser = nameParser;
		this.valueParsers = valueParsers;
		this.seperator = seperator;
	}

	override public function acceptCharacter(char:String, packetId:String, lookahead:ILookahead, packetChildren:Int):Array<ICharacterParser>{
		
		var state:State = getVar(packetId, STATE);
		var prog:Int = getVar(packetId, PROGRESS);
		
		if (state == null || packetChildren==0) {
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
					return packetChildren < 2 ? _lastParserVector : finishedParsers;
					
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
	
	override private function getChildParsers():Null<Array<ICharacterParser>> {
		if (_allParsers == null) {
			_allParsers = _firstParserVector.concat(_lastParserVector);
		}
		return _allParsers;
	}
}
private enum State {
	First;
	Seperator;
	Last;
}