package stringParser.core;

import stringParser.parsers.ICharacterParser;

interface IInterpretter
{
	function setInputString(string:String):Void;
	function getIterator():StringParserIterator;
	function getResult():Dynamic;
}