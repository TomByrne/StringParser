package stringParser.parsers;
import stringParser.core.ILookahead;



class BracketPairParser extends AbstractCharacterParser
{
	private static inline var STATE:String = "state";
	private static inline var PROGRESS:String = "progress";
	private static inline var LAST_CHAR:String = "lastChar";




	public var childParsers:Array<ICharacterParser>;

	public var openBracket:String;
	public var closeBracket:String;
	public var escapeChar:String;
	public var childSeperators:Array<String>;

	public function new(openBracket:String = null, closeBracket:String = null, escapeChar:String = null, childSeperators:Array<String> = null) {
		super();
		this.openBracket = openBracket;
		this.closeBracket = closeBracket;
		this.escapeChar = escapeChar;
		this.childSeperators = childSeperators;
	}

	override public function acceptCharacter(char:String, packetId:String, lookahead:ILookahead):Array<ICharacterParser>{
		var prog:Int = getVar(packetId, PROGRESS);
		var state:State = getVar(packetId, STATE);
		
		if(state==null){
			if(matchToken(char,lookahead,openBracket)){
				// first character
				setVar(packetId,STATE,Opening);
				setVar(packetId,PROGRESS,1);
				return _selfVector;
			}else{
				return null;
			}
		}else {
			var newState:State = null;
			var ret:Array<ICharacterParser> = null;
			var lastChar:String = char;
			
			var doEscape:Bool = (escapeChar != null || getVar(packetId, LAST_CHAR) == escapeChar);
			switch(state) {
				case Opening:
					if (prog == openBracket.length) {
						newState = Children;
						if(childParsers!=null){
							lastChar = null;
							ret = childParsers;
						}else {
							ret = _selfVector;
						}
					}
				case Children:
					ret = childParsers;
					if(!doEscape){
						if (matchToken(char, lookahead, closeBracket)) {
							newState = Closing;
							ret = _selfVector;
						}
						if (childSeperators != null) {
							for(childSeperator in childSeperators){
								if(matchToken(char, lookahead, childSeperator)){
									ret = _selfVector;
									break;
								}
							}
						}
					}
				case Closing:
					if (prog == openBracket.length) {
						setVar(packetId, STATE, null);
						setVar(packetId, PROGRESS, null);
						setVar(packetId, LAST_CHAR, null);
						return null;
					}
			}
			if (newState!=null) {
				setVar(packetId, LAST_CHAR, null);
				setVar(packetId, STATE, newState);
				setVar(packetId, PROGRESS, 1);
			}else {
				setVar(packetId,LAST_CHAR,lastChar);
				setVar(packetId, PROGRESS, prog+1);
			}
			return ret;
		}
	}

	override public function parseCharacter(char:String, packetId:String, lookahead:ILookahead):Bool {
		if (childParsers != null) return false;
		
		return getVar(packetId, STATE)==Children;
	}
	
	override private function getChildParsers():Null<Array<ICharacterParser>> {
		return childParsers;
	}
}
private enum State {
	Opening;
	Children;
	Closing;
}