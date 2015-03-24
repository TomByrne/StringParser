package stringParser.test;
import stringParser.core.IInterpretter;
import stringParser.core.StringParserIterator;

class StringParserTester<ResultType>
{

	@:isVar public var running(default, set):Bool;
	private function set_running(value:Bool):Bool{
		if(this.running!=value){
			this.running = value;
			
			if(value && _tests.length>0){
				runTest(0);
			}
		}
		return value;
	}

	private var _tests:Array<TestInfo<ResultType>>;

	private var _currentIndex:Int;
	private var _currentTest:TestInfo<ResultType>;

	private var _name:String;
	private var _interpretter:IInterpretter;

	public function new(name:String, interpretter:IInterpretter) {
		_name = name;
		_interpretter = interpretter;
		_tests = [];
	}

	public function addTest(string:String, testFunc:Dynamic->String->Bool, runAsynchronous:Bool=true):Void{
		_tests.push({string:string,testFunc:testFunc,runAsynchronous:runAsynchronous});
		if(this.running && _tests.length==1){
			runTest(0);
		}
	}

	private function runTest(index:Int):Void{
		_currentIndex = index;
		_currentTest = _tests[_currentIndex];
		
		startTest(_currentTest);
	}

	private function startTest(test:TestInfo<ResultType>):Void{
		var iterator:StringParserIterator = _interpretter.getIterator();
		
		_interpretter.setInputString(test.string);
		
		if (test.runAsynchronous) {
			iterator.iterateAsynchronous(function():Void { onTestFinished(test); } );
		}else {
			iterator.iterateSynchronous();
			onTestFinished(test);
		}
	}
	private function onTestFinished(test:TestInfo<ResultType>):Void {
		var success = test.testFunc(_interpretter.getResult(), test.string);
		
		if (success) {
			trace(_name+" " + _currentIndex+": Success");
		}else{
			trace(_name+" " + _currentIndex+": Failed");
		}
		if (_currentIndex+1 < _tests.length ) runTest(_currentIndex + 1);
		else trace(_name+" Tests Finished");
	}
}
typedef TestInfo<ResultType> = {
	public var string:String;
	public var testFunc:ResultType->String->Bool;
	public var runAsynchronous:Bool;
}