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
	
	import flash.display.Graphics;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class SPLContextMenuItemRenderer extends SPLComponent {
		
		/** @private */
		protected var _label:String = '';
		
		/** @private */
		protected var _tf:TextField;
		
		/** @private */
		protected var _txtWidth:Number=0;
		
		/** @private */
		protected var _mouseOver:Boolean = false;
		
		/** @private */
		protected var _normalFormat:TextFormat;
		
		/** @private */
		protected var _overFormat:TextFormat;
		
		public function SPLContextMenuItemRenderer(label:String) {
			_label = label;
			
			super();
			
			addEventListener(MouseEvent.MOUSE_OVER, handleOver, false, 0, true);
		}
		
		public function get textWidth():Number {
			return _txtWidth;
		}
		
		public function set label(value:String):void {
			_label = value || '';
			
			invalidate();
		}
		
		public function get label():String {
			return _label;
		}
		
		/** @private */
		protected function get normalFormat():TextFormat {
			return _normalFormat ||= new TextFormat('_sans', 16, 0xFFFFFF, false, false)
		}
		
		/** @private */
		protected function get overFormat():TextFormat {
			return _overFormat ||= new TextFormat('_sans', 16, 0xFFFFFF, false, false)
		}
		
		/** @private */
		override protected function createChildren():void {
			_tf = new TextField();
			_tf.height = _height;
			_tf.selectable = false;
			_tf.mouseEnabled = false;
			_tf.defaultTextFormat = normalFormat;
			_tf.text = _label;
			_tf.autoSize = TextFieldAutoSize.LEFT;
			_txtWidth = _width = _tf.width;
			addChild(_tf);
		}
		
		/** @private */
		override protected function draw():void {			
			_tf.text = _label;
			_txtWidth = _tf.width + 15;
			_tf.y = _height - _tf.height >> 1;
			_tf.x = 5;
			
			var g:Graphics = graphics;
			g.clear();
			
			g.beginFill(0x003416, _mouseOver ? 1 : 0);
			g.drawRect(0, 0, _width, _height);
			g.endFill();
						
			super.draw();
		}
		
		/**
		 * Event Handlers
		 */
		/** @private */
		protected function handleOver(event:MouseEvent):void {
			addEventListener(MouseEvent.MOUSE_OUT, handleOut);
			_mouseOver = true;
			invalidate();
		}
		
		/** @private */
		protected function handleOut(event:MouseEvent):void {
			removeEventListener(MouseEvent.MOUSE_OUT, handleOut);
			_mouseOver = false;
			invalidate();
		}
	}
}