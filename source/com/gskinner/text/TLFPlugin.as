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

	import fl.text.TLFTextField;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
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
	 * The TLF plugin defines the methods needed to provide text highlighting capabilities
	 * to TLFTextFields and TLF-based components such as the Flex 4 "spark" component set.
	 */
	public class TLFPlugin extends EventDispatcher implements ITextHighlighterPlugin {

		/** @private */
		protected var textField:TLFTextField;
		
		/** @private */
		protected var yOffset:Number=0;
		
		/** @private */
		protected var canvas:Sprite;
		
		/** @private */
		protected var _color:uint = 0xFFFF0000;
		
		/** @private */
		protected var colorTransform:ColorTransform;
		
		/**
		 * Create an instance of a TLFPlugin. This is done automatically by the TLFPluginFactory
		 * when a component containing a TLFTextField is highlighted using the TextHighlighter class.
		 *
		 * @see com.gskinner.text.TextHighlighter TextHighlighter
		 * @param textField The TLFTextField instance to highlight
		 */
		public function TLFPlugin(textField:TLFTextField) {
			this.textField = textField;
			canvas = new Sprite();
		}
		
		/** @inheritDoc */
		public function get contextMenu():ContextMenu { //
			return (textField ? textField.contextMenu as ContextMenu : null);
		}
		/** @private */
		public function set contextMenu(value:ContextMenu):void { //
			if (textField) {
				textField.contextMenu = value;
				
				//Hack, we had to disable mouse interactions on this Sprite or the context menu won't show.
				var sprite:Sprite = textField.getChildAt(1) as Sprite;
				if (sprite) {
					sprite.mouseEnabled  = false;
				}
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
		public function get visibleRange():StringPosition { // scrollV is 0 based in TLF.
			if (textField == null) { return null; }
			
			//wdg:: I need to add this line or the TLFTextField throws errors, when calling getLineOffset().. Found error in cs 5.5
			textField.getLineOffset(0);
			
			var beginIndex:uint = textField.getLineOffset(textField.scrollV);
			var endIndex:uint = textField.getLineOffset(textField.bottomScrollV-1)+textField.getLineLength(textField.bottomScrollV-1);
			return new StringPosition(beginIndex, endIndex, textField.text.substr(beginIndex, endIndex));
		}
		
		/** @inheritDoc */
		public function get text():String {
			return textField.text;
		}
		/** @private */
		public function set text(value:String):void {
			textField.text = value;
		}
		
		/** @inheritDoc */
		public function get isFocus():Boolean {
			return (textField != null && textField.stage && textField.stage.focus == textField);
		}
		
		/** @inheritDoc */
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
			var point = new Point();
			point = textField.localToGlobal(point);
			
			var pnt:int = textField.getCharIndexAtPoint(point.x+x, point.y+y);
			return pnt;
		}
		
		/** @inheritDoc */
		public function getCharIndexFromEvent(event:MouseEvent):int {
			return getCharIndexAtPoint(event.stageX, event.stageY);
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
			if (canvas.parent != null) {
				canvas.parent.removeChild(canvas);
			}
			
			if (textField == null || textField.parent == null) {
				return false;
			}
			
			var range:StringPosition = visibleRange;
			var beginIndex:int = visibleRange.beginIndex;
			var endIndex:int = visibleRange.endIndex;
			
			
			
			textField.parent.addChildAt(canvas,textField.parent.getChildIndex(textField));
			canvas.x = textField.x;
			canvas.y = textField.y;
			
			yOffset = 0;

			return true;
		}
			
		/** @inheritDoc */
		public function drawHighlight(beginIndex:int,endIndex:int):void {
			var tf:TLFTextField = textField;
			canvas.x = tf.x;
			canvas.y = tf.y;
			
			if (endIndex < beginIndex) { return; }
			
			var rect1:Rectangle = tf.getCharBoundaries(beginIndex);
			while (rect1 == null && beginIndex < endIndex) { rect1 = tf.getCharBoundaries(++beginIndex); }
			var line1:int = tf.getLineIndexOfChar(beginIndex);
			
			//When a word wraps across multiple lines, and some of the lines are out of range getCharBoundaries() will be 1 index off
				//So grab the actual text (endIndex + 3) .. not sure why its +3, but it works consistently.
				//And see if this word is wrapping multiple lines.
			var lineText:String = tf.getLineText(line1);
			var wordToFind:String = tf.text.substring(beginIndex,endIndex+3);
			if (wordToFind.indexOf(lineText) == 0 && wordToFind.length > lineText.length) {
				endIndex++;
			}
			
			var rect2:Rectangle = tf.getCharBoundaries(endIndex);
			while (rect2 == null && beginIndex < endIndex) { rect2 = tf.getCharBoundaries(--endIndex); }
			var line2:int = tf.getLineIndexOfChar(endIndex);
			
			if (rect1 == null || rect2 == null) {
				trace("Error: Could not find boundaries for '"+tf.text.substring(beginIndex,endIndex)+"' beginIndex="+beginIndex+" endIndex="+endIndex);
				return;
			}
			
			var lineMetrics:TextLineMetrics = tf.getLineMetrics(line1);
			var xMin:Number = tf.scrollH;
			var yMin:Number = tf.scrollRect == null?0:tf.scrollRect.y;
			var xD:Number = tf.width-2;
			var boundsHeight:Number = textField.scrollRect?textField.scrollRect.height:textField.height
				
			if (line1 == line2) {
				// single-line highlight:
				drawRectInBounds(rect1.x,rect1.y+yOffset,rect2.x+rect2.width,rect1.height,xMin,yMin,xD,boundsHeight,lineMetrics.ascent,lineMetrics.descent,3);
			} else {
				// multi-line highlight:
				
				// draw start line:
				rect3 = tf.getCharBoundaries(tf.getLineOffset(line1)+tf.getLineLength(line1));
				if (rect3 == null) { rect3 = tf.getCharBoundaries(tf.getLineOffset(line1)+tf.getLineLength(line1)-1); }
				if (rect3) {
					drawRectInBounds(rect1.x,rect1.y,rect3.x+rect3.width,rect1.height,xMin,yMin,xD,boundsHeight,lineMetrics.ascent,lineMetrics.descent,1);
				}
				
				// draw end line:
				var rect3:Rectangle = tf.getCharBoundaries(tf.getLineOffset(line2));
				lineMetrics = tf.getLineMetrics(line2);
				if (rect3) {
					drawRectInBounds(rect3.x,rect3.y+yOffset,rect2.x+rect2.width,rect3.height,xMin,yMin,xD,boundsHeight,lineMetrics.ascent,lineMetrics.descent,2);
				}

				// draw middle lines:
				var line:uint = line1;
				while (++line < line2) {
					lineMetrics = tf.getLineMetrics(line);
					if (lineMetrics == null) { continue; } // empty line
					rect1 = tf.getCharBoundaries(tf.getLineOffset(line));
					
					if (rect1 == null) { continue; }
					rect2 = tf.getCharBoundaries(tf.getLineOffset(line)+tf.getLineLength(line));
					
					if (rect2 == null) { rect2 = tf.getCharBoundaries(tf.getLineOffset(line)+tf.getLineLength(line)-1); }
					drawRectInBounds(rect1.x,rect1.y+yOffset,rect2.x+rect2.width,rect1.height,xMin,yMin,xD,boundsHeight,lineMetrics.ascent,lineMetrics.descent,0);
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
			canvas.parent.removeChild(canvas);
			setupListeners(false, false, false);
		}
		
		
	// Protected Methods:
		/** @private */
		protected function drawRectInBounds(x1:Number,y:Number,x2:Number,height:Number,boundsX:Number,boundsY:Number,boundsWidth:Number,boundsHeight:Number, ascent:Number,descent:Number,type:uint=3):void {
			var x:Number = Math.max(2,x1-boundsX);
			var w:Number = Math.min(boundsWidth-x,x2-boundsX-x);
			
			if (w > 0 && y > boundsY && y < boundsY -height + boundsHeight) {
				drawRect(x,y,w,height,ascent,descent,type);
			}
		}
		
		/** @private */
		protected function drawRect(x:Number,y:Number,width:Number,height:Number,ascent:Number,descent:Number,type:uint=3):void {
			canvas.graphics.beginFill(_color,(_color>>>24)/0xFF);
			canvas.graphics.drawRoundRect(x,y+height-ascent-descent,width,ascent+descent,6);
		}
		
		/** @private */
		protected function handleInvalidationEvent(evt:Event):void {
			//wdg:: need to delay a frame here, since sometimes while scrolling text positions a frame off.
				//Also tryed using TextFlow events, with same result.
			textField.addEventListener(Event.ENTER_FRAME, handleInvalindateFrameDelay);
		}
		
		/** @private */
		protected function handleInvalindateFrameDelay(event:Event):void {
			textField.removeEventListener(Event.ENTER_FRAME, handleInvalindateFrameDelay);
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