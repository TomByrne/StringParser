package stringParser.core;

import stringParser.parsers.ICharacterParser;
import stringParser.parsers.WhitespaceParser;

class StringParser implements ILookahead
{
	@:isVar public var inputString(default, set):String;
	private function set_inputString(value:String):String{
		if(this.inputString!=value){
			reset();
			this.inputString = value;
			init();
		}
		return value;
	}

	@:isVar public var config(default, set):Array<ICharacterParser>;
	private function set_config(value:Array<ICharacterParser>):Array<ICharacterParser>{
		if(this.config!=value){
			reset();
			this.config = value;
			init();
		}
		return value;
	}

	@:isVar public var trimWhitespace(default, set):Bool;
	private function set_trimWhitespace(value:Bool):Bool{
		if(this.trimWhitespace!=value){
			reset();
			this.trimWhitespace = value;
			if(value && _whitespaceParser==null){
				_whitespaceParser = WhitespaceParser.instance;
			}
			init();
		}
		return value;
	}


	@:isVar public var totalSteps(default, null):Int;
	@:isVar public var progress(default, null):Int;


	public var firstPacketId(getFirstPacketId, null):String;
		private function getFirstPacketId():String{
		return _firstPacketId;
	}
	public var totalPackets(getTotalPackets, null):Int;
		private function getTotalPackets():Int{
		return _totalPackets;
	}

	private var _idsAtIndex:Int = -1;

	private var _firstPacketId:String;
	private var _totalPackets:Int = -1;
	private var _strings:Hash<String>;
	private var _stringArrays:Hash<Array<String>>;
	private var _parents:Hash<String>;
	private var _firstChild:Hash<String>;
	private var _lastChild:Hash<String>;
	private var _nextSibling:Hash<String>;
	private var _parsers:Hash<ICharacterParser>;

	private var _currentId:String;
	private var _currentParser:ICharacterParser;
	private var _finishedOnCurrent:Bool;
	private var _startCurrentString:Int = -1;

	private var _currentOptions:Array<ICharacterParser>;
	//private var _openParsers:Array<ICharacterParser>;
	private var _openParserIds:Array<String>;

	private var _whitespaceParser:WhitespaceParser;

	public function new(inputString:String = null, config:Array<ICharacterParser> = null, trimWhitespace:Bool = true) {
		totalSteps = -1;
		this.inputString = inputString;
		this.config = config;
		this.trimWhitespace = trimWhitespace;
	}

	public function lookahead(count:Int, includingCurrent:Bool=true):String {
		if (includingCurrent) {
			return inputString.substr(progress, count);
		}else{
			return inputString.substr(progress+1, count);
		}
	}

	private function reset():Void{
		if(this.inputString!=null && this.config!=null){
			progress = -1;
			totalSteps = -1;
			_startCurrentString = -1;
			_currentId = null;
			_totalPackets = -1;
			_firstPacketId = null;
			_idsAtIndex = -1;
			
			//_openParsers = null;
			_currentOptions = null;
			_strings = null;
			_parsers = null;
			_parents = null;
			_firstChild = null;
			_lastChild = null;
			_nextSibling = null;
		}
	}
	private function init():Void{
		if(this.inputString!=null && this.config!=null){
			progress = 0;
			_idsAtIndex = 0;
			totalSteps = this.inputString.length;
			_currentId = null;
			_totalPackets = 0;
			
			//_openParsers = new Vector();
			_openParserIds = [];
			_currentOptions = this.config;
			_strings = new Hash();
			_stringArrays = new Hash();
			_parsers = new Hash();
			_parents = new Hash();
			_firstChild = new Hash();
			_lastChild = new Hash();
			_nextSibling = new Hash();
		}
	}

	public function parseStep():Void{
		var char:String = this.inputString.charAt(progress);
		var newParserId:String;
		var newParser:ICharacterParser;
		
		if((_currentParser==null || _finishedOnCurrent) && skipWhitespsace(char)){
			// ignore
		}else{
			//var nextId:String = getNextId();
			if(_currentParser==null){
				newParserId = findCurrentParser(char,null,_currentOptions);
				newParser = _getParser(newParserId);
				if(newParser==null){
					throw "No initial parser found";
				}
				_firstPacketId = newParserId;
				setCurrentParser(newParser,newParserId);
				_finishedOnCurrent = false;
			}else{
				if((newParserId = testParser(char,_currentParser,_currentId,_getParent(_currentId),true))!=null){
					newParser = _getParser(newParserId);
					if(newParser!=_currentParser){
						//nextId = getNextId();
						setCurrentParser(newParser,newParserId);
						_finishedOnCurrent = false;
					}
				}else if(!skipWhitespsace(char)){
				storeCurrentString();
				var firstTry:Bool = true;
				
				var oldCurrId:String = _currentId;
				
				var i:Int=0;
				while(i<_openParserIds.length && (_finishedOnCurrent || firstTry)){
					firstTry = false;
					
					var parentId:String = _openParserIds[_openParserIds.length-1-i];
					var parentParser:ICharacterParser = _getParser(parentId);
					newParserId = testParser(char,parentParser,parentId,_getParent(parentId),true);
					
					if(newParserId!=null){
						newParser = _getParser(newParserId);
						
						//_openParsers.splice(_openParsers.length-1-i,i+1);
						_openParserIds.splice(_openParserIds.length-1-i,i+1);
						
						if(newParser==parentParser){
							_currentId = parentId;
							_currentParser = newParser;
						}else{
							setCurrentParser(newParser,newParserId);
							addToList(newParserId,parentId);
						}
						_finishedOnCurrent = false;
						break;
					}else{
						_finishedOnCurrent = true;
					}
					++i;
				}
				}else{
				_finishedOnCurrent = true;
				}
			}
			if(_currentParser!=null && !_finishedOnCurrent){
				if(_currentParser.parseCharacter(char,_currentId, this)){
					if(_startCurrentString==-1){
						_startCurrentString = progress;
					}
				}else{
					storeCurrentString();
				}
			}
		}
		
		++progress;
		_idsAtIndex = 0;
	}

