package stringParser.core;

#if flash
import flash.display.Shape;
import flash.events.Event;
import haxe.Timer;
#elseif (java || js || python)
import haxe.Timer;
#end


import stringParser.parsers.ICharacterParser;

class StringParserIterator
{
	
	private static var asyncHandlers:Array<Void->Void>;

	#if flash
	private static var frameDispatcher:Shape;
	private static function addAsycHandler(func:Void->Void):Void {
		if(frameDispatcher==null){
			frameDispatcher = new Shape();
			frameDispatcher.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			asyncHandlers = [];
		}
		asyncHandlers.push(func);
	}
	private static function onEnterFrame(event:Event):Void{
		for(func in asyncHandlers){
			func();
		}
	}
	#elseif (js || python || java)
	private static var _fps:Float = 30;
	public static function setFPS(fps:Float):Void {
		_fps = fps;
	}
	private static function addAsycHandler(func:Void->Void):Void {
		if(asyncHandlers==null){
			Timer.delay(onFrameTick, Std.int(1000/_fps));
		}
		asyncHandlers.push(func);
	}
	private static function onFrameTick():Void{
		for(func in asyncHandlers){
			func();
		}
		Timer.delay(onFrameTick, Std.int(1000/_fps));
	}
	#end
	
	private static function removeAsycHandler(func:Void->Void):Void{
		if(asyncHandlers!=null){
			asyncHandlers.remove(func);
		}
	}

	/**
	 * In seconds
	 */
	@:isVar public var executionTime(default, set):Float;
	private function set_executionTime(value:Float):Float{
		this.executionTime = value;
		//_executionTimeMilli = Std.int(value * 1000 + 0.5);
		return value;
	}

	@:isVar public var phase1CurrStep(default, null):Int;
	@:isVar public var phase2CurrStep(default, null):Int;
	@:isVar public var phase1Steps(default, null):Int;
	@:isVar public var phase2Steps(default, null):Int;

	public var stringParser(get, null):StringParser;
	private function get_stringParser():StringParser{
		return _stringParser;
	}

	//private var _executionTimeMilli:Int;

	private var _stringParser:StringParser;
	private var _func:String->String->String->ICharacterParser->Dynamic->Void;
	private var _start:Null<Void->Void>;
	private var _finish:Null<Void->Void>;
	//private var _additionalParams:Array<Dynamic>;
	//private var _params:Array<Dynamic>;

	private var _state:Int = 0;// 0 = before start, 1 = phase 1, 2 = phase 2, 3 = finished

	private var _phase2Id:String;

	private var _asyncCompleteHandler:Void->Void;

	public function new(parser:StringParser, func:String->String->String->ICharacterParser->Dynamic->Void, ?start:Void->Void, ?finish:Void->Void/*, ?additionalParams:Array<Dynamic>*/){
		_stringParser = parser;
		_func = func;
		_start = start;
		_finish = finish;
		//_additionalParams = additionalParams;
		
		//_params = [null,null,null];
		/*if(additionalParams!=null){
			_params = _params.concat([]);
		}*/
	}
	private function reset():Void{
		_state = 0;
		phase1CurrStep = 0;
		phase2CurrStep = 0;
		phase1Steps = 0;
		phase2Steps = 0;
	}

	public function iterateSynchronous():Void{
		if (_state == 3) reset();
		if(_state>0){
			throw "iteration has already begun";
		}
		
		if (_start != null)_start();
		
		// Phase 1
		phase1Steps = _stringParser.totalSteps;
		while(_stringParser.progress<_stringParser.totalSteps){
			_stringParser.parseStep();
		}
		phase1CurrStep = _stringParser.totalSteps;
		
		
		// Phase 2
		phase2Steps = _stringParser.totalPackets;
		var i:Int=0;
		var id:String = _stringParser.firstPacketId;
		while(i<_stringParser.totalPackets){
			var parentId:String = _stringParser.getParent(id);
			var key:String = _stringParser.getKey(id);
			_func(id, parentId, key, _stringParser.getParser(id), _stringParser.getStrings(id));
			
			var newId :String = _stringParser.getFirstChild(id);
			if(newId==null){
				newId = getNext(id);
			}
			id = newId;
			++i;
		}
		phase2CurrStep = _stringParser.totalPackets;
		_state = 3;
		if (_finish != null) _finish();
	}
	
	#if (flash || js || java || python)
	public function iterateAsynchronous(onComplete:Void->Void):Void {
		if (_state == 3) reset();
		if(_state>0){
			throw "iteration has already begun";
		}
		_asyncCompleteHandler = onComplete;
		
		if (_start != null)_start();
		
		// Phase 1
		phase1Steps = _stringParser.totalSteps;
		phase1CurrStep = _stringParser.progress;
		
		if(phase1Steps>phase1CurrStep){
			_state = 1;
			addAsycHandler(doPhase1Loop);
			doPhase1Loop();
		}else{
			startPhase2();
		}
	}

	private function doPhase1Loop():Void{
		var start:Float = Timer.stamp();
		while(Timer.stamp()-start<this.executionTime){
			_stringParser.parseStep();
			phase1CurrStep = _stringParser.progress;
			if(_stringParser.totalSteps==phase1CurrStep){
				removeAsycHandler(doPhase1Loop);
				startPhase2(start);
			}
		}
	}
	private function startPhase2(?start:Float):Void{
		_state = 2;
		phase2CurrStep = 0;
		_phase2Id = _stringParser.firstPacketId;
		addAsycHandler(doPhase2LoopDef);
		doPhase2Loop(start);
	}
	private function doPhase2LoopDef():Void {
		doPhase2Loop();
	}
	private function doPhase2Loop(?start:Float):Void{
		if(Math.isNaN(start) || start==null){
			start = Timer.stamp();
		}
		while(Timer.stamp()-start<this.executionTime){
			
			var parentId:String = _stringParser.getParent(_phase2Id);
			var key = _stringParser.getKey(_phase2Id);
			_func(_phase2Id, parentId, key, _stringParser.getParser(_phase2Id), _stringParser.getStrings(_phase2Id));
			var newId :String = _stringParser.getFirstChild(_phase2Id);
			if(newId==null){
				newId = getNext(_phase2Id);
			}
			_phase2Id = newId;
			
			++phase2CurrStep;
			if (_stringParser.totalPackets == phase2CurrStep) {
				_state = 3;
				removeAsycHandler(doPhase2LoopDef);
				if (_finish != null) _finish();
				_asyncCompleteHandler();
			}
		}
	}
	#end

	private function getNext(id:String):String{
		var newId:String = _stringParser.getNextSibling(id);
		if(newId!=null)return newId;
		
		var parentId:String = _stringParser.getParent(id);
		if(parentId!=null){
			return getNext(parentId);
		}else{
			return null;
		}
	}
}