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
	
	import com.gskinner.text.ITextHighlighterPlugin;
	import com.gskinner.text.ITextHighlighterPluginFactory;
	import com.gskinner.text.TextUtils;
	
	import flash.text.TextField;
	
	/**
	 * The SpellingTextField plugin factory assists with the creation of SpellingTextFieldPlugins.
	 */
	public class SpellingTextFieldPluginFactory implements ITextHighlighterPluginFactory {
		
		/**
		 * Determines if an object contains a TextField instance, which can be highlighted by a
		 * SpellingHighlighter. If found, it creates and returns a SpellingTextFieldPlugin which will be
		 * responsible for highlighting the textField.
		 *
		 * @see com.gskinner.spelling.SpellingTextFieldPlugin
		 * @see com.gskinner.spelling.SpellingHighlighter
		 *
		 * @param target An object containing a TextField. Typically this is a MovieClip, flash component, or flex mx component.
		 * @return a SpellingTextFieldPlugin instance referencing the textField that is found. If none is found, it will return null instead of a plugin instance.
		 */
		public function getPluginInstance(target:Object):ITextHighlighterPlugin {
			var textField:TextField = TextUtils.findType(target, "textField", "numChildren", "getChildAt", TextField) as TextField;
			return textField ? new SpellingTextFieldPlugin(textField) : null;
		}
	}
}