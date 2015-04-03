package stringParser.parsers;
import stringParser.core.ILookahead;

interface ICharacterParser
{
	function acceptCharacter(char:String, packetId:String, lookahead:ILookahead, packetChildren:Int):Array<ICharacterParser>;
	function parseCharacter(char:String, packetId:String, lookahead:ILookahead):Bool;
	function reset():Void;
	function ignore(packetId:String):Bool;
}