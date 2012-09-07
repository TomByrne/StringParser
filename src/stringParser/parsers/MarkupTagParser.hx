package stringParser.parsers;
import stringParser.core.ILookahead;

/**
 * ...
 * @author Tom Byrne
 */

class MarkupTagParser  extends AbstractCharacterParser
{
	public static var TAG_OPEN_START:String = "<";
	public static var TAG_OPEN_END:String = ">";
	public static var TAG_EMPTY_END:String = "/>";
	public static var TAG_CLOSE_START:String = "</";
	public static var TAG_CLOSE_END:String = ">";
	
	
	private static inline var STATE:String = "state";
	private static inline var PROGRESS:String = "progress";

	public var openParsers:Array<ICharacterParser>;
	public var childParsers:Array<ICharacterParser>;
	public var closeParsers:Array<ICharacterParser>;
	
	public var openingStart:String;
	public var openingEnd:String;
	public var emptyEnd:String;
	public var closingStart:String;
	public var closingEnd:String;

	private var _nameParserVector:Array<ICharacterParser>;

	private var _firstParserVector:Array<ICharacterParser>;
	private var _lastParserVector:Array<ICharacterParser>;

	public var seperator:String;

	public function new(?openParsers:Array<ICharacterParser>, ?childParsers:Array<ICharacterParser>, ?closeParsers:Array<ICharacterParser>,
						?openingStart:String, ?openingEnd:String, ?emptyEnd:String, ?closingStart:String, ?closingEnd:String) {
		super();
		this.openParsers = openParsers;
		this.childParsers = childParsers;
		this.closeParsers = closeParsers;
		
		this.openingStart = openingStart==null?TAG_OPEN_START:openingStart;
		this.openingEnd = openingEnd==null?TAG_OPEN_END:openingEnd;
		this.emptyEnd = emptyEnd==null?TAG_EMPTY_END:emptyEnd;
		this.closingStart = closingStart==null?TAG_CLOSE_START:closingStart;
		this.closingEnd = closingEnd==null?TAG_CLOSE_END:closingEnd;
	}
	
	override public function acceptCharacter(char:String, packetId:String, lookahead:ILookahead):Array<ICharacterParser>{
		var prog:Int = getVar(packetId, PROGRESS);
		var state:State = getVar(packetId, STATE);
		if (state == null) {
			if(matchToken(char, lookahead, openingStart)){
				// first character
				setVar(packetId, STATE, OpeningStart);
				setVar(packetId, PROGRESS, 1);
				return _selfVector;
			}else{
				return null;
			}
		}else {
			var newState:State = null;
			var ret:Array<ICharacterParser> = null;
			switch(state) {
				case OpeningStart:
					if (prog == openingStart.length) {
						newState = OpeningMid;
						ret = (openParsers==null?_selfVector:openParsers);
					}else {
						ret = _selfVector;
					}
				case OpeningMid:
					if (matchToken(char, lookahead, emptyEnd)) {
						newState = EmptyEnd;
						ret = _selfVector;
					}else if (matchToken(char, lookahead, openingEnd)) {
						newState = OpeningEnd;
						ret = _selfVector;
					}
				case OpeningEnd:
					if (prog == openingEnd.length) {
						newState = Children;
						ret = (childParsers==null?_selfVector:childParsers);
					}else {
						ret = _selfVector;
					}
				case EmptyEnd:
					if (prog < emptyEnd.length) {
						ret = _selfVector;
					}
				case Children:
					if (matchToken(char, lookahead, closingStart)) {
						newState = ClosingStart;
						ret = _selfVector;
					}
				case ClosingStart:
					if (prog == closingStart.length) {
						newState = ClosingMid;
						ret = (closeParsers==null?_selfVector:closeParsers);
					}else {
						ret = _selfVector;
					}
				case ClosingMid:
					if (matchToken(char, lookahead, closingEnd)) {
						newState = ClosingEnd;
						ret = _selfVector;
					}
				case ClosingEnd:
					if (prog == closingEnd.length) {
						setVar(packetId, STATE, null);
						setVar(packetId, PROGRESS, null);
						return null;
					}else {
						ret = _selfVector;
					}
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
private enum State{
	OpeningStart;
	OpeningMid;
	OpeningEnd;
	EmptyEnd;
	Children;
	ClosingStart;
	ClosingMid;
	ClosingEnd;
}