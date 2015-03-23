package stringParser;

import stringParser.core.AbstractInterpretter;
import stringParser.core.StringParser;
import stringParser.core.StringParserIterator;
import stringParser.parsers.BracketPairParser;
import stringParser.parsers.ICharacterParser;
import stringParser.parsers.NameValuePairParser;
import stringParser.parsers.QuotedStringParser;



class JsonInterpretter extends AbstractInterpretter
{
	public static var jsonConfig(get, null):Array<ICharacterParser>;
	private static function get_jsonConfig():Array<ICharacterParser>{
		checkInit();
		return _jsonConfig;
	}
	
	public static var objectParser(get, null):BracketPairParser;
	private static function get_objectParser():BracketPairParser{
		checkInit();
		return objectParser;
	}
	public static var arrayParser(get, null):BracketPairParser;
	private static function get_arrayParser():BracketPairParser{
		checkInit();
		return arrayParser;
	}
	public static var stringParser(get, null):QuotedStringParser;
	private static function get_stringParser():QuotedStringParser{
		checkInit();
		return stringParser;
	}
	public static var nameValueParser(get, null):NameValuePairParser;
	private static function get_nameValueParser():NameValuePairParser{
		checkInit();
		return nameValueParser;
	}

	private static function checkInit():Void{
		if(_jsonConfig==null){
			_jsonConfig = [];
			
			objectParser = new BracketPairParser("{","}",null,[","]);
			_jsonConfig.push(objectParser);
			
			arrayParser = new BracketPairParser("[","]",null,[","]);
			_jsonConfig.push(arrayParser);
			
			stringParser = new QuotedStringParser();
			
			nameValueParser = new NameValuePairParser(stringParser,[stringParser,objectParser,arrayParser],":");
			
			objectParser.childParsers = [nameValueParser];
			arrayParser.childParsers = [stringParser,objectParser,arrayParser];
		}
	}


	private static var _jsonConfig:Array<ICharacterParser>;

	private var _nameValueMode:Bool;
	private var _nextPropName:String;

	private var _objectMap:Map<String, Dynamic>;


	public function new(inputString:String=null){
		super(inputString);
		_objectMap = new Map<String, Dynamic>();
	}
	override private function getParserConfig():Array<ICharacterParser>{
		return jsonConfig;
	}

	override private function interpret(id:String, parentId:String, parser:ICharacterParser, strings:Dynamic):Void{
		var value:Dynamic = null;
		
		if (parser == nameValueParser) {
			_nameValueMode = true;
			_objectMap.set(id, _objectMap.get(parentId));
			return;
		}else if (parser == objectParser) {
			value = {};
		}else if (parser == arrayParser) {
			value = [];
		}else if (parser == stringParser) {
			if(_nameValueMode && _nextPropName==null){
				_nextPropName = cast strings;
				return;
			}
			value = strings;
		}
		
		_objectMap.set(id, value);
		if(!_result){
			_result = value;
		}else{
			var parentObject:Dynamic = _objectMap.get(parentId);
			if (_nameValueMode) {
				Reflect.setProperty(parentObject, _nextPropName, value);
				_nameValueMode = false;
				_nextPropName = null;
			}else if(Std.is(parentObject , Array)){
				parentObject.push(value);
			}
		}
	}
}