/*
* SPL; AS3 Spelling library for Flash and the Flex SDK. 
* 
* Copyright (c) 2013 gskinner.com, inc.
* 
* Permission is hereby granted, free of charge, to any person
* obtaining a copy of this software and associated documentation
* files (the "Software"), to deal in the Software without
* restriction, including without limitation the rights to use,
* copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the
* Software is furnished to do so, subject to the following
* conditions:
* 
* The above copyright notice and this permission notice shall be
* included in all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
* OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
* NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
* HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
* OTHER DEALINGS IN THE SOFTWARE.
*/
package com.gskinner.spelling.wordlisteditor.events {
	
	import flash.events.Event;
	
	public class WordListManagerEvent extends Event {
		
		public static const IMPORTEE_SELECTED:String = 'importSelected';
		public static const LIST_DATA_COMLETE:String = 'listDataComplete';
		public static const OPEN_OFFICE_SELECTED:String = 'openOfficeSelected';
		public static const OPEN_OFFICE_AFFIX_COMLETE:String = 'openOfficeAffixComplete';
			
		protected var _affArray:Array;
		protected var _wordArray:Array;
		
		public function WordListManagerEvent(p_type:String, p_wordArray:Array=null, p_affArray:Array=null) {
			super(p_type);
			if (p_wordArray) { _wordArray = p_wordArray; }
			if (p_affArray) { _affArray = p_affArray; }
		}
		
		public function set wordArray(p_wordArray:Array):void { _wordArray = p_wordArray; }
		public function set affArray(p_affArray:Array):void { _affArray = p_affArray; }
		public function get wordArray():Array { return _wordArray; }
		public function get affArray():Array { return _affArray; }
	}	
}
