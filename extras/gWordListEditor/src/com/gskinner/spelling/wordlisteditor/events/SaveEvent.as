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
package com.gskinner.spelling.wordlisteditor.events {
	
	import flash.events.Event;
	
	public class SaveEvent extends Event {
		
		public static const SETTINGS_SELECTED:String = 'settingsSelected';
		public static const DIRECTORY_SELECTED:String = 'directorySelected';
		public static const SAVED:String = 'saved';
		
		protected var _fileType:String;
		protected var _compressed:Boolean;
		
		public function SaveEvent(p_type:String, p_fileType:String=null, p_compressed:Boolean=false) {
			super(p_type);
			_fileType = p_fileType;
			_compressed = p_compressed;
		}
		
		public function set fileType(p_fileType:String):void { _fileType = p_fileType; }
		public function set compressed(p_compressed:Boolean):void { _compressed = p_compressed; }
		
		public function get fileType():String { return _fileType; }
		public function get compressed():Boolean { return _compressed; }
	}	
}
