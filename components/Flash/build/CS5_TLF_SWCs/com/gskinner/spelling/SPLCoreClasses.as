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
	
	import flash.display.Sprite;
	
	import com.gskinner.text.*;
	import com.gskinner.spelling.*;
	
	// simple component to force import of core spelling dictionary related classes (no UI).
	[IconFile("componentIcon.png")]
	public class SPLCoreClasses extends Sprite {
	
		public function SPLCoreClasses() {
			visible = false;
			
			// com.gskinner.spelling:
			var v02:SpellingDictionary;
			var v03:SpellingDictionaryEvent;
			var v05:SpellingUtils;
			
			// com.gskinner.text:
			var v07:CharacterSet;
			var v08:StringPosition;
			var v09:PluginFactoryDefaults;
			var v10:TLFPluginFactory;
			
		}
	
	}
}