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
	
	/**
	 * CharacterSet provides data sets representing word characters.
	 * You can change these values at run-time to support different lanugages.
	 * This is primarily intended for use by TextHighlighter and SpellingDictionary.
	 */
	public class CharacterSet {
		
		/**
		 * A string containing the default roman word characters.
		 */
		public static const DEFAULT_WORD_CHARS:String = "abcdefghijklmnopqrstuvwxyzàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿß";
		
		/**
		 * A string containing the default roman inner word characters.
		 * The default characters are: '’
		 */
		public static const DEFAULT_INNER_WORD_CHARS:String = "'’";
		
		/**
		 * A string containing the default roman invalid word characters.
		 */
		public static const DEFAULT_INVALID_WORD_CHARS:String = "0123456789";
		
		/** @private */
		private static var _wordCharSet:Array;
		
		/** @private */
		private static var _innerWordCharSet:Array;
		
		/** @private */
		private static var _invalidWordCharSet:Array;
		
		/** @private */
		private static var _wordChars:String = DEFAULT_WORD_CHARS;
		
		/** @private */
		private static var _innerWordChars:String = DEFAULT_INNER_WORD_CHARS;
		
		/** @private */
		private static var _invalidWordChars:String = DEFAULT_INVALID_WORD_CHARS;
		
		/** @private */
		public function CharacterSet() {
			throw(new Error("CharacterSet cannot be instantiated"));
		}
		
	// public getter / setters
		/**
		 * An array having true at each index corresponding to a word character code (lower and upper case).
		 */
		public static function get wordCharSet():Array {
			if (_wordCharSet == null) {
				_wordCharSet = prepCharCodeArray(_wordChars);
			}
			return _wordCharSet;
		}
		
		/**
		 * An array having true at each index corresponding to an inner word character code (lower and upper case).
		 */
		public static function get innerWordCharSet():Array {
			if (_innerWordCharSet == null) {
				_innerWordCharSet = prepCharCodeArray(_innerWordChars);
			}
			return _innerWordCharSet;
		}
		
		/**
		 * An array having true at each index corresponding to an invalid word character code (lower and upper case).
		 */
		public static function get invalidWordCharSet():Array {
			if (_invalidWordCharSet == null) {
				_invalidWordCharSet = prepCharCodeArray(_invalidWordChars);
			}
			return _invalidWordCharSet;
		}
		
		/**
		 * A string containing all of the lower case characters that are considered to be part of a word.
		 */
		public static function get wordChars():String {
			return _wordChars;
		}
		public static function set wordChars(value:String):void {
			_wordCharSet = null;
			_wordChars = value;
		}
		
		/**
		 * A string containing all of the lower case characters that are considered to be part of a word,
		 * but must be contained within characters from the word chars set. For example:
		 * in "don't" the inner character "'" is considered part of the word, but in "'monkey'" it is not.
		 */
		public static function get innerWordChars():String {
			return _innerWordChars;
		}
		public static function set innerWordChars(value:String):void {
			_innerWordCharSet = null;
			_innerWordChars = value;
		}
		
		/**
		 * A string containing all of the lower case characters that invalidate a word if it comprises them.
		 */
		public static function get invalidWordChars():String {
			return _invalidWordChars;
		}
		public static function set invalidWordChars(value:String):void {
			_invalidWordCharSet = null;
			_invalidWordChars = value;
		}
		
		/** @private */
		private static function prepCharCodeArray(str:String):Array {
			var l:uint = str.length;
			var a:Array = [];
			for (var i:uint=0; i<l; i++) {
				a[str.charCodeAt(i)] = true;
				a[str.charAt(i).toUpperCase().charCodeAt(0)] = true;
			}
			return a;
		}
		
		
	}
	
}