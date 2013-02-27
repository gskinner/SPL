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
	
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	public class RegExpTextFieldPlugin extends TextFieldPlugin {
		
		protected var highlightsPool:Array;
		
		public function RegExpTextFieldPlugin(textField:TextField) {
			super(textField);
			
			highlightsPool = [];
		}
		
		public var currentMatch:Object;
		
		override protected function drawRect(x:Number,y:Number,width:Number,height:Number,ascent:Number,descent:Number,type:uint=3):void {
			var highlight:RegExpHighlight = createHighlight();
			canvas.addChild(highlight);
			highlight.setSize(width,height,type);
			highlight.x = x;
			highlight.y = y+height-ascent;
			//highlight.match = currentMatch;
		}
		
		override public function clear():void {
			canvas.graphics.clear();
			while (canvas.numChildren > 0) {
				var child:RegExpHighlight = canvas.removeChildAt(0) as RegExpHighlight;
				if (child) { highlightsPool.push(child); }
			}
		}
		
		protected function createHighlight():RegExpHighlight {
			if (highlightsPool.length) { 
				return highlightsPool.pop() as RegExpHighlight;
			}
			
			return new RegExpHighlight();
		}
			
	}
}