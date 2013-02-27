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
	
	/**
	 * Contains utility methods for working with wordlists and dictionaries.
	 */
	public class SpellingUtils {
		
		/** @private */
		public function SpellingUtils() {
			throw(new Error("SpellingUtils cannot be instantiated"));
		}
		
		/**
		 * Merges two word lists. A word list is an array of strings sorted ascending case-insentive alphanumerically. This will
		 * not merge SpellingDictionary objects. Use this to merge loaded (or generated) word lists prior to using them
		 * in a SpellingDictionary.
		 *
		 * @param list1 An array of strings sorted ascending case-insentive alphanumerically.
		 * @param list2 An array of strings sorted ascending case-insentive alphanumerically.
		 *
		 * @return the merged array.
		 */
		public static function mergeWordLists(list1:Array,list2:Array):Array {
			var bigList:Array = (list1.length > list2.length) ? list1 : list2;
			var smallList:Array = (list1.length > list2.length) ? list2 : list1;
			
			var l:int = bigList.length;
			var hash:Object = {};
			for (var i:int=0;i<l;i++) {
				hash[bigList[i]] = true;
			}
			var list:Array = bigList.slice(0);
			
			// assemble combined list, removing duplicates:
			l = smallList.length;
			for (i=0;i<l;i++) {
				var n:String = smallList[i];
				if (hash[n]) { continue; }
				list.splice(findIndex(list,n),0,n);
			}
			return list;
		}
		
		/**
		 * Uses a simple halving algorithm to find a word's position in a list of words.
		 * The list must be sorted ascending case-insensitive alphanumerically.
		 *
		 * @param list1 An array of strings sorted ascending case-insentive alphanumerically.
		 * @param list2 An array of strings sorted ascending case-insentive alphanumerically.
		 *
		 * @return The word's index in the list, or the index it would be found at if it existed in the list.
		 */
		public static function findIndex(list:Array,word:String):int {
			var index1:int = 0;
			var index2:int = list.length;
			var index:int = index2>>1;
			// Case insensitive implementation. NOTE: much slower than case sensitive version.
			var lcWord:String = word.toLowerCase();
			if (index1 == index2) { return index1; }
			while (true) {
				var w:String  = (list[index] as String).toLowerCase();
				if (lcWord > w) {
					index1 = index;
				} else {
					index2 = index;
				}
				index = ((index2-index1)>>1)+index1;
				if (index == index1 || index == index2) {
					w = (list[index] as String).toLowerCase();
					return (w < lcWord) ? index+1 : index;
				}
			}
			return -1;
		}
		
	}
	
}