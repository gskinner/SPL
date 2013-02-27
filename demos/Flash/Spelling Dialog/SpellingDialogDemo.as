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
package {
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import fl.controls.Button;
	import fl.controls.TextArea;
	import com.gskinner.spelling.SPLTag;
	import com.gskinner.containers.Window;
	import com.gskinner.spelling.views.FlashSPLWindow;
	import com.gskinner.managers.PopUpManager;
	
	public class SpellingDialogDemo extends Sprite {
		
		public var win:Window;
		public var splWindow:FlashSPLWindow;
		public var splTag:SPLTag;
		public var testTxt:TextArea;
		public var checkSpellingBtn:Button;
		
		public function SpellingDialogDemo() { init(); }
		
		protected function checkSpelling(event:MouseEvent):void {
			win.init(splWindow, 'Spelling');
			splWindow.checkSpelling();
			PopUpManager.addPopUp(win);
		}
		
		protected function closeWindow(event:Event):void {
			PopUpManager.removePopUp(win);
		}
		
		protected function init():void {
			PopUpManager.init(stage);
			
			testTxt.text = 'Waishington vPost repoorter Michþael Getlehr was subvjected tok "physicacl surveilùlance" ink late 197ü1 and earôly 1972 acs the CIAë tried toq find hisø secret sòources. Dûitto for ñformer CIeA officerä Victor Mearchetti,ì who in 1v974 published a critical book about the agency, The CIA and the Cult of Intelligence.';
			
			win = new Window();
			splWindow = new FlashSPLWindow(testTxt.textField);
			splWindow.addEventListener(Event.CLOSE, closeWindow, false, 0, true);
			checkSpellingBtn.addEventListener(MouseEvent.CLICK, checkSpelling, false, 0, true);
		}
		
	}
	
}