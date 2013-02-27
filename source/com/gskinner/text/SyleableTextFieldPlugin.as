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
	
	import flash.events.MouseEvent;
	
	import mx.core.UIComponent;
	
	import spark.components.Group;
	import spark.components.supportClasses.StyleableTextField;
	
	/**
	 * The TextField plugin defines the methods needed to provide text highlighting capabilities
	 * to Flex's SyleableTextField (used in AIR for mobile)
	 */
	public class SyleableTextFieldPlugin extends TextFieldPlugin {
		
		public function SyleableTextFieldPlugin(textField:StyleableTextField) {
			super(textField);
		}
		
		/** @inheritDoc */
		override public function getCharIndexFromEvent(event:MouseEvent):int {
			return getCharIndexAtPoint(event.localX, event.localY);
		}
		
		/**
		 * @private
		 * 
		 */
		override protected function createHilightCanvas():void {
			canvas = new UIComponent();
		}
		
		/**
		 * @private
		 * 
		 */
		override protected function attachHighlightCanvas():void {
			if (canvas.parent as Group != null && (canvas.parent as Group).containsElement(canvas as UIComponent)) {
				(canvas.parent as Group).removeElement(canvas as UIComponent);
			}
			
			(textField.parent as Group).addElementAt(canvas as UIComponent,textField.parent.getChildIndex(textField));
			canvas.x = textField.x;
			canvas.y = textField.y;
		}
	}
}