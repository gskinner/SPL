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
package com.gskinner.spelling {
	
	import flash.net.URLRequest;

	public class WordListEditorLoader extends WordListLoader {
		
		public var _prefixList:Array;
		public var _affixList:Array;
		
	// Constructor
		public function WordListEditorLoader(request:URLRequest=null) {
			super(request);
		}
		
	// Getter / Setters
		public function get prefixList():Array { return _prefixList; }
		public function get affixList():Array { return _affixList; }
		
		public function set prefixList(p_prefixes:Array):void {
			_prefixList = p_prefixes;
		}
		
		public function set affixList(p_affixes:Array):void {
			_affixList = p_affixes;
		}
		
	// Overrride	
		override protected function parseAffixes():void {
			var affixes:Array = parseParams.affixes = [];
			var prefixes:Array = parseParams.prefixes = [];
			var i:uint=parseParams.index;
			
			var list:Array = parseParams.list;
			while (true) {
				var afxCode:String = list[i].substr(0,3);
				if (afxCode == "PFX" || afxCode == "SFX") {
					var afx:String = list[i].substr(4);
					affixes[i] = afx;
					prefixes[i] = (afxCode == "PFX");
					i++;
				} else {
					break;
				}
			}
			parseParams.index = i;
		// ADDED FUNCTIONALITY
			affixList = affixes;
			prefixList = prefixes;
		//
		}
	}
}