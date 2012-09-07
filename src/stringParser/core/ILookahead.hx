package stringParser.core;

/**
 * @author Tom Byrne
 */

interface ILookahead 
{

	public function lookahead(count:Int, includingCurrent:Bool=true):String;
	
}