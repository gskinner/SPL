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

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextLineMetrics;
	import flash.ui.ContextMenu;

	/**
	 * The text component has changed.
	 *
	 * @eventType flash.events.Event.CHANGE
	 */
	[Event(name="change", type="flash.events.Event")]
	/**
	 * The text component has received focus.
	 *
	 * @eventType flash.events.FocusEvent.FOCUS_IN
	 */
	[Event(name="focusIn", type="flash.events.FocusEvent")]
	/**
	 * The text component has lost focus.
	 *
	 * @eventType flash.events.FocusEvent.FOCUS_OUT
	 */
	[Event(name="focusOut", type="flash.events.FocusEvent")]
	
	/**
	 * The TextField plugin defines the methods needed to provide text highlighting capabilities
	 * to "classic" TextFields and TextField-based components.
	 */
	public class TextFieldPlugin extends EventDispatcher implements ITextHighlighterPlugin {
		
		/** @private */
		protected var textField:TextField;

		/** @private */
		protected var yOffset:Number=0;

		/** @private */
		protected var canvas:Sprite;
		
		/** @private */
		protected var _color:uint = 0xFFFF0000;
		
		/** @private */
		protected var colorTransform:ColorTransform;

		/**
		 * Create an instance of a TextFieldPlugin. This is done automatically by the TextFieldPluginFactory
		 * when a component containing a TextField is highlighted using the TextHighlighter class.
		 *
		 * @see com.gskinner.text.TextHighlighter TextHighlighter
		 * @param textField The TextField instance to highlight
		 */
		public function TextFieldPlugin(textField:TextField) {
			this.textField = textField;
			createHilightCanvas();
		}
		
		/** @inheritDoc */
		public function getCharIndexFromEvent(event:MouseEvent):int {
			return getCharIndexAtPoint(event.stageX, event.stageY);
		}
		
		/** @inheritDoc */
		public function get contextMenu():ContextMenu {
			return textField ? textField.contextMenu as ContextMenu : null;
		}
		/** @private */
		public function set contextMenu(value:ContextMenu):void {
			if (textField) {
				textField.contextMenu = value;
			}
		}

		/** @inheritDoc */
		public function set color(value:uint):void {
			_color = value;
			
			var a:Number = _color>>24&0xFF;
			if (a == 0) { a = 255; }
			colorTransform = new ColorTransform(0,0,0,a/255,_color>>16&0xFF,_color>>8&0xFF,_color&0xFF,0);
		}
		
		/** @inheritDoc */
		public function get color():uint {
			return _color;
		}
		
		/** @inheritDoc */
		public function get visibleRange():StringPosition {
			if (textField == null) { return null; }
			var beginIndex:uint = textField.getLineOffset(textField.scrollV-1);
			var endIndex:uint = textField.getLineOffset(textField.bottomScrollV-1)+textField.getLineLength(textField.bottomScrollV-1);
			return new StringPosition(beginIndex, endIndex, textField.text.substr(beginIndex, endIndex));
		}

		/** @inheritDoc */
		public function get text():String {
			return textField.text;
		}
		public function set text(value:String):void {
			textField.text = value;
		}

		/** @inheritDoc */
		public function get isFocus():Boolean {
			return (textField != null && textField.stage && textField.stage.focus == textField);
		}

		public function get selectionBeginIndex():int {
			return textField.selectionBeginIndex;
		}

		/** @inheritDoc */
		public function get selectionEndIndex():int {
			return textField.selectionEndIndex;
		}

		/** @inheritDoc */
		public function getCharIndexUnderMouse():int {
			if (textField == null) { return -1; }

			return getCharIndexAtPoint(textField.mouseX, textField.mouseY);
		}
		
		/** @inheritDoc */
		public function getCharIndexAtPoint(x:Number, y:Number):int {
			/*
			Bug: When using Text Input with no wrap. If the text goes over the limit of the textField and the user scrolls
			to it horizontally. When you make the call getCharIndexAtPoint on it, it will return -1 and SPL will not work
			Fix: Workaround the bug since it is an adobe problem. Set the width size to the textWidth size instantaneously
			make the call and back to original width and we are able to get the info we are looking for.
			*/
			var txt:String = textField.text;
			var charIndex:int
			if(textField.scrollH > 0){
				var w:Number = textField.width;
				    var s:Number = textField.scrollH;
				    textField.width = textField.textWidth;
				    textField.scrollH = 0;
				
				    charIndex = textField.getCharIndexAtPoint(x+s,y);
				    textField.width = w;
				    textField.scrollH = s;
			} else {
				charIndex = textField.getCharIndexAtPoint(x,y);
			}
			
			return charIndex;
		}

		/** @inheritDoc */
		public function replaceText(beginIndex:int, endIndex:int, newText:String):void {
			if (textField) {
				textField.replaceText(beginIndex, endIndex, newText);
			}
		}

		/** @inheritDoc */
		public function setSelection(beginIndex:int, endIndex:int):void {
			if (textField) {
				textField.setSelection(beginIndex, endIndex);
			}
		}

		/** @inheritDoc */
		public function dispatchChangeEvent():void {
			if (textField) {
				textField.dispatchEvent(new Event(Event.CHANGE));
			}
		}

		/** @inheritDoc */
		public function setupListeners(focusListeners:Boolean, invalidateListeners:Boolean, selectionListeners:Boolean):void {
			if (!textField) { return; }

			if (focusListeners) {
				textField.addEventListener(FocusEvent.FOCUS_IN,handleFocusEvent,false,1,true);
				textField.addEventListener(FocusEvent.FOCUS_OUT,handleFocusEvent,false,1,true);
			} else {
				textField.removeEventListener(FocusEvent.FOCUS_IN,handleFocusEvent);
				textField.removeEventListener(FocusEvent.FOCUS_OUT,handleFocusEvent);
			}

			if (invalidateListeners) {
				// set priority to 1 to avoid issues with the flex framework stopping the propagation of events:
				textField.addEventListener(Event.SCROLL,handleInvalidationEvent,false,1,true);
				textField.addEventListener(Event.CHANGE,handleInvalidationEvent,false,1,true);
			} else {
				textField.removeEventListener(Event.SCROLL,handleInvalidationEvent);
				textField.removeEventListener(Event.CHANGE,handleInvalidationEvent);
			}
			
			if (selectionListeners) {
				// we need to listen for events that can change the selection:
				textField.addEventListener(MouseEvent.MOUSE_DOWN,handleSelectionMouseDown,false,1,true);
				textField.addEventListener(KeyboardEvent.KEY_DOWN,handleInvalidationEvent,false,1,true);
				textField.addEventListener(FocusEvent.FOCUS_OUT,handleInvalidationEvent,false,1,true);
			} else {
				textField.removeEventListener(MouseEvent.MOUSE_DOWN,handleSelectionMouseDown);
				textField.removeEventListener(KeyboardEvent.KEY_DOWN,handleInvalidationEvent);
				textField.removeEventListener(FocusEvent.FOCUS_OUT,handleInvalidationEvent);
			}
		}
		
		/** @inheritDoc */
		public function startDraw():Boolean {
			var range:StringPosition = visibleRange;
			var beginIndex:int = visibleRange.beginIndex;
			var endIndex:int = visibleRange.endIndex;

			if (textField == null || textField.parent == null) {
				return false;
			}

			attachHighlightCanvas();

			var i:uint = 0;
			var char0Bounds:Rectangle = textField.getCharBoundaries(beginIndex);
			yOffset = 0;
			
			var lineIndex:uint = textField.getLineIndexOfChar(beginIndex);
			while (char0Bounds == null) {
				if (++i+beginIndex >= endIndex) { return false; }
				char0Bounds = textField.getCharBoundaries(beginIndex+i);
				var lineIndex2:uint = textField.getLineIndexOfChar(beginIndex+i);
				if (lineIndex2 > lineIndex) {
					yOffset += textField.getLineMetrics(lineIndex).height;
					lineIndex = lineIndex2;
				}
			}
			yOffset -= char0Bounds.y;

			return true;
		}
		
		protected function createHilightCanvas():void {
			canvas = new Sprite();
		}
		
		protected function attachHighlightCanvas():void {
			if (canvas.parent != null) {
				canvas.parent.removeChild(canvas);
			}
			
			textField.parent.addChildAt(canvas,textField.parent.getChildIndex(textField));
			canvas.x = textField.x;
			canvas.y = textField.y;
		}
		
		/** @inheritDoc */
		public function drawHighlight(beginIndex:int,endIndex:int):void {
			var tf:TextField = textField;
			canvas.x = tf.x;
			canvas.y = tf.y;

			if (endIndex < beginIndex) { return; }
			var rect1:Rectangle = tf.getCharBoundaries(beginIndex);
			while (rect1 == null && beginIndex < endIndex) { rect1 = tf.getCharBoundaries(++beginIndex); }
			var rect2:Rectangle = tf.getCharBoundaries(endIndex);
			while (rect2 == null && beginIndex < endIndex) { rect2 = tf.getCharBoundaries(--endIndex); }
			var line1:int = tf.getLineIndexOfChar(beginIndex);
			var line2:int = tf.getLineIndexOfChar(endIndex);


			if (rect1 == null || rect2 == null) {
				// no bounds.
				trace("Error: Could not find boundaries for '"+tf.text.substring(beginIndex,endIndex)+"' beginIndex="+beginIndex+" endIndex="+endIndex);
				return;
			}

			var lineMetrics:TextLineMetrics = tf.getLineMetrics(line1);
			var xMin:Number = tf.scrollH;
			var xD:Number = tf.width-2;
			if (line1 == line2) {
				// single-line highlight:
				drawRectInXBounds(rect1.x,rect1.y+yOffset,rect2.x+rect2.width,rect1.height,xMin,xD,lineMetrics.ascent,lineMetrics.descent,3);
			} else {
				// multi-line highlight:

				// draw start line:
				rect3 = tf.getCharBoundaries(tf.getLineOffset(line1)+tf.getLineLength(line1)-1);
				if (rect3 == null) { rect3 = tf.getCharBoundaries(tf.getLineOffset(line1)+tf.getLineLength(line1)-2); }
				if (rect3) {
					drawRectInXBounds(rect1.x,rect1.y+yOffset,rect3.x+rect3.width,rect1.height,xMin,xD,lineMetrics.ascent,lineMetrics.descent,1);
				}

				// draw end line:
				var rect3:Rectangle = tf.getCharBoundaries(tf.getLineOffset(line2));
				lineMetrics = tf.getLineMetrics(line2);
				if (rect3) {
					drawRectInXBounds(rect3.x,rect3.y+yOffset,rect2.x+rect2.width,rect3.height,xMin,xD,lineMetrics.ascent,lineMetrics.descent,2);
				}

				// draw middle lines:
				var line:uint = line1;
				while (++line < line2) {
					lineMetrics = tf.getLineMetrics(line);
					if (lineMetrics == null) { continue; } // empty line
					rect1 = tf.getCharBoundaries(tf.getLineOffset(line));
					if (rect1 == null) { continue; }
					rect2 = tf.getCharBoundaries(tf.getLineOffset(line)+tf.getLineLength(line)-1);
					if (rect2 == null) { rect2 = tf.getCharBoundaries(tf.getLineOffset(line)+tf.getLineLength(line)-2); }
					drawRectInXBounds(rect1.x,rect1.y+yOffset,rect2.x+rect2.width,rect1.height,xMin,xD,lineMetrics.ascent,lineMetrics.descent,0);
				}
			}
		}
		
		/** @inheritDoc */
		public function clear():void {
			canvas.graphics.clear();
		}

		/** @inheritDoc */
		public function dispose():void {
			clear();
			if (canvas && canvas.stage) {
				canvas.parent.removeChild(canvas);
			}
			setupListeners(false, false, false);
		}

		/** @private */
		protected function drawRectInXBounds(x1:Number,y:Number,x2:Number,height:Number,boundsX:Number,boundsWidth:Number,ascent:Number,descent:Number,type:uint=3):void {
			var x:Number = Math.max(2,x1-boundsX);
			var w:Number = Math.min(boundsWidth-x,x2-boundsX-x);
			if (w > 0) {
				drawRect(x,y,w,height,ascent,descent,type);
			}
		}

		/** @private */
		protected function drawRect(x:Number,y:Number,width:Number,height:Number,ascent:Number,descent:Number,type:uint=3):void {
			canvas.graphics.beginFill(_color,(_color>>>24)/0xFF);
			canvas.graphics.drawRoundRect(x,y+height-ascent,width,ascent+descent,6);
		}
		
		/** @private */
		protected function handleInvalidationEvent(evt:Event):void {
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		/** @private */
		protected function handleFocusEvent(evt:FocusEvent):void {
			dispatchEvent(evt);
		}
		/** @private */
		protected function handleSelectionMouseDown(evt:MouseEvent):void {
			textField.stage.addEventListener(MouseEvent.MOUSE_UP,handleSelectionMouseUp,false,0,true);
			handleInvalidationEvent(evt);
		}

		/** @private */
		protected function handleSelectionMouseUp(evt:MouseEvent):void {
			textField.stage.removeEventListener(MouseEvent.MOUSE_UP,handleSelectionMouseUp);
			handleInvalidationEvent(evt);
		}
	}

}