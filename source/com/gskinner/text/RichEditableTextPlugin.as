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
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.engine.TextLine;
	import flash.ui.ContextMenu;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import flashx.textLayout.compose.IFlowComposer;
	import flashx.textLayout.compose.TextFlowLine;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.edit.SelectionState;
	import flashx.textLayout.edit.TextFlowEdit;
	import flashx.textLayout.edit.TextScrap;
	import flashx.textLayout.elements.FlowLeafElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.CompositionCompleteEvent;
	import flashx.textLayout.events.SelectionEvent;
	import flashx.textLayout.events.TextLayoutEvent;
	import flashx.textLayout.tlf_internal;
	
	import mx.core.UIComponent;
	
	import spark.components.RichEditableText;
	import spark.utils.TextFlowUtil;
	
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
	 * The RichEditableText plugin defines the methods needed to provide text highlighting capabilities
	 * to RichEditableText components in the Flex 4 "spark" component set.
	 */
	public class RichEditableTextPlugin extends EventDispatcher implements ITextHighlighterPlugin {
		
		/** @private */
		protected var _textDisplay:RichEditableText;
		
		/** @private */
		protected var canvas:UIComponent;
		
		/** @private */
		protected var _color:uint = 0xFFFF0000;
		
		/** @private */
		protected var colorTransform:ColorTransform;
		
		/** @private */
		protected var invalid:Boolean;
		
		/** @private */
		protected var lastStringPosition:StringPosition;
		
		/** @private */
		protected var invalidateTimer:Timer;
		
		/** @private */
		protected var flowPosition:FlowPosition;
		
		/**
		 * Create an instance of a RichEditableTextPlugin. This is done automatically by the RichEditableTextPluginFactory
		 * when a component containing a RichEditableText instance is highlighted using the TextHighlighter class.
		 *
		 * @see com.gskinner.text.TextHighlighter TextHighlighter
		 * @param textDisplay The RichEditableText spark component instance to highlight
		 */
		public function RichEditableTextPlugin(textDisplay:RichEditableText) {
			super();
			
			_textDisplay = textDisplay;
			
			canvas = new UIComponent();
			canvas.mouseEnabled = false;
			canvas.mouseChildren = false;
			canvas.contextMenu = null;
			
			//Used when drawing highlights to mantain a position of where we are in the current textFlow
			//allows for easy updating on errors
			flowPosition = new FlowPosition();
			
			invalidateTimer = new Timer(5, 1);
			invalidateTimer.addEventListener(TimerEvent.TIMER_COMPLETE, handleInvalidTimer, false, 0, false);
			
			invalid = true;
		}
		
		/** @inheritDoc */
		public function get visibleRange():StringPosition {
			if (!invalid) {
				return lastStringPosition;
			}
			
			var startTime:uint = getTimer();
			
			//If there is no need to scroll the text, scrollRect will be null.
			var rect:Rectangle = _textDisplay.scrollRect || new Rectangle(_textDisplay.x, _textDisplay.y, _textDisplay.width, _textDisplay.height);
			var flow:TextFlow = _textDisplay.textFlow;
			
			//Offset for positioning.  If this is just an RichEditableText, top and left might be NaN
			rect.y -= _textDisplay.getStyle('top') || 0;
			rect.x -= _textDisplay.getStyle('left') || 0;
			
			var beginIndex:int = -1;
			var endIndex:int;
			
			var flowComposer:IFlowComposer = flow.flowComposer;
			
			var visibleText:String = '';
			var textDisplayText:String = _textDisplay.text;
			var l:uint = flowComposer.numLines;
			
			var lines:Vector.<TextFlowLine> = new Vector.<TextFlowLine>;
			var line:TextFlowLine;
			
			if (l > 1) {
				for (var i:uint = 0; i < l; i++) {
					line = flowComposer.getLineAt(i);
					
					if (isLineVisible(line, rect)) {
						lines.push(line);
						visibleText += textDisplayText.substr(line.absoluteStart, line.textLength);
						
						if (beginIndex == -1) {
							beginIndex = line.absoluteStart;
						}
						endIndex = endIndex < line.absoluteStart + line.textLength ? line.absoluteStart + line.textLength : endIndex;
					}
				}
			} else { //For one line flow (Probably a TextInput), we just grab the start and end index's to find the visible range. 
				line = flowComposer.getLineAt(0);
				
				if (isLineVisible(line, rect)) {
					var textLine:TextLine = line.getTextLine();
					
					var startPnt:Point = new Point(rect.x, rect.y);
					startPnt = textLine.localToGlobal(startPnt);
					
					var endPnt:Point = new Point(rect.x+rect.width, rect.y);
					endPnt = textLine.localToGlobal(endPnt);
					
					var lineStartIdx:int = textLine.getAtomIndexAtPoint(startPnt.x, startPnt.y);
					var lineEndIndex:int = textLine.getAtomIndexAtPoint(endPnt.x, endPnt.y);
					
					//wdg:: Sometimes getAtomIndexAtPoint() will return a false -1 :/
					// either pass back 0 or the last index
					beginIndex = lineStartIdx == -1?0:lineStartIdx;
					endIndex = lineEndIndex == -1?line.textLength:lineEndIndex;
					lines.push(line);
					
					visibleText = textDisplayText.substr(beginIndex, endIndex);
				}
			}
			
			//trace('visibleRange running time ', getTimer()-startTime, 'ms', l, 'lines. visibleText: ' +  visibleText);
			lastStringPosition = new StringPosition(beginIndex, endIndex, visibleText, lines);
			invalid = false;
			
			return lastStringPosition;
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
		public function get isFocus():Boolean {
			return (_textDisplay != null && _textDisplay.stage && _textDisplay.stage.focus == _textDisplay);
		}
		
		/** @inheritDoc */
		public function get text():String {
			return _textDisplay.text;
		}
		
		/** @inheritDoc */
		public function get selectionBeginIndex():int {
			var activePosition:int = _textDisplay.selectionActivePosition;
			var anchorPosition:int = _textDisplay.selectionAnchorPosition;
			
			return activePosition > anchorPosition?anchorPosition:activePosition;
		}
		
		/** @inheritDoc */
		public function get selectionEndIndex():int {
			var activePosition:int = _textDisplay.selectionActivePosition;
			var anchorPosition:int = _textDisplay.selectionAnchorPosition;
			
			return anchorPosition < activePosition?activePosition:anchorPosition;
		}
		
		/** @inheritDoc */
		public function setupListeners(focusListeners:Boolean, invalidateListeners:Boolean, selectionListeners:Boolean):void {
			if (focusListeners) {
				_textDisplay.addEventListener(FocusEvent.FOCUS_IN, handleFocusEvent, false, 1, false);
				_textDisplay.addEventListener(FocusEvent.FOCUS_OUT, handleFocusEvent, false, 1, false);
			} else {
				_textDisplay.removeEventListener(FocusEvent.FOCUS_IN, handleFocusEvent);
				_textDisplay.removeEventListener(FocusEvent.FOCUS_OUT, handleFocusEvent);
			}
			
			if (invalidateListeners) {
				_textDisplay.textFlow.addEventListener(TextLayoutEvent.SCROLL, handleInvalidationEvent, false, 1, false);
				
				//Only dispatched we the engine re-draws text.  It may not be disptached when a scroll happens
				_textDisplay.textFlow.addEventListener(CompositionCompleteEvent.COMPOSITION_COMPLETE, handleInvalidationEvent, false, 1, false);
			} else {
				_textDisplay.textFlow.removeEventListener(TextLayoutEvent.SCROLL, handleInvalidationEvent);
				_textDisplay.textFlow.removeEventListener(CompositionCompleteEvent.COMPOSITION_COMPLETE, handleInvalidationEvent);
			}
			
			if (selectionListeners) {
				_textDisplay.textFlow.addEventListener(SelectionEvent.SELECTION_CHANGE, handleInvalidationEvent, false, 0, false);
			} else {
				_textDisplay.textFlow.removeEventListener(SelectionEvent.SELECTION_CHANGE, handleInvalidationEvent);
			}
			
			//This event is not dispatched when text is edited, it should be but its not.
			//_textDisplay.textFlow.addEventListener(TextOperationEvent.CHANGE, handleInvalidationEvent);
		}
		
		/** @inheritDoc */
		public function startDraw():Boolean {
			if (_textDisplay.stage == null) {
				return false;
			}
			
			_textDisplay.addChildAt(canvas, 0);
			var rect:Rectangle = _textDisplay.scrollRect || new Rectangle;
			canvas.y = rect.y;
			canvas.x = rect.x;
			
			var td:RichEditableText = _textDisplay;
			canvas.scrollRect = new Rectangle(td.x, td.y, td.width, td.height);
			
			return true;
		}
		
		/** @inheritDoc */
		public function drawHighlight(beginIndex:int, endIndex:int):void {
			if (endIndex < beginIndex || beginIndex == endIndex) {
				return;
			}
			
			//var word:String = _textDisplay.text.substr(beginIndex, endIndex - beginIndex + 1); //For debugging
			
			var composer:IFlowComposer = _textDisplay.textFlow.flowComposer;
			var line:TextFlowLine = composer.findLineAtPosition(beginIndex);
			var textDisplayScrollRect:Rectangle = _textDisplay.scrollRect;
			
			flowPosition.line = line;
			flowPosition.beginIndex = beginIndex;
			
			var rectsToDraw:Vector.<DrawRectangleMetrics> = new Vector.<DrawRectangleMetrics>;
			
			// Loop so if needed, we can draw multiple lines for this word:
			for (; true; ) {
				line = flowPosition.line;
				if (line == null) {
					break; //no more lines to draw, break and move on
				}
				
				beginIndex = flowPosition.beginIndex;
				
				var currentLineEnd:Number = line.absoluteStart + line.textLength;
				var actualEndIndex:Number = endIndex >= currentLineEnd ? line.textLength - 1 : endIndex - beginIndex < 0 ? 0 : endIndex - beginIndex;
				
				//Line is not visible and was gc'd
				if (line.textLineExists == false) {
					updateFlowPosition(endIndex, currentLineEnd, composer, flowPosition);
					continue;
				}
				
				var textLine:TextLine = line.getTextLine();
				
				//Sometimes a line will exist in memory, with an in-bounds position, but not be visible, so ignore and move on.
				if (textLine.stage == null) {
					updateFlowPosition(endIndex, currentLineEnd, composer, flowPosition);
					continue;
				}
				
				var atomIndex:int = beginIndex - line.absoluteStart;
				
				//Sometimes when editing text, the line length will be less then the index we want
				//Just ignore and move on.
				if (atomIndex < textLine.atomCount) {
					var startBounds:Rectangle = textLine.getAtomBounds(atomIndex);
				} else {
					updateFlowPosition(endIndex, currentLineEnd, composer, flowPosition);
					continue;
				}
				
				var atomEndIndex:uint = (beginIndex - line.absoluteStart) + actualEndIndex;
				if (atomEndIndex < textLine.atomCount) {
					var endBounds:Rectangle = textLine.getAtomBounds(atomEndIndex);
				} else {
					updateFlowPosition(endIndex, currentLineEnd, composer, flowPosition);
					continue;
				}
				
				//If the draw won't be visible, then stop the draw.
				if (textDisplayScrollRect != null) {
					var x:Number = startBounds.x;
					var y:Number = _textDisplay.y + line.y + line.height - line.descent;
					if (!(x <= textDisplayScrollRect.x + textDisplayScrollRect.width && x >= textDisplayScrollRect.x && y >= textDisplayScrollRect.y && y <= textDisplayScrollRect.y + textDisplayScrollRect.height)) {
						updateFlowPosition(endIndex, currentLineEnd, composer, flowPosition);
						continue;
					}
				}
				
				var yOffset:Number = (textDisplayScrollRect != null) ? textDisplayScrollRect.y : 0;
				var xOffset:Number = (textDisplayScrollRect != null) ? textDisplayScrollRect.x : 0;
				
				rectsToDraw.push(
					new DrawRectangleMetrics(
						startBounds.x + line.x + _textDisplay.x - xOffset,
						(startBounds.y + textLine.y + _textDisplay.y) - yOffset,
						(endBounds.x + endBounds.width) - startBounds.x,
						textLine.height,
						textLine.ascent,
						textLine.descent
					));
				updateFlowPosition(endIndex, currentLineEnd, composer, flowPosition);
			}
			
			var l:uint = rectsToDraw.length;
			var rm:DrawRectangleMetrics;
			var type:uint;
			for (var i:uint = 0; i < l; i++) {
				rm = rectsToDraw[i];
				if (l == 1) {
					type = 1; //Draw both
				} else if (i > 0 && i < l - 1) {
					type = 2; //Draw middle
				} else if (i == 0 && l > 1) {
					type = 3; //Draw start with no end
				} else {
					type = 4; //Draw end
				}
				
				drawRect(rm.x, rm.y, rm.width, rm.height, rm.ascent, rm.descent, type);
			}
		}
		
		/**
		 * @private
		 * Utility method to refresh the flowPosition, used in drawHighlight();
		 */
		protected function updateFlowPosition(endIndex:int, currentLineEnd:int, composer:IFlowComposer, pos:FlowPosition):void {
			var line:TextFlowLine = endIndex < currentLineEnd ? null : composer.findLineAtPosition(currentLineEnd + 1);
			
			pos.line = line;
			pos.beginIndex = line == null ? 0 : line.absoluteStart;
		}
		
		/** @inheritDoc */
		public function clear():void {
			canvas.graphics.clear();
		}
		
		/** @inheritDoc */
		public function dispose():void {
			clear();
			
			setupListeners(false, false, false);
			
			_textDisplay.removeChild(canvas);
			
			invalidateTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, handleInvalidTimer);
			invalidateTimer.stop();
		}
		
		/** @inheritDoc */
		public function getCharIndexUnderMouse():int {
			if (_textDisplay == null || _textDisplay.stage == null) {
				return -1;
			}
			
			var mouseX:Number = _textDisplay.stage.mouseX;
			var mouseY:Number = _textDisplay.stage.mouseY;
			
			return getCharIndexAtPoint(mouseX, mouseY);
		}
		
		/** @inheritDoc */
		public function getCharIndexAtPoint(x:Number, y:Number):int {
			if (_textDisplay == null || _textDisplay.stage == null) {
				return -1;
			}
			
			var stringPos:StringPosition = visibleRange;
			var lines:Vector.<TextFlowLine> = stringPos.data as Vector.<TextFlowLine>;
			var l:uint = lines.length;
			for (var i:uint = 0; i < l; i++) {
				var line:TextFlowLine = lines[i];
				var index:int = -1;
				
				var txtLine:TextLine = line.getTextLine();
				if (txtLine) { //This could have been gc'd by TLF.
					index = txtLine.getAtomIndexAtPoint(x, y);
				}
				
				if (index != -1) {
					return index + line.absoluteStart;
				}
			}
			
			return -1;
		}
		
		/** @inheritDoc */
		public function getCharIndexFromEvent(event:MouseEvent):int {
			return getCharIndexAtPoint(event.stageX, event.stageY);
		}
		
		/** @inheritDoc */
		public function replaceText(beginIndex:int, endIndex:int, newText:String):void {
			var flow:TextFlow = _textDisplay.textFlow;
			
			invalid = true;
			
			/*
			// Flex 4.0 support ... just here for reference.
			
			var leaf:FlowLeafElement = flow.findLeaf(beginIndex + 1);
			var span:SpanElement = leaf as SpanElement;
			var absStart:int = leaf.getAbsoluteStart();
			
			var textFlow:TextFlow = TextFlowUtil.importFromXML(<TextFlow xmlns='http://ns.adobe.com/textLayout/2008'>{newText}</TextFlow>);
			textFlow.hostFormat = leaf.computedFormat;
			var textScrap:TextScrap = new TextScrap(textFlow);
			
			//Insert the new text
			TextFlowEdit.insertTextScrap(flow, beginIndex, textScrap, false);
			
			//Then we delete the original text
			ModelEdit.deleteText(flow, beginIndex + newText.length, endIndex+newText.length+1, false);
			*/
			
			//Flex 4.1 support
			var editManager:EditManager = flow.interactionManager as EditManager;
			if  (editManager) {
				editManager.insertText(newText, new SelectionState(flow, beginIndex, beginIndex));
				editManager.deleteText(new SelectionState(flow, beginIndex + newText.length, endIndex+newText.length));
			}
		}
		
		/** @inheritDoc */
		public function setSelection(beginIndex:int, endIndex:int):void {
			if (_textDisplay.selectable == false) {
				_textDisplay.selectable = true;
			}
			_textDisplay.selectRange(beginIndex, endIndex);
		}
		
		/** @inheritDoc */
		public function dispatchChangeEvent():void {
			if (hasEventListener(Event.CHANGE)) {
				dispatchEvent(new Event(Event.CHANGE));
			}
		}
		
		/** @inheritDoc */
		public function get contextMenu():ContextMenu {
			return createContextMenu();
		}
		/** @private */
		public function set contextMenu(value:ContextMenu):void {
			attachContextMenu(value);
		}
		
		// Protected Methods:
		/**
		 * Forces the TLF framework to create its context menu.
		 * This will normally only happen on focus, but for SPL support we need the menu before focus occurs.
		 * Note: This will only work with a single controller (which will work fine in most instances).
		 *
		 * @see attachContextMenu();
		 * 
		 */
		protected function createContextMenu():ContextMenu {
			if (_textDisplay) {
				var controller:ContainerController = _textDisplay.textFlow.flowComposer.getControllerAt(0);
				try {
					//This method doesn't exist in 4.1, so we need to supress the error.
					controller.tlf_internal::attachContextMenu();
				} catch (e:*) { } //In 4.1 the contextMenu is not created untill setFocus();
			}
			return _textDisplay != null ? controller.container.contextMenu as ContextMenu : null;
		}
		
		/**
		 * Attaches our custom contextMenu to the first TLF flow composer.
		 * 
		 * @param menu The context menu to attach.
		 * 
		 * @see createContextMenu();
		 * 
		 */
		protected function attachContextMenu(menu:ContextMenu):void {
			if (_textDisplay) {
				_textDisplay.textFlow.flowComposer.getControllerAt(0).container.contextMenu = menu;
			}
		}
		
		
	// Protected Methods:		
		/** @private */
		protected function isLineVisible(line:TextFlowLine, bounds:Rectangle):Boolean {
			var textLineBounds:Rectangle;
			var textLine:TextLine;
			
			if (line == null || line.textLineExists == false) {
				return false;
			}
			
			textLine = line.getTextLine();
			if (textLine.stage == null) {
				return false;
			}
			
			/* To catch:
				ArgumentError: Error #2004: One of the parameters is invalid.
					at Error$/throwError()
					at flash.text.engine::TextBlock/createTextLine()
					at Function/http://adobe.com/AS3/2006/builtin::apply()
					at GlobalSWFContext/callInContext()[C:\Vellum\branches\v1\1.1\dev\output\openSource\textLayout\src\flashx\textLayout\compose\BaseCompose.as:1325]
		 	*/
			try {
				textLineBounds = line.getBounds();
			} catch (e:ArgumentError) { return false; }
			
			var rectY:Number = bounds.y;
			var rectX:Number = bounds.x;
			var textLineY:Number = textLineBounds.y + textLineBounds.height;
			var textLineX:Number = textLineBounds.x + textLineBounds.width;
			
			return (textLineY >= rectY && textLineY < rectY + bounds.height);
		}
		
		/** @private */
		protected function handleInvalidTimer(event:TimerEvent):void {
			invalid = true;
			
			dispatchChangeEvent();
		}
		
		/** @private */
		protected function handleInvalidationEvent(event:Event):void {
			if (!invalidateTimer.running) {
				invalidateTimer.start();
			}
			
			var rect:Rectangle = _textDisplay.scrollRect || new Rectangle;
			canvas.y = rect.y;
			canvas.x = rect.x;
		}
		
		/** @private */
		protected function handleFocusEvent(evt:FocusEvent):void {
			dispatchEvent(evt);
		}
		
		/** @private */
		protected function drawRect(x:Number, y:Number, width:Number, height:Number, ascent:Number, descent:Number, type:uint = 1):void {
			canvas.graphics.beginFill(_color, (_color >>> 24) / 0xFF);
			var rr:Number;
			var lr:Number;
			
			if (type == 1) {
				rr = lr = 4;
			} else if (type == 2) {
				rr = lr = 0;
			} else if (type == 3) {
				rr = 0;
				lr = 4;
			} else if (type == 4) {
				rr = 4;
				lr = 0;
			}
			
			canvas.graphics.drawRoundRectComplex(x, y, width, height, lr, rr, lr, rr);
		}
	}
}


