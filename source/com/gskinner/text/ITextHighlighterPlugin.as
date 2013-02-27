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
	
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.ui.ContextMenu;
	
	/**
	 * The interface a TextHighlighter plugin must expose to assist SPL in highlighting a text or component instance.
	 * In order to provide TLF and RichEditableText capabilities, but also support legacy TextField in earlier Flash
	 * versions, plugins provide the actual metrics and access to highlight text, making compiling in older versions
	 * possible.
	 *
	 * In addition to the instance interface, plugins must expose a static getInstance(target:Object) method, which
	 * scans the target, and returns an instance of the plugin if it can find an appropriate object to operate on, such
	 * as a textField for the TextFieldPlugin.
	 */
	public interface ITextHighlighterPlugin extends IEventDispatcher {
		
		/**
		 * The visible range of text, which contains a start, end, and substring of text.
		 */
		function get visibleRange():StringPosition;
		
		/**
		 * Determines if the component is currently the focus of the application.
		 */
		function get isFocus():Boolean;
		
		/**
		 * The text of the component.
		 * Read-only because we have no reason to set the text here.
		 */
		function get text():String;
		
		/**
		 * The color of the highlight.
		 */
		function set color(color:uint):void;
		function get color():uint;
		
		/**
		 * The beginning of the current text selection.
		 */
		function get selectionBeginIndex():int
		
		/**
		 * The end of the current text selection.
		 */
		function get selectionEndIndex():int
		
		/**
		 * Set up listeners, which help bubble events to the SPL framework.
		 *
		 * @param focusListeners Specifies if focus-based events should be exposed
		 * @param invalidateListeners Specifies if invalidation events should be exposed
		 * @param selectionListeners Specifies if selection events should be exposed
		 */
		function setupListeners(focusListeners:Boolean, invalidateListeners:Boolean, selectionListeners:Boolean):void;
		
		/**
		 * Called before a series of new drawHighlight operations. Provides the plugin with an opportunity
		 * to set up for the draw and precalculate necessary values.
		 */
		function startDraw():Boolean;
		
		/**
		 * Draws a highlight effect on the character range specified by beginIndex and endIndex.
		 * This can be useful for highlighting a specific word or range of text, instead of all instances
		 * of a word. Works with multiple line text ranges. Note that highlights drawn this way are
		 * temporary, and will be removed the next time highlights are redrawn (by calling update, or
		 * scrolling the field for example).
		 *
		 * @param beginIndex The character index to begin drawing the highlight at.
		 * @param endIndex The character index to finish drawing the highlight at.
		 */
		function drawHighlight(beginIndex:int, endIndex:int):void;
		
		/**
		 * Clear the current highlight.
		 */
		function clear():void;
		
		/**
		 * Clean up the plugin so it can be garbage collected. Dispose usually happens when a
		 * highlighter changes targets, or is no longer in use.
		 */
		function dispose():void;
		
		/**
		 * The context menu of the highlighter.
		 */
		function get contextMenu():ContextMenu;
		/** @private */
		function set contextMenu(value:ContextMenu):void;
		
		
		// Developer note: These methods are currently only be used by SpellingHighlighter, but are implemented in all the text plugins.
		
		/**
		 * Returns the character index under the mouse. This is primarily used by SPL to determine what
		 * word is right-clicked.
		 */
		function getCharIndexUnderMouse():int;
		
		/**
		 * Returns the character index at a specific point.
		 * Used primarly for touch devices to determine where a user has clicked, or long pressed.
		 * 
		 * @version 2.1
		 */
		function getCharIndexAtPoint(x:Number, y:Number):int;
		
		/**
		 * Utility function to retreive the correct character position from a mouse event.
		 * For example SyleableTextFieldPlugin uses localX and localY, vs stageX and stageY
		 * 
		 */
		function getCharIndexFromEvent(event:MouseEvent):int;
		
		/**
		 * Replaces text between given indexes. This is primarily used for SPL suggestion selection.
		 *
		 * @param beginIndex The index where the replacement begins
		 * @param endIndex The index where the replacement ends
		 * @param newText The new text to add to the component between the start and end indexes
		 */
		function replaceText(beginIndex:int, endIndex:int, newText:String):void;
		
		/**
		 * Set the selection of the text component between the given index. The is primarily used for
		 * SPL suggestion selection to maintain user selection.
		 *
		 * @param beginIndex The index to begin selection
		 * @param endIndex The index to end selection
		 */
		function setSelection(beginIndex:int, endIndex:int):void;
		
		/**
		 * Force the component to manually dispatch a text change event, since ActionScript-based interactions
		 * will not trigger change events. This is primarily used by SPL to dispatch events when a suggestion
		 * is selected.
		 */
		function dispatchChangeEvent():void;
	}
	
}