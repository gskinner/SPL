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
	
	import flash.display.DisplayObject;
	
	/**
	 * Utility class for shared methods in SPL.
	 */
	public class TextUtils {
		
		/**
		 * In-order to share the logic to find a text area with any given component, we need to highly abstract this searching logic
		 * to accommodate Flash, Flex 4.x and Flex 3.x
		 *
		 * @param target The target component to search on
		 * @param propertyName the name of the textField we are attempting to find.
		 * @param lengthProperty The property used to determine how any children we need to search. This should be either numChildren (Flash, Flex 3.x or numElements (Flex 4.x)
		 * @param getChildMethod - The method used to get a child at an specific index. This should be either getChildAt(Flash and Flex 3.x, or getElementAt (Flex 4.x)
		 * @param type The type of text we are looking for, TLFTextField, TextField, or RichEditableText
		 * @param depth How many levels to search before giving up.
		 *
		 * @returns the found text field. Or null if no textField is found.
		 */
		public static function findType(target:Object, propertyName:String, lengthProperty:String, getChildMethod:String, type:Class, depth:int=2):Object {
			if (target == null) { return null; }
			var foundTarget:Object;
			
			if (target is type) {
				foundTarget = target;
			} else if (propertyName in target && target[propertyName] is type) {
				foundTarget = target[propertyName];
			} else if (lengthProperty in target && getChildMethod in target && depth > 0) {
				// iterate to find largest child:
				var displayObj:Object;
				var size:Number = 0;
				var l:uint = target[lengthProperty];
				for (var i:uint=0; i<l; i++) {
					var child:DisplayObject = target[getChildMethod](i);
					displayObj = findType(child, propertyName, lengthProperty, getChildMethod, type, depth-1);
					if (displayObj && displayObj.width+displayObj.height > size) {
						foundTarget = displayObj;
						size = displayObj.width+displayObj.height;
					}
				}
			}
			return foundTarget;
		}
	}
}