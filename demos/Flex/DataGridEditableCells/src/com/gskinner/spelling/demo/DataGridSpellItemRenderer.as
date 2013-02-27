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
package com.gskinner.spelling.demo {
	
	import com.gskinner.spelling.SpellingHighlighter;
	
	import flash.events.Event;
	
	import mx.controls.dataGridClasses.DataGridItemRenderer;
	
	public class DataGridSpellItemRenderer extends DataGridItemRenderer {
		
		protected var spellingHighlighter:SpellingHighlighter;
		
		override public function validateProperties():void {
			super.validateProperties();
			if (!visible) { spellingHighlighter.enabled = false; }
			spellingHighlighter.update();
		}
		
		override public function validateDisplayList():void {
			super.validateDisplayList();
			spellingHighlighter.update();
		}
		
		public function DataGridSpellItemRenderer() {
			super();
			spellingHighlighter = new SpellingHighlighter(this);
			addEventListener(Event.ADDED, onAdded, false, 0, true);
			addEventListener(Event.REMOVED, onRemoved, false, 0, true);
		}
		
		protected function onAdded(p_event:Event):void {
			spellingHighlighter.enabled = true;
		}
		
		protected function onRemoved(p_event:Event):void {
			spellingHighlighter.enabled = false;
		}
		
		override public function set visible(value:Boolean):void {
			super.visible = value;
			spellingHighlighter.enabled = visible;
			spellingHighlighter.update();
		}
		
		override public function move(x:Number, y:Number):void {
			spellingHighlighter.update();
			super.move(x,y);
		}
		
		// Consider adding setActualSize override
	}
	
}