	private function getNextId():String{
		return progress+" "+_idsAtIndex;
	}

	private function setCurrentParser(parser:ICharacterParser, id:String):Void{
		_currentParser = parser;
		_currentId = id;
		_parsers.set(id, parser);
		
		_idsAtIndex++;
	}
	private function addToList(id:String, parentId:String):Void{
		if(parentId!=null){
			var lastChild:Dynamic = _getLastChild(parentId);
			if(lastChild==null){
				_firstChild.set(parentId, id);
			}else{
				_nextSibling.set(lastChild, id);
			}
			_lastChild.set(parentId, id);
		}
		++_totalPackets;
	}

	private function skipWhitespsace(char:String):Bool{
		return (this.trimWhitespace && _whitespaceParser.acceptCharacter(char,null,this)!=null);
	}
	private function storeCurrentString():Void{
		if(_startCurrentString!=-1){
			var string:String = this.inputString.substring(_startCurrentString, progress);
			
			if (_stringArrays.exists(_currentId)) {
				var array = _stringArrays.get(_currentId);
				array.push(string);
			}else if (_strings.exists(_currentId)) {
				var otherStr = _strings.get(_currentId);
				_strings.remove(_currentId);
				_stringArrays.set(_currentId, [otherStr, string]);
			}else {
				_strings.set(_currentId, string);
			}
			_startCurrentString = -1;
		}
	}

	private function findCurrentParser(char:String, parentId:String, inParsers:Array<ICharacterParser>):String{
		var nextId:String = getNextId();
		var childId:String;
		for(parser in inParsers){
			if((childId = testParser(char,parser,nextId,parentId,false))!=null){
				if(childId==nextId){
					if(parentId!=_currentId){
						addToList(parentId,_getParent(parentId));
					}
					_parents.set(childId, parentId);
					addToList(childId,parentId);
				}
				return childId;
			}
		}
		return null;
	}

	private function testParser(char:String, parser:ICharacterParser, id:String, parentId:String, allowOptionRecover:Bool):String
	{
		var newOptions:Array<ICharacterParser> = parser.acceptCharacter(char,id,this);
		
		if(newOptions==null && _currentOptions!=null && allowOptionRecover){
			newOptions = _currentOptions;
		}
		if(newOptions!=null){
			if(_getParser(id)==null){
				_parsers.set(id, parser);
				_parents.set(id, parentId);
				++_idsAtIndex;
			}
			
			if(newOptions.length>1 || newOptions[0]!=parser){
				_currentOptions = newOptions;
				if(skipWhitespsace(char)){
					return null;
				}else{
					var index:Int = _openParserIds.length;
					var childId:String = findCurrentParser(char, id, newOptions);
					if(childId!=null){
						storeCurrentString();
						_openParserIds.insert(index, id);
					}
					return childId;
				}
			}else{
				_currentOptions = null;
				return id;
			}
		}else{
			_currentOptions = null;
			return null;
		}
	}


	private inline function _getParent(packetId:String):String{
		return _parents.get(packetId);
	}
	private inline function _getFirstChild(packetId:String):String{
		return _firstChild.get(packetId);
	}
	private inline function _getNextSibling(packetId:String):String{
		return _nextSibling.get(packetId);
	}
	private inline function _getLastChild(packetId:String):String{
		return _lastChild.get(packetId);
	}
	private inline function _getParser(packetId:String):ICharacterParser{
		return _parsers.get(packetId);
	}

	
	public function getParent(packetId:String):String{
		return _getParent(packetId);
	}
	public function getFirstChild(packetId:String):String{
		return _getFirstChild(packetId);
	}
	public function getNextSibling(packetId:String):String{
		return _getNextSibling(packetId);
	}
	public function getParser(packetId:String):ICharacterParser{
		return _getParser(packetId);
	}
	public function getStrings(packetId:String):Dynamic {
		var array = _stringArrays.get(packetId);
		if (array!=null) {
			return array;
		}else{
			return _strings.get(packetId);
		}
	}
}