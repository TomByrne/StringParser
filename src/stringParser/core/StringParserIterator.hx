package stringParser.core;

#if flash
import flash.display.Shape;
import flash.events.Event;
#end


import stringParser.parsers.ICharacterParser;
import haxe.Timer;

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
	#else
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
	public var executionTime(default, setExecutionTime):Float;
	private function setExecutionTime(value:Float):Float{
		this.executionTime = value;
		//_executionTimeMilli = Std.int(value * 1000 + 0.5);
		return value;
	}

	public var phase1CurrStep(default, null):Int;
	public var phase2CurrStep(default, null):Int;
	public var phase1Steps(default, null):Int;
	public var phase2Steps(default, null):Int;

	public var stringParser(getStringParser, null):StringParser;
		private function getStringParser():StringParser{
		return _stringParser;
	}

	//private var _executionTimeMilli:Int;

	private var _stringParser:StringParser;
	private var _func:String->String->ICharacterParser->Dynamic->Void;
	//private var _additionalParams:Array<Dynamic>;
	//private var _params:Array<Dynamic>;

	private var _state:Int = 0;// 0 = before start, 1 = phase 1, 2 = phase 2, 3 = finished

	private var _phase2Id:String;

	private var _asyncCompleteHandler:Void->Void;

	public function new(stringParser:StringParser, func:String->String->ICharacterParser->Dynamic->Void/*, ?additionalParams:Array<Dynamic>*/){
		_stringParser = stringParser;
		_func = func;
		//_additionalParams = additionalParams;
		
		//_params = [null,null,null];
		/*if(additionalParams!=null){
			_params = _params.concat([]);
		}*/
	}
	public function reset():Void{
		_state = 0;
		phase1CurrStep = 0;
		phase2CurrStep = 0;
		phase1Steps = 0;
		phase2Steps = 0;
	}

	public function iterateSynchronous():Void{
		if(_state>0){
			throw "iteration has already begun";
		}
		
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
			/*_params[0] = id;
			_params[1] = parentId;
			_params[2] = _stringParser.getParser(id);
			_params[3] = _stringParser.getStrings(id);
			_func.apply(null,_params);*/
			_func(id, parentId, _stringParser.getParser(id), _stringParser.getStrings(id));
			
			var newId :String = _stringParser.getFirstChild(id);
			if(newId==null){
				newId = getNext(id);
			}
			id = newId;
			++i;
		}
		phase2CurrStep = _stringParser.totalPackets;
		
		_state = 3;
	}

	public function iterateAsynchronous(onComplete:Void->Void):Void{
		if(_state>0){
			throw "iteration has already begun";
		}
		_asyncCompleteHandler = onComplete;
		
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
			/*_params[0] = _phase2Id;
			_params[1] = parentId;
			_params[2] = _stringParser.getParser(_phase2Id);
			_params[3] = _stringParser.getStrings(_phase2Id);
			_func.apply(null,_params);*/
			_func(_phase2Id, parentId, _stringParser.getParser(_phase2Id), _stringParser.getStrings(_phase2Id));
			
			var newId :String = _stringParser.getFirstChild(_phase2Id);
			if(newId==null){
				newId = getNext(_phase2Id);
			}
			_phase2Id = newId;
			
			++phase2CurrStep;
			if(_stringParser.totalPackets==phase2CurrStep){
				removeAsycHandler(doPhase2LoopDef);
				_asyncCompleteHandler();
			}
		}
	}

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