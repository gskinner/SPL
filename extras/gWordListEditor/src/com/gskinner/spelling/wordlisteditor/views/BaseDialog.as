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
package com.gskinner.spelling.wordlisteditor.views {

	import flash.events.Event;
	import com.gskinner.spelling.wordlisteditor.events.DialogEvent;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	import mx.containers.TitleWindow;
	
	public class BaseDialog extends TitleWindow {
		
		public static const DELAY_AMOUNT:uint = 5;
		protected var tick:uint = 0;
		
		public function BaseDialog() { initListeners(); }

		protected function initListeners():void {
			addEventListener(Event.ENTER_FRAME, delayAvailablity);
			addEventListener(Event.CLOSE, hide);
		}
		
		protected function delayAvailablity(p_event:Event):void {
			if (tick >= DELAY_AMOUNT) {
				tick = 0;
				removeEventListener(Event.ENTER_FRAME, delayAvailablity);
				dispatchEvent(new DialogEvent(DialogEvent.AVAILABLE));
			} else {
				tick++;
			}
		}
		
		protected function hide(event:CloseEvent):void {
			PopUpManager.removePopUp(this);
			removeEventListener(Event.CLOSE, hide);
		}
	}
}