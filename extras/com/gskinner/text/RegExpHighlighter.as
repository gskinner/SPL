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
	
	import flash.events.ErrorEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	/**
	* Applies a highlight effect to specified words in a textfield.
	**/
	public class RegExpHighlighter extends TextHighlighter {
		
		
	// private properties
		protected var _regExp:RegExp;
		protected var currentMatch:Object;
		
	// constructor
		/**
		* Creates a new instance of RegExpHighlighter
		*
		* @param target The target object to apply highlights to. See the target property for more information.
		* @param regExp The RegExp to highlight
		* 
		**/
		public function RegExpHighlighter(target:Object=null,regExp:RegExp=null) {
			_regExp = regExp;
			super(target);
		}
		
		override protected function draw():void {
			if (plugin == null) { return; }
			plugin.clear();
			
			if (!_enabled || !plugin.startDraw()) {
				return;
			}
			
			// isolate the text that's visible:
			var visibleText:StringPosition = plugin.visibleRange;
			var beginIndex:uint = visibleText.beginIndex;
			var endIndex:uint = visibleText.endIndex;
			
			// logic for watching selection:
			var selBeginIndex:uint = plugin.selectionBeginIndex;
			var selEndIndex:uint = plugin.selectionEndIndex;
			var ignoreSel:Boolean = _ignoreSelectedWord && plugin.isFocus;
			
			var l:uint = visibleText.subString.length;
			
			var bi:uint = visibleText.beginIndex;
			var str:String = visibleText.subString;
			
			_regExp.lastIndex = 0;
			var o:Object = _regExp.exec(str);
			var lastIndex:int = _regExp.lastIndex;
			
			while (o != null) {
				currentMatch = o;
				(plugin as RegExpTextFieldPlugin).currentMatch = currentMatch;
				plugin.startDraw();
				plugin.drawHighlight(Math.max(beginIndex,o.index+bi),Math.min(endIndex-1,o.index+o[0].length+bi-1));
				o = (_regExp.global) ? _regExp.exec(str) : null;
				if (o != null && _regExp.lastIndex == lastIndex) { dispatchEvent(new ErrorEvent(ErrorEvent.ERROR)); break; }
				lastIndex = regExp.lastIndex;
			}
		}
		
	// public getter / setters:
		/**
		* The RegExp to highlight.
		**/
		public function get regExp():RegExp {
			return _regExp;
		}
		public function set regExp(value:RegExp):void {
			_regExp = value;
			invalidate();
		}
		
	}
	
}