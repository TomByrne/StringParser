package stringParser.core;

import stringParser.parsers.ICharacterParser;



class AbstractInterpreter implements IInterpreter
{

	public function getResult():Dynamic{
		return _result;
	}
	public function getIterator():StringParserIterator{
		return _iterator;
	}

	public var inputString(get, set):String;
	private function get_inputString():String{
		return _stringParser.inputString;
	}
	private function set_inputString(value:String):String{
		//_iterator.reset();
		_stringParser.inputString = value;
		return value;
	}
	
	private var _result:Dynamic;

	private var _stringParser:StringParser;
	private var _iterator:StringParserIterator;

	public function new(inputString:String){
		_stringParser = new StringParser(null, getParserConfig());
		_iterator = new StringParserIterator(_stringParser, interpret, start, finish);
		this.inputString = inputString;
	}
	
	public function setInputString(string:String):Void {
		this.inputString = string;
	}

	private function getParserConfig():Array<ICharacterParser>{
		return null;
	}


	private function start():Void{
		
	}


	private function interpret(id:String, parentId:String, key:String, parser:ICharacterParser, strings:Dynamic):Void{
		
	}


	private function finish():Void{
		
	}
}