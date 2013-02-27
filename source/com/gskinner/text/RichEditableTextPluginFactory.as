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
	
	import spark.components.RichEditableText;
	
	/**
	 * The RichEditableText plugin factory assists with the creation of RichEditableTextPlugins.
	 */
	public class RichEditableTextPluginFactory implements ITextHighlighterPluginFactory {
		
		/**
		 * Determines if an object contains a RichEditableText instance, which can be highlighted by a
		 * TextHighlighter. If found, it creates and returns a RichEditableTextPlugin which will be
		 * responsible for highlighting the RichEditableText instance.
		 *
		 * @see com.gskinner.text.RichEditableTextPlugin
		 * @see com.gskinner.text.TextHighlighter
		 *
		 * @param target An object containing a RichEditableText instance. Typically this is a MovieClip, or flex spark component.
		 * @return a RichEditableTextPlugin instance referencing the RichEditableText instance that is found. If none is found, it will return null instead of a plugin instance.
		 */
		public function getPluginInstance(target:Object):ITextHighlighterPlugin {
			var richText:RichEditableText = TextUtils.findType(target, "textDisplay", "numElements", "getElementAt", RichEditableText) as RichEditableText;
			return richText?new RichEditableTextPlugin(richText):null;
		}
	}
}