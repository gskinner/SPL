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
	
	import com.gskinner.text.RichEditableTextPlugin;
	
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	
	import spark.components.RichEditableText;
	
	/**
	 * The SpellingRichEditableText plugin defines the methods needed to provide text highlighting capabilities
	 * specific to spell-checking to RichEditableText components in the Flex 4 "spark" component set.
	 */
	public class SpellingRichEditableTextPlugin extends RichEditableTextPlugin implements ISpellingHighlighterPlugin {
		
		/** @private */
		protected var _underlinePattern:BitmapData;
		
		/**
		 * Create an instance of a SpellingRichEditableTextPlugin. This is done automatically by the SpellingRichEditableTextPluginFactory
		 * when a component containing a RichEditableText instance is highlighted using the SpellingHighlighter class.
		 *
		 * @see com.gskinner.spelling.SpellingHighlighter SpellingHighlighter
		 * @param textField The RichEditableText instance to highlight
		 */
		public function SpellingRichEditableTextPlugin(textDisplay:RichEditableText) {
			super(textDisplay);
		}
		
		/** @inheritDoc */
		public function set underlinePattern(value:BitmapData):void {
			_underlinePattern = value;
		}
		
		/** @private */
		override protected function drawRect(x:Number,y:Number,width:Number,height:Number,ascent:Number,descent:Number,type:uint=3):void {
			var bmpd:BitmapData = _underlinePattern != null?_underlinePattern:SpellingHighlighter.defaultUnderlinePattern;
			var baselineY:Number = y+height-descent+1; //1 to offset
			
			canvas.transform.colorTransform = colorTransform;
			canvas.graphics.beginBitmapFill(bmpd, new Matrix(1,0,0,1,x,baselineY));
			canvas.graphics.drawRect(x,baselineY,width,bmpd.height);
		}
	}
}