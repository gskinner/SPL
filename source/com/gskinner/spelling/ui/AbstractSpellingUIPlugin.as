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
	
	import com.gskinner.spelling.SpellingDictionary;
	import com.gskinner.text.CharacterSet;
	import com.gskinner.text.ITextHighlighterPlugin;
	
	import flash.events.EventDispatcher;
	import flash.utils.Timer;

	public class AbstractSpellingUIPlugin extends EventDispatcher {
		
		// locale strings:
		/**
		 * Locale string used to generate context menu options.
		 */
		public static var str_add_to_dictionary:String="Add to my dictionary";
		
		/**
		 * Locale string used to generate context menu options.
		 */
		public static var str_remove_from_dictionary:String="Remove from my dictionary";
		
		/**
		 * Locale string used to generate context menu options.
		 */
		public static var str_spelling_is_correct:String="Spelling is correct";
		
		/**
		 * Locale string used to generate context menu options. %WORD% will be
		 * replaced with the related word.
		 */
		public static var str_no_suggestions:String="No suggestions for: %WORD%";
		
		/** @private */
		protected var contextData:Object; // stores temporary data during a right click.
		
		/** @private */
		protected var validateTimer:Timer;
		
		/** @private */
		protected var _enabled:Boolean;
		
		/**
		 * The current spelling plugin to be used by this menu.
		 * Set by SpellingHighlighter
		 * 
		 */
		public var textHighlighterPlugin:ITextHighlighterPlugin;
		
		/**
		 * The current spelling dictionary to be used by this menu.
		 * Set by SpellingHighlighter
		 * 
		 */
		public var spellingDictionary:SpellingDictionary;
		
		/**
		 * Shows or hide the ability to add custom words.
		 * Set by SpellingHighlighter
		 * 
		 */
		public var customDictionaryEditsEnabled:Boolean;
		
		/**
		 * The current target this item should be attached to.
		 * This is used by the MobileContextMenuPlugin.
		 * 
		 * Set by SpellingHighlighter
		 * 
		 */
		public var target:Object;
		
		public function AbstractSpellingUIPlugin() {
			super();
		}
		
		/**
		 * Enables or disables this menu.
		 * 
		 */
		public function set enabled(value:Boolean):void {
			_enabled = value;
			if (_enabled) {
				setupListeners();
			} else {
				removeListeners();
			}
		}
		
		/** @private */
		protected function setupListeners():void { }
		
		/** @private */
		protected function removeListeners():void { }
		
		/** @private */
		protected function clear():void { }
		
		/** @private */
		protected function getSpellingSuggestions(charIndex:int):ContextMenuData {
			// run through all text:
			var wc:Array = CharacterSet.wordCharSet;
			var ic:Array = CharacterSet.innerWordCharSet;
			var xc:Array = CharacterSet.invalidWordCharSet;
			
			var cmd:ContextMenuData = new ContextMenuData();
			
			var i:uint;
			
			var dict:Object = spellingDictionary.getWordHash(SpellingDictionary.COMBINED_LIST);
			
			// first we need to find the word that was clicked:
			var txt:String = textHighlighterPlugin.text;
			if (charIndex == -1 || !(wc[txt.charCodeAt(charIndex)] || ic[txt.charCodeAt(charIndex)] || xc[txt.charCodeAt(charIndex)])) {
				// nothing. not a word.
				return null;
			}
			
			// find end of word:
			i = charIndex;
			var l:uint = txt.length;
			var endIndex:int=-1;
			var badWord:Boolean = false;
			while (i<l) {
				var c:uint = txt.charCodeAt(i)
				if (ic[c]) {
					if (!wc[txt.charCodeAt(i+1)]) {
						endIndex = i;
						break;
					}
				} else if (xc[c]) {
					badWord = true;
				} else if (!wc[c]) {
					endIndex = i;
					break;
				}
				i++;
				if (i==l) { endIndex = l; }
			}
			// find start of word:
			i = charIndex;
			var beginIndex:int=-1;
			while (i>0) {
				c = txt.charCodeAt(i)
				if (ic[c]) {
					if (!wc[txt.charCodeAt(i-1)]) {
						beginIndex = i+1;
						break;
					}
				} else if (xc[c]) {
					badWord = true;
				} else if (!wc[c]) {
					beginIndex = i+1;
					break;
				}
				i--;
				if (i==0) { beginIndex = 0; }
			}
			
			var word:String = txt.substring(beginIndex,endIndex);
			contextData = {beginIndex:beginIndex,endIndex:endIndex,word:word};
			cmd.word = word;
			
			if (badWord) {
				cmd.state = ContextMenuData.BAD_WORD;
			} else if (spellingDictionary.checkWord(word)) {
				if (spellingDictionary.getWordHash(SpellingDictionary.CUSTOM_LIST)[word.toLowerCase()]) {
					cmd.state = ContextMenuData.CUSTOM_CORRECT_SPELLING;
				} else {
					cmd.state = ContextMenuData.CORRECT_SPELLING;
				}
			} else {
				var suggestions:Array = spellingDictionary.getSpellingSuggestions(word,5,0.6);
				if (suggestions.length == 0) {
					cmd.state = ContextMenuData.NO_SUGGESTIONS;
				} else {
					cmd.suggestions = suggestions.concat();
				}
			}
			
			return cmd;
		}
		
		/** @private */
		protected function replaceWord(word:String):void {
			var txt:String = textHighlighterPlugin.text;
			textHighlighterPlugin.replaceText(contextData.beginIndex, contextData.endIndex, word);
			textHighlighterPlugin.setSelection(contextData.beginIndex,contextData.beginIndex+word.length);
			textHighlighterPlugin.dispatchChangeEvent();
		}
		
		/** @private */
		protected function addToDictonary(word:String):void {
			spellingDictionary.addCustomWord(word);
		}
		
		/** @private */
		protected function removeFromDictonary(word:String):void {
			spellingDictionary.removeCustomWord(word);
		}
	}
}