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
package com.gskinner.spelling {
	
	import flash.net.SharedObject;
	
	/**
	 * CustomWordListLSO works with SpellingDictionary to support saving and loading custom word lists
	 * from Local Shared Objects. While useful on its own, it's also intended as a demonstration of
	 * how to implement different custom dictionary systems.
	 */
	public class CustomWordListLSO {
		
		public static const DEFAULT_LSO_NAME:String = "_com_gskinner_spelling_customDictionary";
		
		/** @private */
		protected var sharedObject:SharedObject;
		
		/** @private */
		protected var lsoName:String;
		
		/** @private */
		protected var spellingDictionary:SpellingDictionary;
		
		/**
		 * Creates a new instance of CustomWordListLSO.
		 *
		 * @param spellingDictionary The SpellingDictionary instance to use this custom word list manager with.
		 * @param lsoName The name of the local shared object that holds the custom word list. This will default to the value of DEFAULT_LSO_NAME ("_com_gskinner_spelling_customDictionary") if not specified.
		 *
		 */
		public function CustomWordListLSO(spellingDictionary:SpellingDictionary, lsoName:String=null) {
			this.spellingDictionary = spellingDictionary;
			initCustomList(lsoName);
			
			// listen for changes to the custom word list:
			spellingDictionary.addEventListener(SpellingDictionaryEvent.ADDED_CUSTOM_WORD,handleCustomListChange);
			spellingDictionary.addEventListener(SpellingDictionaryEvent.REMOVED_CUSTOM_WORD,handleCustomListChange);
			spellingDictionary.addEventListener(SpellingDictionaryEvent.CHANGED_CUSTOM_WORD_LIST,handleCustomListChange);
		}
		
		/**
		 * Clears the custom word list.
		 */
		public function clearWordList():void {
			spellingDictionary.setCustomWordList([]);
		}
		
		/**
		 * @private
		 * Initializes the local shared library.
		 */
		protected function initCustomList(lsoName:String=null):void {
			lsoName = (lsoName) ? lsoName : DEFAULT_LSO_NAME;
			sharedObject = SharedObject.getLocal(lsoName,"/");
			if (sharedObject == null || sharedObject.data.customList == null) {
				spellingDictionary.setCustomWordList([]);
			} else {
				spellingDictionary.setCustomWordList(sharedObject.data.customList as Array);
			}
		}
		
		/**
		 * Called when the custom word list changes. Saves the modified list back to the LSO.
		 */
		protected function handleCustomListChange(evt:SpellingDictionaryEvent):void {
			sharedObject.data.customList = spellingDictionary.getWordList(SpellingDictionary.CUSTOM_LIST);
			sharedObject.flush();
		}
	}
}