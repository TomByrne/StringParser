package stringParser.parsers;
import stringParser.core.ILookahead;
import stringParser.core.ParserStorage;

interface ICharacterParser
{
	function acceptCharacter(storage:ParserStorage, char:String, packetId:String, lookahead:ILookahead, packetChildren:Int):Array<ICharacterParser>;
	function parseCharacter(storage:ParserStorage, char:String, packetId:String, lookahead:ILookahead):Bool;
	//function reset():Void;
	function ignore(storage:ParserStorage, packetId:String):Bool;
}