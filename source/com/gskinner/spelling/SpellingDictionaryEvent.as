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
	
	import flash.events.Event;
	
	/**
	 * Event class for SpellingDictionary events.
	 */
	public class SpellingDictionaryEvent extends Event {
		
		/**
		 * Indicates that a new word was added to the custom word list.
		 */
		public static const ADDED_CUSTOM_WORD:String = "addedCustomWord";
		
		/**
		 * Indicates that a new word was removed from the custom word list.
		 */
		public static const REMOVED_CUSTOM_WORD:String = "removedCustomWord";
		
		/**
		 * Indicates that custom word list was changed completely. This is currently only when
		 * setCustomWordList is called.
		 */
		public static const CHANGED_CUSTOM_WORD_LIST:String = "changedCustomWordList";
		
		/**
		 * Indicates that master word list was changed completely. This is currently only when
		 * setMasterWordList is called.
		 */
		public static const CHANGED_MASTER_WORD_LIST:String = "changedMasterWordList";
		
		/**
		 * Dispatched from SpellingDictionary when it's active property changes.
		 */
		public static const ACTIVE:String = "active";
		
		/** @private */
		protected var _word:String;
		
		/** @private */
		protected var _index:int;
		
		/**
		 * Creates a new SpellingDictionaryEvent object.
		 *
		 * @param type The event type.
		 * @param word A string indicating the word that was added or removed, if applicable.
		 * @param index The list index of the word that was added or removed, if applicable.
		 */
		public function SpellingDictionaryEvent(type:String,word:String=null,index:int=-1):void {
			super(type,false,false);
			_word = word;
			_index = index;
		}
		
		/**
		 * A string indicating the word related to this event, or null.
		 */
		public function get word():String {
			return _word;
		}
		
		/**
		 * The list index related to this event, or -1.
		 */
		public function get index():int {
			return _index;
		}
		
		/**
		 * Creates a new SpellingDictionaryEvent object with the same properties as this one.
		 *
		 * @return A clone of this SpellingDictionaryEvent object.
		 */
		override public function clone():Event {
			return new SpellingDictionaryEvent(type,_word,_index);
		}
		
		/**
		 * Returns a string representing this SpellingDictionaryEvent object.
		 *
		 * @return A string representing this SpellingDictionaryEvent object.
		 */
		override public function toString():String {
			return super.toString();
		}
	}
	
}