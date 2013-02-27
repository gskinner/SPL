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
package com.gskinner.managers {
	
	import flash.display.Stage;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	import flash.events.Event;
	import com.gskinner.containers.Window;
	
	public class PopUpManager {

		private static var innited:Boolean = false;
		private static var _stage:Stage;
		private static var _modal:Sprite;
		private static var _showModal:Boolean;
		private static var popUpCount:uint = 0;
		
		private static var popupHash:Dictionary;
	// Initialization:
		public function PopUpManager() {}
	
	// Public Methods:
		public static function init(stage:Stage):void {
			if (innited) { return; }
			if (!stage) { throw new Error('Stage cannot be found.'); }
			
			_stage = stage;
			
			_modal = new Sprite();
			_modal.graphics.beginFill(0xffffff, .3);
			_modal.graphics.drawRect(0, 0, 10, 10);
			_modal.buttonMode = true;
			_modal.useHandCursor = false;
			
			popupHash =  new Dictionary(true);
			
			innited = true;
		}
		
		public static function set modal(value:Sprite):void { _modal = value; drawModal(); }
		public static function get modal():Sprite { return _modal; }
		
		public static function set showModal(value:Boolean):void { _showModal = value; drawModal(); }
		public static function get showModal():Boolean { return _showModal; }
		
		public static function addPopUp(popUp:DisplayObject, center:Boolean=true, showModal:Boolean = true):Boolean {
			init(popUp.stage);
			if (popupHash[popUp]) { return false; }
			
			if (popUp is Window) {
				popUp.addEventListener(Event.CLOSE, handelWindowClose, false, 0, true);
			}
			
			_showModal = showModal;
			popupHash[popUp] = true;
			_stage.addChild(popUp);
			popUpCount++;
			
			if (center) {
				popUp.x = _stage.stageWidth - popUp.width>>1;
				popUp.y = _stage.stageHeight - popUp.height>>1;
			}
			
			drawModal();
			return true;
		}
		
		public static function removePopUp(p_popUp:DisplayObject):void {
			if (popupHash[p_popUp]) {
				if (_stage.contains(p_popUp)) {
					_stage.removeChild(p_popUp);
					popUpCount--;
				}
				delete popupHash[p_popUp];
			}
			
			if (popUpCount == 0) {
				removeModal();
			}
		}
		
		protected static function removeModal():void {
			if (_stage.contains(_modal)) { _stage.removeChild(_modal); }
		}
		
		protected static function drawModal():void {
			removeModal();
			
			if (_showModal) {
				_modal.width = _stage.stageWidth;
				_modal.height = _stage.stageHeight;
				_stage.addChildAt(_modal, _stage.numChildren-1);
				_stage.addEventListener(Event.RESIZE, onStageResize, false, 0, true);
			} else {
				_stage.removeEventListener(Event.RESIZE, onStageResize);
			}
		}
		
		protected static function handelWindowClose(event:Event):void {
			removePopUp(event.target as DisplayObject);
		}
		
		protected static function onStageResize(event:Event):void {
			_modal.width = _stage.stageWidth;
			_modal.height = _stage.stageHeight;
			_modal.x = _modal.y = 0;
		}
	
	}
}