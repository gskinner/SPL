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
	
	import mx.core.UIComponent;
	
	/**
	 * The SPLCustomWordListLSO component provides a quick way to set up the Custom WordList LSO
	 * in MXML. For direct instantiation with ActionScript, please use CustomWordListLSO.as.
	 *
	 * @see com.gskinner.spelling.CustomWordListLSO
	 */
	 [IconFile("componentIcon.png")]
	public class SPLCustomWordListLSOFlex extends UIComponent {
	
		/** @private */
		protected static var inited:Boolean = false;
		
		/** @private */
		protected var _customWordListLSO:CustomWordListLSO;
		
		/** @private */
		protected var _inited:Boolean = false;
		
		/** @private */
		public function SPLCustomWordListLSOFlex() {
			if (inited) { throw(new Error("Only one instance of SPLCustomWordListLSOFlex can be instantiated")); }
			inited = true;
		}
		
		/** @copy com.gskinner.spelling.SPLCustomWordListLSO#lsoName */
		[Inspectable(type="String", defaultValue="_com_gskinner_customDictionary")]
		public function set lsoName(value:String):void {
			if (_inited) { throw(new Error("lsoName can not be changed")); }
			_customWordListLSO = new CustomWordListLSO(SpellingDictionary.getInstance(), value);
			_inited = true;
		}
		
		/** @copy com.gskinner.spelling.SPLCustomWordListLSO#customWordListLSO */
		public function get customWordListLSO():CustomWordListLSO {
			return _customWordListLSO;
		}
	}
}