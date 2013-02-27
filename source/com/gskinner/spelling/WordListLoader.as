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
	
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	/**
	 * Dispatched when the word list has been completely loaded and parsed.
	 *
	 * @eventType flash.events.Event.COMPLETE
	 */
	[Event(name="complete", type="flash.events.Event")]
	/**
	 * Dispatched when the word list at the specified url can not be found.
	 *
	 * @eventType flash.events.IOErrorEvent.IO_ERROR
	 */
	[Event(name="ioError", type="flash.events.IOErrorEvent")]
	/**
	 * Dispatched when the download operation receives an HTTPStatus event.
	 *
	 * @eventType flash.events.HTTPStatusEvent.HTTP_STATUS
	 */
	[Event(name="httpStatus", type="flash.events.HTTPStatusEvent")]
	/**
	 * Dispatched when the connection to the word list has been opened.
	 *
	 * @eventType flash.events.Event.COMPLETE
	 */
	[Event(name="open", type="flash.events.Event")]
	/**
	 * Dispatched as the word list downloads. 
	 *
	 * @eventType flash.events.Event.COMPLETE
	 */
	[Event(name="progress", type="flash.events.ProgressEvent")]
	/**
	 * Dispatched when the word list download encouters security errors.
	 *
	 * @eventType flash.events.Event.COMPLETE
	 */
	[Event(name="securityError", type="flash.events.SecurityErrorEvent")]
	
	/**
	 * Loads and parses word list files. It can handle either the GSPL file type, or a presorted
	 * (ascending, case-insensitive, and alphanumeric) plain text file containing a list of words separated
	 * by line breaks. It will automatically uncompress zlib-compressed binary text files – this does
	 * not work with zip compression.
	 */
	public class WordListLoader extends EventDispatcher {
		
		/**
		 * Specifies the maximum number of milliseconds to spend per frame parsing word list data. This
		 * allows you to maintain application responsiveness while the parsing routine runs. For example,
		 * setting maximumParseTime to 20 would let animations continue to run smoothly, but increase the
		 * overall time required to parse the word list. Setting maximumParseTime to 3000 will cause the
		 * application to freeze completely for 2-3 seconds while the word list data is parsed, but the
		 * parsing will take less time in total.
		 */
		public var maximumParseTime:uint=50;
		
		/** @private */
		protected var loader:URLLoader;
		
		/** @private */
		protected var _data:Array;
		
		/** @private */
		protected var parseParams:Object;
		
		/**
		 * Creates and instance of WordListLoader and starts a request immediately if the request
		 * parameter is not null.
		 *
		 * @param A URLRequest object that specifies the URL to download. If specified, a load operation begins immediately.
		 */
		public function WordListLoader(request:URLRequest=null) {
			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE,handleComplete,false,0,true);
			loader.addEventListener(IOErrorEvent.IO_ERROR,handleError,false,0,true);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,handleError,false,0,true);
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS,bounceEvent,false,0,true);
			loader.addEventListener(Event.OPEN,bounceEvent,false,0,true);
			loader.addEventListener(ProgressEvent.PROGRESS,bounceEvent,false,0,true);
			if (request) { load(request); }
		}
		
		/**
		 * Indicates the bytes loaded in the load operation.
		 */
		public function get bytesLoaded():uint {
			return loader.bytesLoaded;
		}
		
		/**
		 * Indicates the total number of bytes in the load operation.
		 */
		public function get bytesTotal():uint {
			return loader.bytesTotal;
		}
		
		/**
		 * The array of words loaded during the load operation. Returns null if accessed
		 * before the wordlist is fully loaded and parsed.
		 */
		public function get data():Array {
			return _data
		}
		
		/**
		 * Loads a word list from the URL specified by the request parameter.
		 *
		 * @param A URLRequest object that specifies the URL to download.
		 */
		public function load(request:URLRequest):void {
			_data = null;
			loader.load(request);
		}
		
		/**
		 * Loads a word list from the specified byte array. Note that this is an asynchronous action, and you must wait for the
		 * complete event before accessing data.
		 *
		 * @param A byteArray containing word list data to load.
		 */
		public function loadBytes(byteArray:ByteArray):void {
			try {
				byteArray.uncompress();
			} catch (e:*) {}
			byteArray.position = 0;
			loadString(byteArray.toString());
		}
		
		/**
		 * Loads a word list from the specified string. Note that this is an asynchronous action, and you must wait for the
		 * complete event before accessing data.
		 *
		 * @param A string of word list data to load.
		 */
		public function loadString(string:String):void {
			parseParams = {stringData:string}
			parseParams.ticker = new Shape();
			parseParams.ticker.addEventListener(Event.ENTER_FRAME,beginParse);
		}
		
		/**
		 * Closes the current load operation.
		 */
		public function close():void {
			loader.close();
		}
		
		/** @private */
		protected function handleComplete(evt:Event):void {
			var bytes:ByteArray = (loader.data as ByteArray);
			loadBytes(bytes);
			// ByteArray.clear() is not supported in FP9, using try/catch to use it in FP10+
			try { bytes["clear"](); } catch(e:*) {}
			try { bytes.length = 0; } catch(e:*) {}
		}
		
		/** @private */
		protected function beginParse(evt:Object=null):void {
			parseParams.ticker.removeEventListener(Event.ENTER_FRAME,beginParse);
			var afx:String = parseParams.stringData.substr(0,3);
			if (afx == "SFX" || afx == "PFX") {
				parseParams.list = parseParams.stringData.split("\n");
				parseParams.index = 0;
				parseParams.data = [];
				parseParams.count=0;
				parseAffixes();
				parseParams.ticker.addEventListener(Event.ENTER_FRAME,parse);
				delete(parseParams.stringData);
			} else {
				parseParams.data = parseParams.stringData.split("\n");
				endParse();
			}
		}
		
		/** @private */
		protected function endParse():void {
			parseParams.ticker.removeEventListener(Event.ENTER_FRAME,parse);
			_data = parseParams.data;
			parseParams = null;
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/** @private */
		protected function parseAffixes():void {
			var affixes:Array = parseParams.affixes = [];
			var prefixes:Array = parseParams.prefixes = [];
			var i:uint=parseParams.index;
			
			var list:Array = parseParams.list;
			while (true) {
				var afxCode:String = list[i].substr(0,3);
				if (afxCode == "PFX" || afxCode == "SFX") {
					var afx:String = list[i].substr(4);
					affixes[i] = afx;
					prefixes[i] = (afxCode == "PFX");
					i++;
				} else {
					break;
				}
			}
			parseParams.index = i;
		}
		
		/** @private */
		protected function parse(evt:Object=null):void {
			var t:uint = getTimer()+maximumParseTime;
			var list:Array = parseParams.list;
			var l:uint = list.length;
			var words:Array = parseParams.data;
			
			var affixes:Array = parseParams.affixes;
			var prefixes:Array = parseParams.prefixes;
			var i:uint=parseParams.index;
			
			var al:uint = affixes.length;
			
			while (i<l) {
				var word:String = String(list[i]);
				var index:int = word.lastIndexOf("/");
				if (index != -1) {
					var code:int = parseInt(word.substr(index+1),32);
					word = word.substring(0,index);
					
					// apply affixes:
					for (var j:int=0;j<al;j++) {
						if (code>>j&1) {
							var w:String = (prefixes[j]) ? affixes[j]+word : word+affixes[j];
							words.splice(SpellingUtils.findIndex(words,w),0,w);
						}
					}
				}
				words.splice(SpellingUtils.findIndex(words,word),0,word);
				i++;
				if (i%100==0 && getTimer() >= t) { break; }
			}
			parseParams.index = i;
			parseParams.count++;
			if (i == l) { endParse(); }
		}
		
		/** @private */
		protected function handleError(evt:Event):void {
			bounceEvent(evt);
		}
		
		/** @private */
		protected function bounceEvent(evt:Event):void {
			dispatchEvent(evt.clone());
		}
	}
}