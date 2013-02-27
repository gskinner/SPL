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
package com.gskinner.text {
	
	import com.gskinner.spelling.*;
	import com.gskinner.text.*;
	
	/**
	 * Used to define which plugin factories TextHighlighter uses when attempting to find text to spell check and/or highlight.
	 * The PluginFactoryDefaults are only used when a TextHighlighter is not provided a specific PluginFactory.
	 */
	public class PluginFactoryDefaults {
		
		/**
		 * The default factories to use when searching for editable text fields or components. The defaults will depend on
		 * what your current SPL implementation is targeting. Multiple PluginFactories can be specified, only the first
		 * applicable factory will be used, so it's a good idea to list them with the most likely factory first.
		 */
		public static var factories:Array = [new SpellingTextFieldPluginFactory()];
		
		//Un-comment to add in RichEditableText support
		//public static var factories:Array = [new SpellingRichEditableTextPluginFactory(), new SpellingTextFieldPluginFactory()];
		
		//Un-comment to add in TLFTextField support
		//public static var factories:Array = [new SpellingTLFPluginFactory(), new SpellingTextFieldPluginFactory()];
	}
}