import flashx.textLayout.compose.TextFlowLine;

/**
 * A utility class to store and modify TextFlowLine meta information in RichEditableText.
 */
class FlowPosition {
	
	public var line:TextFlowLine;
	public var beginIndex:int;

}

/**
 * A utility class to assist with storing and drawing highlights.
 */
class DrawRectangleMetrics {
	
	/**
	 * The horizontal position of the rectangle
	 */
	public var x:Number;
	
	/**
	 * The vertical position of the rectangle
	 */
	public var y:Number;
	
	/**
	 * The width of the rectangle
	 */
	public var width:Number;
	
	/**
	 * The height position of the rectangle
	 */
	public var height:Number;
	
	/**
	 * The vertical ascent of the rectangle from the baseline
	 */
	public var ascent:Number;
	
	/**
	 * The vertical descent of the rectangle from the baseline
	 */
	public var descent:Number;
	
	/**
	 * Create a DrawTriangleMetrics value object
	 *
	 * @param x The horizontal position of the rectangle
	 * @param y The vertical position of the rectangle
	 * @param width The width of the rectangle
	 * @param height The height of the rectangle
	 * @param ascent The vertical ascent of the rectangle from the baseline
	 * @param descent The vertical descent of the rectangle from the baseline
	 */
	public function DrawRectangleMetrics(x:Number, y:Number, width:Number, height:Number, ascent:Number, descent:Number) {
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		this.ascent = ascent;
		this.descent = descent;
	}

}