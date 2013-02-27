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
	 * Represents a sub-string's position in a larger string.
	 */
	public class StringPosition {
		
		/**
		 * The starting index of the sub-string within a larger string.
		 */
		public var beginIndex:uint;
		
		/**
		 * The ending index of the sub-string within a larger string.
		 */
		public var endIndex:uint;
		
		/**
		 * The sub-string.
		 */
		public var subString:String;
		
		/**
		 * Arbritrary data that we can store with this class.
		 */
		public var data:Object;

		/**
		 * Represents a sub-string's position in a larger string.
		 *
		 * @param beginIndex The starting index of the sub-string.
		 * @param endIndex The ending index of the sub-string.
		 * @param subString The sub-string.
		 * @param data Arbitrary data to attach to this StringPosition instance.
		 */
		public function StringPosition(beginIndex:uint,endIndex:uint,subString:String=null, data:Object = null) {
			this.beginIndex = beginIndex;
			this.endIndex = endIndex;
			this.subString = subString;
			this.data = data;
		}
		
		/** @private */
		public function toString():String {
			return '[beginIndex: ' + beginIndex + ', endIndex: ' + endIndex + ', subString: ' + subString + ']';
		}

	}

}