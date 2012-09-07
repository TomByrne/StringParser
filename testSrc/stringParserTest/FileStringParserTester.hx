package stringParserTest;
import flash.events.Event;
import flash.net.URLLoader;
import flash.net.URLRequest;
import stringParser.core.IInterpretter;

class FileStringParserTester extends StringParserTester
{


	public function new(name:String, interpretter:IInterpretter){
		super(name, interpretter);
	}


	override public function addTest(fileUrl:String, testFunc:Dynamic->String->Bool, runAsynchronous:Bool = true):Void {
		var fileInput:URLLoader = new URLLoader(new URLRequest(fileUrl));
		fileInput.addEventListener(Event.COMPLETE, function(e:Event) {
			var fileInput:URLLoader = cast e.target;
			_addTest(fileInput.data, testFunc, runAsynchronous);
		});
	}
	private function _addTest(string:String, testFunc:Dynamic->String->Bool, runAsynchronous:Bool = true):Void {
		super.addTest(string, testFunc, runAsynchronous);
	}
	
}