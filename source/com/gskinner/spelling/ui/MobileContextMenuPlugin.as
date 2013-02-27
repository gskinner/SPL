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
	
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	/**
	 * Creates a custom ContextMenu item for use on mobile devices.
	 * To attach this item use the SpellingHighter.menu property.
	 * To show the menu click your desired word.
	 * 
	 */
	public class MobileContextMenuPlugin extends AbstractSpellingUIPlugin {
		
		/** @private */
		protected var splMenu:MobileContextMenu;
		
		public function MobileContextMenuPlugin() {
			//For mobile make the default no suggestions string shorter.
			str_no_suggestions="No suggestions";
			
			super();
		}
		
		/** @private */
		override protected function setupListeners():void {
			if (textHighlighterPlugin == null || target == null) { return; }
			
			if (!splMenu) {
				splMenu = new MobileContextMenu();
			}
			
			target.addEventListener(MouseEvent.CLICK, buildMenu, false, -1, true);
			if (target.stage) {
				target.stage.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false, 0, true);
			}

		}

		/** @private */
		override protected function clear():void {
			if (!textHighlighterPlugin || !splMenu) return;

			splMenu.removeAll();
		}

		/** @private */
		protected function handleSuggestionSelect(event:SPLContextMenuEvent):void {
			replaceWord(event.target.caption);
			splMenu.hide();
		}
		
		/** @private */
		protected function handleAddToDictionary(event:SPLContextMenuEvent):void {
			addToDictonary(contextData.word);
			splMenu.hide();
		}
		
		/** @private */
		protected function handleRemoveFromDictionary(event:SPLContextMenuEvent):void {
			removeFromDictonary(contextData.word);
			splMenu.hide();
		}
		
		/** @private */
		protected function handleMouseDown(event:MouseEvent):void {
			if (splMenu.contains(event.target as DisplayObject)) {
				return;
			}
			splMenu.hide();
		}
		
		/** @private */
		protected function buildMenu(event:MouseEvent):void {
			clear();
			
			var hasItems:Boolean = false;
			var i:int;
			
			var data:ContextMenuData = getSpellingSuggestions(textHighlighterPlugin.getCharIndexFromEvent(event));
			
			if (data == null) { return; }
			
			if (data.state == ContextMenuData.BAD_WORD || data.state == ContextMenuData.NO_SUGGESTIONS) {
				splMenu.addItem( new SPLContextMenuItem(str_no_suggestions.split("%WORD%").join(data.word), false) );
				hasItems = true;
			} else if (data.state == ContextMenuData.CUSTOM_CORRECT_SPELLING && customDictionaryEditsEnabled) {
				hasItems = true;
				var removeItem:SPLContextMenuItem = new SPLContextMenuItem(str_remove_from_dictionary.split("%WORD%").join(data.word), false);
				removeItem.addEventListener(SPLContextMenuEvent.MENU_ITEM_SELECT, handleRemoveFromDictionary, false, 0, true);
				splMenu.addItem(removeItem);
			} else if (data.suggestions) {
				var l:uint = data.suggestions.length;
				for (i=0; i<l; i++) {
					var suggestion:String = data.suggestions[i];
					var suggestionItem:SPLContextMenuItem = new SPLContextMenuItem(suggestion);
					suggestionItem.addEventListener(SPLContextMenuEvent.MENU_ITEM_SELECT, handleSuggestionSelect, false, 0, true);
					splMenu.addItem(suggestionItem);
					hasItems = true;
				}
			}
			
			if (customDictionaryEditsEnabled && !(data.state == ContextMenuData.CUSTOM_CORRECT_SPELLING || data.state == ContextMenuData.CORRECT_SPELLING)) {
				var addCMItem:SPLContextMenuItem = new SPLContextMenuItem(str_add_to_dictionary.split("%WORD%").join(data.word),true);
				addCMItem.addEventListener(SPLContextMenuEvent.MENU_ITEM_SELECT,handleAddToDictionary,false,0,true);
				splMenu.addItem(addCMItem);
			}
			
			if (hasItems) { 
				splMenu.drawNow();
				
				var s:Stage = target.stage;
				var sb:Rectangle = s.getBounds(s);
				var mb:Rectangle = splMenu.getBounds(splMenu);
				var nx:int = mb.x = event.stageX+5;
				var ny:int = mb.y = event.stageY+5;
				
				if (mb.bottomRight.x > sb.bottomRight.x) { nx -= mb.bottomRight.x-sb.bottomRight.x; }				
				if (mb.bottomRight.y > sb.bottomRight.y) { ny -= mb.bottomRight.y-sb.bottomRight.y; }				
				
				splMenu.display(target.stage, nx, ny);
			}
		}
		
		/** @private */
		override protected function removeListeners():void {
			if (target) {
				target.removeEventListener(MouseEvent.CLICK, buildMenu);
			}
			
			if (target && target.stage) {
				target.stage.removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			}
		}
	}
}