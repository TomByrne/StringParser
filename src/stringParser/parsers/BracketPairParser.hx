package stringParser.parsers;
import stringParser.core.ILookahead;



class BracketPairParser extends AbstractCharacterParser
{
	private static inline var STATE:String = "state";
	private static inline var PROGRESS:String = "progress";
	private static inline var LAST_CHAR:String = "lastChar";



	
	public var childParsers:Array<ICharacterParser>;
	private var allChildParsers:Array<ICharacterParser>;

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

	override public function acceptCharacter(char:String, packetId:String, lookahead:ILookahead, packetChildren:Int):Array<ICharacterParser>{
		var prog:Int = getVar(packetId, PROGRESS);
		var state:State = getVar(packetId, STATE);
		
		if (state == Closed) {
			return null;
			
		}else if(state==null){
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
			
			var doEscape:Bool = (escapeChar != null && getVar(packetId, LAST_CHAR) == escapeChar);
			switch(state) {
				case Opening:
					if (prog == openBracket.length) {
						newState = Children;
						if(childParsers!=null){
							lastChar = null;
							ret = getAllChildParsers();
						}else {
							ret = _selfVector;
						}
					}
				case Children:
					ret = getAllChildParsers();
					if(!doEscape){
						if (matchToken(char, lookahead, closeBracket)) {
							newState = Closing;
							ret = _selfVector;
							
						}else if (childSeperators != null) {
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
						setVar(packetId, STATE, Closed);
						setVar(packetId, PROGRESS, null);
						setVar(packetId, LAST_CHAR, null);
						return finishedParsers;
					}
				case Closed: // already dealt with at top
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
	function getAllChildParsers(){
		if(allChildParsers == null){
			if (childParsers != null) {
				allChildParsers = childParsers.concat(finishedParsers);
			}else {
				allChildParsers = finishedParsers;
			}
		}
		return allChildParsers;
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
	Closed;
}