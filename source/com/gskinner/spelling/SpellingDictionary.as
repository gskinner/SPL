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
	
	import com.gskinner.text.CharacterSet;
	import com.gskinner.text.StringPosition;
	
	import flash.events.EventDispatcher;
	
	/**
	 * Dispatched when the dictionary becomes active. This means all the words have been
	 * loaded and parsed. Typically this notifies all SPL components to begin highlighting.
	 *
	 * @eventType com.gskinner.spelling.SpellingDictionaryEvent.ACTIVE
	 */
	[Event(name="active", type="com.gskinner.spelling.SpellingDictionaryEvent")]
	/**
	 * Dispatched when the master word lists changes.
	 *
	 * @eventType com.gskinner.spelling.SpellingDictionaryEvent.CHANGED_MASTER_WORD_LIST
	 */
	[Event(name="changedMasterWordList", type="com.gskinner.spelling.SpellingDictionaryEvent")]
	/**
	 * Dispatched when the custom word list changes. This happens when the list is first loaded.
	 * To determine when the user changes the custom word list by adding and removing custom words
	 * use the addedCustomWord and removedCustomWord events.
	 *
	 * @eventType com.gskinner.spelling.SpellingDictionaryEvent.CHANGED_CUSTOM_WORD_LIST
	 */
	[Event(name="changedCustomWordList", type="com.gskinner.spelling.SpellingDictionaryEvent")]
	/**
	 * Dispatched when the user adds a custom word to the dictionary, usually by right-clicking
	 * misspelled words and correcting them.
	 *
	 * @eventType com.gskinner.spelling.SpellingDictionaryEvent.ADDED_CUSTOM_WORD
	 */
	[Event(name="addedCustomWord", type="com.gskinner.spelling.SpellingDictionaryEvent")]
	/**
	 * Dispatched when the user removes a custom word from the dictionary, usually by right-clicking
	 * words that have been added, and removing them.
	 *
	 * @eventType com.gskinner.spelling.SpellingDictionaryEvent.REMOVED_CUSTOM_WORD
	 */
	[Event(name="removedCustomWord", type="com.gskinner.spelling.SpellingDictionaryEvent")]
	
	
	/**
	 * SpellingDictionary provides spell checking and spelling suggestion services for ActionScript 3 classes.
	 * It is built to be highly modular and extensible, with built-in support for custom word lists.
	 */
	public class SpellingDictionary extends EventDispatcher {
		
		/**
		 * Normally you would use getInstance() to access a single global SpellingDictionary instance so that all changes to your spelling settings are
		 * reflected universally. In some cases you may wish to have multiple SpellingDictionary instances (ex. checking both English and French in different
		 * elements of the same application). In this case, you can set allowInstantiation to true and instantiate SpellingDictionary normally
		 * (with new SpellingDictionary). Note that the Flex and Flash components will always use the global instance by default.
		 *
		 * See SpellingHighlighter.spellingDictionary and SpellingHighlighter.defaultSpellingDictionary for more info.
		 */
		public static var allowInstantiation:Boolean = false;
		
		/** @private */
		protected static var _instance:SpellingDictionary;
		
		/**
		 * Returns the instance of SpellingDictionary.
		 *
		 * @return The instance of SpellingDictionary.
		 */
		public static function getInstance():SpellingDictionary {
			if (_instance == null) {
				var tmp:Boolean = allowInstantiation;
				allowInstantiation = true;
				_instance = new SpellingDictionary();
				allowInstantiation = tmp;
			}
			return _instance;
		}
		
		/**
		 * Represents the master list option when requesting word lists
		 */
		public static const MASTER_LIST:uint = 1;
		
		/**
		 * Represents the custom list option when requesting word lists
		 */
		public static const CUSTOM_LIST:uint = 2;
		
		/**
		 * Represents the combined custom ans master word lists option when requesting word lists
		 */
		public static const COMBINED_LIST:uint = 3;
		
		/** @private */
		protected var masterList:Array;
		
		/** @private */
		protected var masterHash:Object;
		
		/** @private */
		protected var customList:Array;
		
		/** @private */
		protected var customHash:Object;
		
		/** @private */
		protected var combinedList:Array;
		
		/** @private */
		protected var combinedHash:Object;
		
		/** @private */
		protected var dontSuggestList:Array;
		
		/** @private */
		protected var dontSuggestHash:Object;
		
		/**
		 * Ignores words that have all characters capitalized when checking spelling.
		 */
		public var ignoreAllCaps:Boolean=true;
		
		/**
		 * Ignores words with mixed capitalization when checking spelling. Exclusive of ignoreAllCaps and ignoreInitialCaps.
		 */
		public var ignoreMixedCaps:Boolean=true;
		
		/**
		 * Ignores words with only an initial capitalized letter when checking spelling.
		 */
		public var ignoreInitialCaps:Boolean=false;
		
		/**
		 * If true, only words starting with the same initial character will be suggested, but spelling suggestion performance increases by roughly 10x.
		 */
		public var useFastMode:Boolean=false;
		
		/**
		 * Constructs a SpellingDictionary instance. Normally you would use getInstance() to access a single global SpellingDictionary instance so that all changes to your spelling settings are
		 * reflected universally. In some cases you may wish to have multiple SpellingDictionary instances (ex. checking both English and French in different
		 * elements of the same application). In this case, you can set SpellingDictionary.allowInstantiation to true and instantiate SpellingDictionary normally
		 * (with new SpellingDictionary). See SpellingHighlighter.spellingDictionary and SpellingHighlighter.defaultSpellingDictionary for more info.
		 */
		public function SpellingDictionary() {
			if (!allowInstantiation) {
				throw("SpellingDictionary is not normally instantiated directly, use SpellingDictionary.getInstance or set SpellingDictionary.allowInstantiation to true.");
			}
			setCustomWordList([]);
			dontSuggestWordList = [];
		}
		
		/**
		 * Indicates whether the SpellingDictionary is active – that is, ready to carry out spelling checks
		 * and generate spelling suggestions. Currently this is dependant only on whether the SpellingDictionary
		 * has a master word list set. A SpellingDictionaryEvent.ACTIVE event will be dispatched when this value
		 * changes.
		 */
		public function get active():Boolean {
			return (masterList != null);
		}
		
		/**
		 * A list of dictionary words to omit when making spelling suggestions. This can be used for omitting
		 * swear words and other inappropriate words from suggestion lists.
		 */
		public function get dontSuggestWordList():Array {
			return dontSuggestList.slice(0);
		}
		/** @private */
		public function set dontSuggestWordList(wordList:Array):void {
			dontSuggestList = (wordList == null) ? [] : wordList.slice(0);
			dontSuggestHash = listToHash(dontSuggestList);
		}
		
		/**
		 * Sets the list of default "dictionary" words to use when spell checking and making suggestions.
		 * The array of lowercase words must be sorted ascending alphanumeric before passing it to this method.
		 * Note that this is a processor intensive operation.
		 *
		 * @param wordList An array of strings sorted ascending alphanumeric to use as the master word list.
		 */
		public function setMasterWordList(wordList:Array):void {
			var wasActive:Boolean = active;
			masterList = wordList;
			masterHash = listToHash(wordList);
			combineLists();
			dispatchEvent(new SpellingDictionaryEvent(SpellingDictionaryEvent.CHANGED_MASTER_WORD_LIST));
			if (wasActive != active) { dispatchEvent(new SpellingDictionaryEvent(SpellingDictionaryEvent.ACTIVE)); }
		}
		
		/**
		 * Sets the list of custom (usually user defined) words to use when spell checking and making suggestions.
		 * The array of lowercase words must be sorted ascending alphanumeric before passing it to this method.
		 * Note that this is a processor intensive operation.
		 *
		 * @param wordList An array of lowercase strings sorted ascending alphanumeric to use as the custom word list.
		 */
		public function setCustomWordList(wordList:Array=null):void {
			if (wordList == null) { wordList = []; }
			customList = wordList;
			customHash = listToHash(wordList);
			combineLists();
			dispatchEvent(new SpellingDictionaryEvent(SpellingDictionaryEvent.CHANGED_CUSTOM_WORD_LIST));
		}
		
		/**
		 * Returns the specified list of words (in alphabetical order), or a subset thereof if startWord or endWord are specified.
		 * If only startWord is specified it will return a subset beginning with the startWord (or the next word in alphanumeric order),
		 * to the end of the list. Likewise, if only endWord is specified, it will return all words in the list from the start of the list to
		 * the end word (or the previous word in alphanumeric order).
		 *
		 * @param type The word list type to return. One of SpellingDictionary.COMBINED_LIST, CUSTOM_LIST, or MASTER_LIST
		 * @param startWord If not null, will return a subset of the word list beginning with the specified word. Does not have a significant impact on performance.
		 * @param endWord If not null, will return a subset of the word list ending with the specified word. Does not have a significant impact on performance.
		 *
		 * @return The specified list of words.
		 */
		public function getWordList(type:int=COMBINED_LIST,startWord:String=null,endWord:String=null):Array {
			var list:Array = (type == COMBINED_LIST) ? combinedList : (type == MASTER_LIST) ? masterList : customList;
			
			// catch error conditions:
			if (list == null ) { return null; }
			
			if (startWord == null && endWord == null) { return list; }
			// word range:
			var startIndex:uint = (startWord == null) ? 0 : SpellingUtils.findIndex(list,startWord);
			var endIndex:uint = (endWord == null) ? list.length : SpellingUtils.findIndex(list,endWord);
			if (list[endIndex] == endWord) { endIndex++; }
			return list.slice(startIndex,endIndex);
		}
		
		/**
		 * Returns the specified hash of words, or a subset thereof if startWord or endWord are specified.
		 * If only startWord is specified it will return a subset beginning with the startWord (or the next word in alphanumeric order),
		 * to the end of the list. Likewise, if only endWord is specified, it will return all words in the list from the start of the list to
		 * the end word (or the previous word in alphanumeric order). Note that returning subsets is more processor intensive than full hashes.
		 *
		 * The hash uses the word as the key, and true as the value. This allows you to carry out tests such as:
		 * if (wordHash["myWord"]) { ... }
		 *
		 * @param type The word list type to return. One of SpellingDictionary.COMBINED_LIST, CUSTOM_LIST, or MASTER_LIST
		 * @param startWord If not null, will return a subset of the word list beginning with the specified word. Specifying a non-null value decreases performance slightly.
		 * @param endWord If not null, will return a subset of the word list ending with the specified word. Specifying a non-null value decreases performance slightly.
		 *
		 * @return The specified word hash (object) with words as keys, and true as the value.
		 */
		public function getWordHash(type:int=COMBINED_LIST,startWord:String=null,endWord:String=null):Object {
			// catch error conditions:
			if (startWord == null && endWord == null) {
				return (type == COMBINED_LIST) ? combinedHash : (type == MASTER_LIST) ? masterHash : customHash;
			} else {
				return listToHash(getWordList(type,startWord,endWord));
			}
		}
		
		/**
		 * Adds a word to the custom word list. If the word does not already exist in the combined list it will be added to it.
		 * If the word does not already exist in the custom word list a SpellingDictionaryEvent of type ADDED_CUSTOM_WORD
		 * is dispatched.
		 *
		 * @param word The word to add.
		 */
		public function addCustomWord(word:String):void {
			word = word.toLowerCase();
			if (!combinedHash[word]) {
				combinedHash[word] = true;
				combinedList.splice(SpellingUtils.findIndex(combinedList,word),0,word);
			}
			if (!customHash[word]) {
				customHash[word] = true;
				var index:int = SpellingUtils.findIndex(customList,word);
				customList.splice(index,0,word);
				dispatchEvent(new SpellingDictionaryEvent(SpellingDictionaryEvent.ADDED_CUSTOM_WORD,word,index));
			}
		}
		
		/**
		 * Removes a word from the custom word list. If the word does not exist in the master word list, it will also be removed
		 * from the combined list. If the word existed in the custom word list a SpellingDictionaryEvent of type REMOVED_CUSTOM_WORD
		 * is dispatched.
		 *
		 * @param word The word to remove.
		 */
		public function removeCustomWord(word:String):void {
			word = word.toLowerCase();
			if (!customHash[word]) { return; }
			delete(customHash[word]);
			var index:int = SpellingUtils.findIndex(customList,word);
			customList.splice(index,1);
			if (!masterHash[word]) {
				delete(combinedHash[word]);
				combinedList.splice(SpellingUtils.findIndex(combinedList,word),1);
			}
			dispatchEvent(new SpellingDictionaryEvent(SpellingDictionaryEvent.REMOVED_CUSTOM_WORD,word,index));
		}
		
		/**
		 * Returns an array of suggested correct spellings for the specified word. This is a very processor intensive operation
		 * taking approximately 100-400ms, or 15-40ms with useFastMode enabled on a 2ghz processor.
		 *
		 * @param word The word to return spelling suggestions for.
		 * @param maxSuggestions The maximum suggestions to return (up to 100). This value does not significantly impact performance.
		 * @param tolerance Specifies how tolerant the algorithm should be when determining suggestions. 0 will only match the exact word, 1 will match almost anything. Increasing this number will decrease performance.
		 * @param type Indicates which word list to use when finding suggestions. One of SpellingDictionary.COMBINED_LIST, CUSTOM_LIST, or MASTER_LIST.
		 * @param useFastMode Boolean value allowing you to override the useFastMode property for specific calls to this method. Defaults to the value of the useFastMode property if not specified.
		 *
		 * @return An array of suggested spellings ordered by descending match value (best matches first).
		 */
		public function getSpellingSuggestions(word:String,maxSuggestions:uint=5,tolerance:Number=0.5,type:int=COMBINED_LIST,useFastMode:*=null):Array {
			//var time:uint = getTimer();
			
		// START special cases
			var wordUC:Boolean = (word.toUpperCase() == word);
			var char0UC:Boolean = (word.charAt(0).toUpperCase() == word.charAt(0));
		// END special cases
			
			// set up variables:
			useFastMode = (useFastMode == null) ? this.useFastMode : Boolean(useFastMode);
			var s:String = word.toLowerCase();
			var arr:Array = []; // stores full list of matches
			var ret:Array = []; // array to return (only the top N matches)
			var sl:int = s.length; // length of s
			var nl:int; // length of n
			var l:int; // length of longest word
			var si:String; // ith character of s
			// fast mode gets word hash containing just words with the same leading character:
			var wl:Array = (useFastMode) ? getWordList(type,s.charAt(0),s.charAt(0)+"~") : getWordList(type);
			var i0:int = (useFastMode) ? 1 : 0; // index of first char to compare (don't need to compare first char in fast mode)
			var tol:int = (sl+2.5)*(1.5*tolerance); // tolerance for deviation.
			var sc:int; // score
			var os:int; // char index offset
			
			// iterate through all words in sub dictionary, and apply matching logic:
			var wll:int = wl.length; // wordlist length
			for (var wi:int=0;wi<wll;wi++) {
				var n:String = wl[wi];
				if (dontSuggestHash[n]) { continue; }
				nl = n.length;
				if (nl>sl) {
					l = nl;
					sc = nl-sl;
				} else {
					l = sl;
					sc = sl-nl;
				}
				
				if (sc<<2 > tol) { continue; }
				os = sc = 0;
				
				for (var i:int=i0; i < l && sc <= tol; i++) {
					si = s.charAt(i);
					var ni:String = n.charAt(i+os);
					if (ni == si) { }
					else if (i+os<l-1 && n.charAt(i+1+os) == si) {
						if (ni == s.charAt(i+1)) { sc+=3; i++; } // swap
						else { sc+=3; os++; } // ommission
					}
					else if (i<l-1 && ni == s.charAt(i+1)) { sc+=3; os--; } // insertion
					else { sc += 4; }
				}
				
				if (sc <= tol) {
					if (os < 0 && n.charAt(nl-1) != s.charAt(sl-1)) { sc += 4; }
					if (sc > tol) { continue; }
					arr.push({str:n,sc:sc});
					if (arr.length == 300) { break; }
				}
			}
			arr.sortOn(["sc","str"],[Array.NUMERIC,0]);
			l = Math.min(arr.length,maxSuggestions);
			for (i=0;i<l;i++) {
				var str:String = arr[i].str;
				
				// START special cases
				if (wordUC) { str = str.toUpperCase(); }
				else if (char0UC) { str = str.charAt(0).toUpperCase()+str.substr(1); }
				// END special cases
				
				ret.push(str);
			}
			//trace("find suggestions ("+ret.length+" of "+arr.length+") for "+word+": "+(getTimer()-time)+"ms");
			return ret;
		}
		
		/**
		 * Returns an Array containing true in all indexes of the original array where the word is spelled correctly, and false where the word is misspelled
		 *
		 * @param wordList An array of words to check spelling on.
		 * @param type Indicates which word list to use when checking spelling. One of SpellingDictionary.COMBINED_LIST, CUSTOM_LIST, or MASTER_LIST.
		 *
		 * @return An Array containing true in all indexes of the original array where the word is spelled correctly, and false where the word is misspelled
		 */
		public function checkWordList(wordList:Array,type:int=COMBINED_LIST):Array {
			var l:int = wordList.length;
			var map:Array = [];
			for (var i:int=0; i<l; i++) {
				map[i] = checkWord(wordList[i],type);
			}
			return map;
		}
		
		/**
		 * Returns an Array containing all of the words that are misspelled in the specified string.
		 *
		 * @param string The string to spell check.
		 * @param type Indicates which word list to use when checking spelling. One of SpellingDictionary.COMBINED_LIST, CUSTOM_LIST, or MASTER_LIST.
		 *
		 * @return an Array containing all of the words that are misspelled
		 */
		public function checkString(string:String,type:int=COMBINED_LIST):Array {
			var badWordList:Array = [];
			var i:int = 0;
			while (true) {
				var wordObj:StringPosition = getNextMisspelledWord(string,i,type);
				if (wordObj == null) { break; }
				badWordList.push(wordObj);
				i = wordObj.endIndex+1;
			}
			return badWordList;
		}
		
		/**
		 * Returns a StringPosition instance indicating the position of the next misspelled word in the string. If no
		 * misspelled word is found, it will return null.
		 *
		 * @param string The string to spell check.
		 * @param fromIndex The index to begin checking from.
		 * @param type Indicates which word list to use when checking spelling. One of SpellingDictionary.COMBINED_LIST, CUSTOM_LIST, or MASTER_LIST.
		 *
		 * @return a StringPosition object indicating the position of the next misspelled word, or null if no misspelled word is found.
		 */
		public function getNextMisspelledWord(str:String,fromIndex:uint=0,type:int=COMBINED_LIST):StringPosition {
			
			var wc:Array = CharacterSet.wordCharSet;
			var ic:Array = CharacterSet.innerWordCharSet;
			var xc:Array = CharacterSet.invalidWordCharSet;
			
			var l:int = str.length;
			
			var wbi:int = 0; // wordBeginIndex
			var i:int = fromIndex;
			var mode:int=0; // 0=seekWord, 1=inWord, 2=badWord, 3=foundWord
			
			while(i<l) {
				var c:int = str.charCodeAt(i);
				if (mode == 0 && (wc[c] || xc[c])) {
					wbi = i;
					mode = (wc[c]) ? 1 : 2;
				} else if (mode > 0 && !wc[c]) {
					if (ic[c]) {
						// check the next character
						if (!wc[str.charCodeAt(i+1)]) {
							// end of word:
							mode = (mode == 1) ? 3 : 0;
						}
					} else {
						mode = (xc[c]) ? 2 : (mode == 1) ? 3 : 0;
					}
				}
				if (mode == 3) {
					var word:String = str.substring(wbi,i)
					if (!checkWord(word)) {
						return new StringPosition(wbi,i,word);
					}
					mode = 0;
				}
				i++;
			}
			if (mode == 1) {
				word = str.substring(wbi)
				if (!checkWord(word)) {
					return new StringPosition(wbi,i,word);
				}
			}
			return null;
		}
		
		/**
		 * Returns a Boolean indicating whether the specified word is spelled correctly.
		 *
		 * @param string The word to spell check.
		 * @param type Indicates which word list to use when checking spelling. One of SpellingDictionary.COMBINED_LIST, CUSTOM_LIST, or MASTER_LIST.
		 *
		 * @return A Boolean indicating whether the specified word is spelled correctly.
		 */
		public function checkWord(word:String,type:int=COMBINED_LIST):Boolean {
			if (word.length < 2) { return true; }
			var dict:Object = getWordHash(type);
			var lcStr:String;
			if (dict[word] || dict[(lcStr = word.toLowerCase())]) { return true; }
			if (ignoreInitialCaps && word.charAt(0) != lcStr.charAt(0)) { return true; }
			
			if (ignoreAllCaps || ignoreMixedCaps) {
				var ucStr:String = word.toUpperCase();
				if (ignoreAllCaps && word == ucStr) { return true; }
				if (ignoreMixedCaps && word.substr(1) != lcStr.substr(1) && word != ucStr) { return true; }
			}
			
			if (!ignoreAllCaps && word == ucStr && dict[word.substr(0, 1) + lcStr.substr(1, lcStr.length)]) { return true; } //Word is all uppercase, but dictionary could have first letter uppercase
			
			return false;
		}
		
		/**
		 * Combines the master and custom word lists into the combined list, and generates the combinedHash.
		 */
		protected function combineLists():void {
			if (masterList == null && customList == null) {
				combinedList = null;
			} else if (masterList == null) {
				combinedList = customList.slice(0);
			} else if (customList == null) {
				combinedList = masterList.slice(0);
			} else {
				combinedList = masterList.slice(0);
				var coL:Array = combinedList;
				var cuH:Object = customHash;
				var maH:Object = masterHash;
				// assemble combined list, removing duplicates:
				for (var n:String in cuH) {
					if (maH[n]) { continue; }
					// this is a lot faster than doing a sort at the end:
					coL.splice(SpellingUtils.findIndex(coL,n),0,n);
				}
			}
			combinedHash = listToHash(combinedList);
		}
		
		/**
		 * Returns a hash table with words as keys and true as the values from a list of words.
		 */
		protected function listToHash(list:Array):Object {
			if (list == null) { return null; }
			var hash:Object = {};
			var l:int = list.length;
			while (l--) {
				hash[list[l]] = true;
			}
			return hash;
		}
		
	}
	
}