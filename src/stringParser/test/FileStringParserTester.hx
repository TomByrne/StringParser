package stringParser.test;
import flash.events.Event;
import flash.net.URLLoader;
import flash.net.URLRequest;
import stringParser.core.IInterpreter;

class FileStringParserTester<ResultType> extends StringParserTester<ResultType>
{


	public function new(name:String, interpreter:IInterpreter){
		super(name, interpreter);
	}


	public function addTestFile(fileUrl:String, testFunc:Dynamic->String->Bool, runAsynchronous:Bool = true):Void {
		var fileInput:URLLoader = new URLLoader(new URLRequest(fileUrl));
		fileInput.addEventListener(Event.COMPLETE, function(e:Event) {
			var fileInput:URLLoader = cast e.target;
			addTest(fileInput.data, testFunc, runAsynchronous);
		});
	}
	
}