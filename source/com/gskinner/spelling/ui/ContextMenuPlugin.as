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
	
	import flash.events.ContextMenuEvent;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.utils.Dictionary;
	
	/**
	 * Plugin used to display the default ContextMenu used when checking spelling.
	 * If no menu is assigned this will be the default one used.
	 * 
	 */
	public class ContextMenuPlugin extends AbstractSpellingUIPlugin {
		
		/** @private */
		protected var menuItems:Dictionary;
		
		public function ContextMenuPlugin() {
			super();
		}
		
		/** @private */
		override protected function setupListeners():void {
			if (textHighlighterPlugin == null) { return; }
			
			if (textHighlighterPlugin.contextMenu == null) {
				var cm:ContextMenu = new ContextMenu();
				textHighlighterPlugin.contextMenu = cm;
			}
			
			//On Android this will always be null, so need to check after trying to create it.
			if (textHighlighterPlugin.contextMenu == null) { return; }
			
			textHighlighterPlugin.contextMenu.addEventListener(ContextMenuEvent.MENU_SELECT,buildContextMenu,false,-1,true);
		}
		
		/** @private */
		override protected function clear():void {
			if (menuItems == null) { return; }
			var cm:ContextMenu = textHighlighterPlugin.contextMenu as ContextMenu;
			if (cm == null) { throw(new TypeError("The SPL engine requires that the target's contextMenu be of type ContextMenu")); }
			var customItems:Array = cm.customItems;
			
			for (var i:uint=customItems.length; i>0; i--) {
				if (menuItems[customItems[i-1]]) {
					customItems.splice(i-1,1);
				}
			}
			cm.customItems = customItems;
			textHighlighterPlugin.contextMenu = cm;
			menuItems = null;
		}
		
		/** @private */
		protected function handleSuggestionSelect(evt:ContextMenuEvent):void {
			replaceWord(evt.target.caption);
		}
		
		/** @private */
		protected function handleAddToDictionary(evt:ContextMenuEvent):void {
			addToDictonary(contextData.word);
		}
		
		/** @private */
		protected function handleRemoveFromDictionary(evt:ContextMenuEvent):void {
			removeFromDictonary(contextData.word);
		}
		
		/** @private */
		protected function buildContextMenu(evt:ContextMenuEvent):void {
			// remove old custom items:
			clear();
			
			var i:uint;
			
			var cm:ContextMenu = textHighlighterPlugin.contextMenu as ContextMenu;
			var customItems:Array = cm.customItems;
			
			var data:ContextMenuData = getSpellingSuggestions(textHighlighterPlugin.getCharIndexUnderMouse());
			
			if (!data) { return; }
			
			var newItems:Array;
			var addCMItem:ContextMenuItem;
			
			if (data.state == ContextMenuData.BAD_WORD || data.state == ContextMenuData.NO_SUGGESTIONS) {
				newItems = [new ContextMenuItem(str_no_suggestions.split("%WORD%").join(data.word), false,false)];
			} else if (data.state == ContextMenuData.CORRECT_SPELLING || data.state == ContextMenuData.CUSTOM_CORRECT_SPELLING) {
				newItems = [new ContextMenuItem(str_spelling_is_correct.split("%WORD%").join(data.word)+"*",false,false)];
				if (customDictionaryEditsEnabled && data.state == ContextMenuData.CUSTOM_CORRECT_SPELLING) {
					var removeCMItem:ContextMenuItem = new ContextMenuItem(str_remove_from_dictionary.split("%WORD%").join(data.word),true);
					removeCMItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,handleRemoveFromDictionary,false,0,true);
					newItems.push(removeCMItem);
				}
			} else {
				newItems = [];
				for (i=0; i<data.suggestions.length; i++) {
					var suggestion:String = data.suggestions[i];
					var suggestionCMItem:ContextMenuItem = new ContextMenuItem(suggestion);
					suggestionCMItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,handleSuggestionSelect,false,0,true);
					newItems.push(suggestionCMItem);
				}
			}
			
			if (customDictionaryEditsEnabled && !(data.state == ContextMenuData.CUSTOM_CORRECT_SPELLING || data.state == ContextMenuData.CORRECT_SPELLING)) {
				addCMItem = new ContextMenuItem(str_add_to_dictionary.split("%WORD%").join(data.word),true);
				addCMItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,handleAddToDictionary,false,0,true);
				newItems.push(addCMItem);
			}
			
			// push in the new items:
			menuItems = new Dictionary(true);
			for (i=0; i<newItems.length; i++) {
				var item:ContextMenuItem = newItems[i] as ContextMenuItem;
				if (i == 0 && customItems.length > 0) { item.separatorBefore = true; }
				customItems.push(item);
				menuItems[item] = true;
			}
			
		}
		
		/** @private */
		override protected function removeListeners():void {
			if (textHighlighterPlugin && textHighlighterPlugin.contextMenu) {
				textHighlighterPlugin.contextMenu.removeEventListener(ContextMenuEvent.MENU_SELECT,buildContextMenu,false);
			}
		}
	}
}