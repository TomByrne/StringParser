package stringParser.parsers;
import stringParser.core.ILookahead;



class AbstractCharacterParser implements ICharacterParser
{
	private var _selfVector:Array<ICharacterParser>;

	private var _varStorage:Map<String, Map<String, Dynamic>>;
	private var _isResetting:Bool;

	public function new(){
		
		_selfVector = [];
		_selfVector.push(this);
	}

	public function acceptCharacter(char:String, packetId:String, lookahead:ILookahead):Array<ICharacterParser>
	{
		return null;
	}

	public function parseCharacter(char:String, packetId:String, lookahead:ILookahead):Bool
	{
		return false;
	}
	
	private function matchToken(char:String, lookahead:ILookahead, token:String):Bool {
		return (token != null && ((token.length == 1 && char == token) || lookahead.lookahead(token.length) == token));
	}

	private function setVar(packetId:String, name:String, value:Dynamic):Void{
		if(_varStorage==null){
			_varStorage = new Map();
		}
		var storage:Map<String, Dynamic> = _varStorage.get(name);
		if(storage==null){
			storage = new Map<String, Dynamic>();
			_varStorage.set(name, storage);
		}
		storage.set(packetId, value);
	}
	private function getVar(packetId:String, name:String):Dynamic{
		if(_varStorage==null || !_varStorage.exists(name)){
			return null;
		}else{
			return _varStorage.get(name).get(packetId);
		}
		
	}
	
	public function reset():Void {
		if (_isResetting) return;
		_isResetting = true;
		_varStorage = null;
		var childParsers = getChildParsers();
		if(childParsers!=null){
			for (parser in childParsers) {
				parser.reset();
			}
		}
		_isResetting = false;
	}
	
	private function getChildParsers():Null<Array<ICharacterParser>> {
		return null;	
	}
}