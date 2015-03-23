package stringParser.test;
import flash.events.Event;
import flash.net.URLLoader;
import flash.net.URLRequest;
import stringParser.core.IInterpretter;

class FileStringParserTester extends StringParserTester
{


	public function new(name:String, interpretter:IInterpretter){
		super(name, interpretter);
	}


	public function addTestFile(fileUrl:String, testFunc:Dynamic->String->Bool, runAsynchronous:Bool = true):Void {
		var fileInput:URLLoader = new URLLoader(new URLRequest(fileUrl));
		fileInput.addEventListener(Event.COMPLETE, function(e:Event) {
			var fileInput:URLLoader = cast e.target;
			addTest(fileInput.data, testFunc, runAsynchronous);
		});
	}
	
}