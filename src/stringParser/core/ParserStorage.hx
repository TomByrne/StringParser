package stringParser.core;
import stringParser.parsers.ICharacterParser;

class ParserStorage
{
	private var _varStorage:Map<ICharacterParser, Map<String, Map<String, Dynamic>>>;

	public function new() 
	{
		_varStorage = new Map();
	}
	

	public function setVar(from:ICharacterParser, packetId:String, name:String, value:Dynamic):Void{
		var parserStorage:Map<String, Map<String, Dynamic>> = _varStorage.get(from);
		if(parserStorage==null){
			parserStorage = new Map();
			_varStorage.set(from, parserStorage);
		}
		var storage:Map<String, Dynamic> = parserStorage.get(name);
		if(storage==null){
			storage = new Map();
			parserStorage.set(name, storage);
		}
		if(value == null){
			storage.remove(packetId);
		}else {
			storage.set(packetId, value);
		}
	}
	public function getVar(from:ICharacterParser, packetId:String, name:String):Dynamic {
		var parserStorage:Map<String, Map<String, Dynamic>> = _varStorage.get(from);
		if(parserStorage==null){
			return null;
		}else{
			if(!parserStorage.exists(name)){
				return null;
			}else{
				return parserStorage.get(name).get(packetId);
			}
		}
		
	}
	
	public function ignore(packetId:String):Bool {
		return false;
	}
	
	public function reset():Void {
		_varStorage = new Map();
	}
	
}