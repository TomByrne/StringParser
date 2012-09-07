package stringParser;

import stringParser.core.AbstractInterpretter;
import stringParser.parsers.ICharacterParser;
import stringParser.parsers.MarkupTagParser;
import stringParser.parsers.BracketPairParser;
import stringParser.parsers.NameValuePairParser;



class XmlInterpretter extends AbstractInterpretter
{
	public static var xmlConfig(get_xmlConfig, null):Array<ICharacterParser>;
	private static function get_xmlConfig():Array<ICharacterParser>{
		checkInit();
		return _xmlConfig;
	}
	
	public static var declarationParser(get_declarationParser, null):BracketPairParser;
	private static function get_declarationParser():BracketPairParser{
		checkInit();
		return declarationParser;
	}
	
	public static var nodeParser(get_nodeParser, null):MarkupTagParser;
	private static function get_nodeParser():MarkupTagParser{
		checkInit();
		return nodeParser;
	}
	
	public static var commentParser(get_commentParser, null):BracketPairParser;
	private static function get_commentParser():BracketPairParser{
		checkInit();
		return commentParser;
	}
	
	public static var attPairParser(get_attPairParser, null):NameValuePairParser;
	private static function get_attPairParser():NameValuePairParser{
		checkInit();
		return attPairParser;
	}
	
	public static var attNameParser(get_attNameParser, null):NameValuePairParser;
	private static function get_attNameParser():NameValuePairParser{
		checkInit();
		return attNameParser;
	}

	private static function checkInit():Void{
		if(_xmlConfig==null){
			_xmlConfig = [];
			
			declarationParser = new BracketPairParser("<?xml", "?>");
			_xmlConfig.push(declarationParser);
			
			nodeParser = new MarkupTagParser();
			_xmlConfig.push(nodeParser);
			
			commentParser = new BracketPairParser("<!--", "-->");
			
			//attNameParser
			
			//attPairParser = new NameValuePairParser(nameParser:ICharacterParser = null, ?valueParsers:Array<ICharacterParser>, "=");
		}
	}


	private static var _xmlConfig:Array<ICharacterParser>;

	private var _nameValueMode:Bool;
	private var _nextPropName:String;

	private var _objectMap:Hash<Dynamic>;


	public function new(inputString:String=null){
		super(inputString);
		_objectMap = new Hash();
	}
	override private function getParserConfig():Array<ICharacterParser>{
		return xmlConfig;
	}

	override private function interpret(id:String, parentId:String, parser:ICharacterParser, strings:Dynamic):Void{
		var value:Dynamic = null;
		
		if (parser == nodeParser) {
			//value = Xml.createElement();
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