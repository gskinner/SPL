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
	
	/**
	 * vo used to store the results of a context menu spelling request.
	 * 
	 */
	public class ContextMenuData {
		
		/**
		 * Constant that specifies when the current word is spelled correctly. 
		 * 
		 */
		public static const CORRECT_SPELLING:String = "correctSpelling";
		
		/**
		 * Constant that specifies when no suggestions can be found for the current word. 
		 * 
		 */
		public static const NO_SUGGESTIONS:String = "noSuggestions";
		
		/**
		 * Constant that specifies when the dictionary has found suggested spellings.
		 * In this case the suggestions array will be populated with suggestions.
		 * 
		 */
		public static const HAS_SUGGESTIONS:String = "hasSuggestions";
		
		/**
		 * Constant that specifies when the context menu has requested a word thats out of bounds. 
		 * 
		 */
		public static const BAD_WORD:String = "badWord";
		
		/**
		 * onstant that specifies when a word is spelled correct and is in the users custom dictonary,
		 * 
		 */
		public static const CUSTOM_CORRECT_SPELLING:String = "customCorrectSpelling";
		
		/**
		 * The suggestions found by the SpellingDictionary
		 * @see com.gskinner.spelling.SpellingDictionary;
		 * 
		 */
		public var suggestions:Array;
		
		/**
		 * The original word requested to be spell checked.
		 * 
		 */
		public var word:String;
		
		/**
		 * The final state of the spelling operation.
		 * This class defines all the possible values:
		 * 
		 * @see CORRECT_SPELLING;
		 * @see CUSTOM_CORRECT_SPELLING;
		 * @see NO_SUGGESTIONS;
		 * @see HAS_SUGGESTIONS;
		 * @see BAD_WORD;
		 * 
		 */
		public var state:String;
		
		public function ContextMenuData() {
			
		}
	}
}