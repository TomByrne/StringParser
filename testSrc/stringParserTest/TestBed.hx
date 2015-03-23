package stringParserTest;

import flash.display.Sprite;
import stringParser.test.FileStringParserTester;
import stringParser.test.ObjectsEqual;
import stringParser.XmlInterpretter;

import stringParser.JsonInterpretter;
import stringParser.core.StringParser;
import stringParser.core.StringParserIterator;

class TestBed extends Sprite
{
	public static function main():Void {
		new TestBed();
	}
	
	public function new()
	{
		super();
		
		var tester:FileStringParserTester = new FileStringParserTester("JSON", new JsonInterpretter());
		tester.addTestFile("testJs/test1.js", testJs, false);
		tester.running = true;
		
		tester = new FileStringParserTester("XML", new XmlInterpretter());
		tester.addTestFile("testXml/test1.xml", testXml, false);
		tester.running = true;
	}
	
	private function testJs(result:Dynamic, string:String):Bool {
		var haxeVers:Dynamic = haxe.Json.parse(string);
		if (!ObjectsEqual.equal(result, haxeVers)) return false;
		
		#if flash11
			var flashVers:Dynamic = flash.utils.JSON.parse(string);
			if (!ObjectsEqual.equal(result, flashVers)) return false;
		#end
		
		return true;
	}
	
	private function testXml(result:Dynamic, string:String):Bool {
		var haxeVers:Xml = Xml.parse(string);
		if (!ObjectsEqual.equal(result, haxeVers)) return false;
		
		return true;
	}
}