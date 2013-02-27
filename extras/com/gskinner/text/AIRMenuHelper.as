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
	
	import flash.events.ContextMenuEvent;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.utils.Dictionary;
	import flash.text.TextField;
	import flash.desktop.NativeApplication;
	
	/**
	* AIRMenuHelper adds standard text editing context menu items when using SPL with Adobe AIR.
	* This includes Cut, Copy, Paste, and Select All.
	**/
	
	public class AIRMenuHelper {
		static public const EDIT_MENU_CAPTIONS:Array = ["Cut","Copy","Paste","Select All"];
		
	// private properties
		protected var _target:TextField;
		protected var customItemHash:Object;
		
	// constructor
		/**
		* Creates an instance of AIRMenuHelper.
		*
		* @param target The text field to target. For targetting nested textfields in components, you can use the .textField property of a SpellingHighlighter after setting the .target property.
		**/
		public function AIRMenuHelper(target:TextField) {
			_target = target;
			customItemHash = {};
			for each (var n:String in EDIT_MENU_CAPTIONS) {
				var cmi:ContextMenuItem = new ContextMenuItem(n);
				cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,handleItemSelect,false,0,true);
				customItemHash[n] = cmi;
			}
			apply();
		}
		
	// public methods
		/**
		* Re-applies the context menu changes. Useful if you assign a new context menu object to the target text field.
		**/
		public function apply():void {
			if (_target == null) { return; }
			var cm:ContextMenu = _target.contextMenu as ContextMenu;
			cm = (cm == null) ? new ContextMenu() : cm;
			cm.addEventListener(ContextMenuEvent.MENU_SELECT,buildContextMenu,false,-2,true);
			
			var customItems:Array = cm.customItems;
			
			// remove old menu items if they exist:
			for (var i:int=customItems.length-1; i>=0; i--) {
				var cmi:ContextMenuItem = customItems[i];
				if (customItemHash[cmi.caption] == cmi) {
					customItems.splice(i,1);
				}
			}
			
			// add them back in:
			for (i=0; i<EDIT_MENU_CAPTIONS.length; i++) {
				customItems.push(customItemHash[EDIT_MENU_CAPTIONS[i]]);
			}
			
			_target.contextMenu = cm;
		}
		
	// private methods
		protected function buildContextMenu(evt:ContextMenuEvent):void {
			var hasSelection:Boolean = (_target.stage.focus == _target) && (_target.selectionBeginIndex < _target.selectionEndIndex);
			customItemHash["Cut"].enabled = hasSelection;
			customItemHash["Copy"].enabled = hasSelection;
		}
		
		protected function handleItemSelect(evt:ContextMenuEvent):void {
			_target.stage.focus = _target;
			switch (evt.target.caption) {
				case "Cut": NativeApplication.nativeApplication.cut(); break;
				case "Copy": NativeApplication.nativeApplication.copy(); break;
				case "Paste": NativeApplication.nativeApplication.paste(); break;
				case "Select All": NativeApplication.nativeApplication.selectAll(); break;
			}
		}
		
	}
	
}