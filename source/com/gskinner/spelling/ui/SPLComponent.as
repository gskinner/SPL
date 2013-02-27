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
package com.gskinner.spelling.ui {
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * Base class used for creating custom ContextMenu elements.
	 * 
	 */
	public class SPLComponent extends Sprite {
		
		/** @private **/
		protected var _width:Number=0;
		
		/** @private **/
		protected var _height:Number=0;
		
		/** @private **/
		protected var _enabled:Boolean=true;
		
		/**
		 * Creates a new SPLComponent instance.
		 * 
		 */
		public function SPLComponent() {
			super();
			
			initialize();			
		}
		
		/**
		 * Sets the width of this item
		 * 
		 */
		override public function set width(value:Number):void {
			if (value != _width) {
				_width = value;
				invalidate();
				dispatchEvent(new Event(Event.RESIZE));
			}
		}
		
		/**
		 * Returns the current width 
		 * 
		 */
		override public function get width():Number {
			return _width;
		}
		
		/**
		 * Sets the current height of the element
		 * 
		 */
		override public function set height(value:Number):void {
			if (value != _height) {
				_height = value;
				invalidate();
				dispatchEvent(new Event(Event.RESIZE));
			}
		}
		
		/**
		 * Gets this items current height
		 * 
		 */
		override public function get height():Number {
			return _height;
		}
		
		/**
		 * Sets the items enabled property.
		 * Also enables or disables tab and mouse interaction.
		 * 
		 */
		public function set enabled(value:Boolean):void {
			_enabled = value;
			tabEnabled = mouseEnabled = mouseChildren = _enabled;
			alpha = _enabled ? 1.0 : 0.5;
		}
		
		/**
		 * Gets the enabled property for this item.
		 * 
		 */
		public function get enabled():Boolean {
			return _enabled;
		}
		
		/**
		 * Forces a draw() operation to happen, skipping invalidation.
		 * 
		 */
		public function drawNow():void {
			draw();
		}
		
		/** @private */
		protected function createChildren():void { }
		
		/** @private */
		protected function draw():void { }
		
		/** @private */
		protected function initialize():void {
			createChildren();
			invalidate();
		}
		
		/** @private */
		protected function invalidate():void {
			if (!hasEventListener(Event.ENTER_FRAME)) addEventListener(Event.ENTER_FRAME, handleInvalidate);
		}
		
		/** 
		 * Event handlers
		 */
		/** @private */
		protected function handleInvalidate(event:Event):void {
			removeEventListener(Event.ENTER_FRAME, handleInvalidate);
			draw();
		}
	}
}