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
package com.gskinner.spelling.wordlisteditor.managers {
	
	//import com.gskinner.spelling.DictionaryLoader;
	import com.gskinner.spelling.SpellingUtils;
	import com.gskinner.spelling.WordListEditorLoader;
	import com.gskinner.spelling.wordlisteditor.events.SaveEvent;
	import com.gskinner.spelling.wordlisteditor.events.WordListEvent;
	import com.gskinner.spelling.wordlisteditor.events.WordListManagerEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
		
	public class WordListManager {
		
		protected static var resultHash:Object;
		protected static var resultStr:String;
		protected static var affixData:Object;
		protected static var binaryDict:ByteArray;
		protected static var unmatchedPossessives:Array;
		protected static var loader:URLLoader;
		
		protected static var prefixes:Array = ["un","re"];
		protected static var suffixes:Array = ["'s","s","ed","ing","ly","d","es","ers"];
		
		protected static var file:File;
		protected static var eventDisp:EventDispatcher;
		protected static var importURL:String;
		// changed from DictionaryLoader
		protected static var dictionaryLoader:WordListEditorLoader;
		//
		protected static var _fileType:String;
		protected static var _compressed:Boolean;
		protected static var _wordHash:Object;
		protected static var _prefixes:Array;
		protected static var _suffixes:Array;
		protected static var _words:Array;
	
		public function WordListManager() {}
	
		
	//*********************************************************
	// Begin: Static EventDispatcher Interface
	//
		public static function addEventListener(p_name:String, p_function:Function, p_useCapture:Boolean=false, p_priority:int=0, p_weak:Boolean=true):void {
            if (eventDisp == null) { eventDisp = new EventDispatcher(); }
            eventDisp.addEventListener(p_name, p_function, p_useCapture, p_priority, p_weak);
        }
        
        public static function removeEventListener(p_name:String, p_function:Function):void {
            if (eventDisp == null) { eventDisp = new EventDispatcher(); }
            eventDisp.removeEventListener(p_name, p_function);
        }  
             
        protected static function dispatchEvent(p_event:Event):void {
            if (eventDisp == null) { eventDisp = new EventDispatcher(); }
            eventDisp.dispatchEvent(p_event);
        }
	//
	// End: Static EventDispatcher Interface
	//*********************************************************
	
// Public Static Methods:
		public static function browseForImport():void {
			dictionaryLoader = new WordListEditorLoader();
			var filterArr:Array = [];
			filterArr.push(new FileFilter("compressed or uncompressed .txt, .gspl, or .zlib files", "*.txt; *.gspl; *.gdic; *.zlib"));
			file = new File();
			file.addEventListener(Event.SELECT, onSelectImport, false, 0, true);
			file.browse(filterArr);
		}
		
		public static function browseForOpenOfficeAffix():void {
			var filterArr:Array = [];
			filterArr.push(new FileFilter("Open Office Affix List","*.aff"));
			file = new File();
			file.addEventListener(Event.SELECT, onSelectOpenOfficeAffix, false, 0, true);
			file.browse(filterArr);
		}
		
		public static function browseForSave(p_fileType:String, p_compressed:Boolean):void {
			_fileType = p_fileType;
			_compressed = p_compressed;
			file = File.documentsDirectory;
			file.addEventListener(Event.SELECT, onSelectSave);
			file.browseForSave("Please enter a filename…");
		}
		
		public static function loadWordList():void {
			dictionaryLoader = new WordListEditorLoader();
			var urlReq:URLRequest = new URLRequest(importURL)
			dictionaryLoader.addEventListener(Event.COMPLETE, importWordList);
			dictionaryLoader.load(urlReq);
		}
		
		public static function loadOpenOfficeAffix():void {
			/*dictionaryLoader = new WordListEditorLoader();
			var urlReq:URLRequest = new URLRequest(importURL)
			dictionaryLoader.addEventListener(Event.COMPLETE, importWordList);
			dictionaryLoader.load(urlReq);*/
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE,handleLoad, false, 0, true);
			loader.load(new URLRequest(importURL));
		}
		
		protected static function handleLoad(p_evt:Event):void {
			var data:String = p_evt.target.data as String;
			if (affixData == null) {
				affixData = parseAffixData(data);
				//loader.load(new URLRequest("wordlists/UK/en_GB/en_GB.dic"))//new URLRequest("wordlists/en_US/en_US.dic"));
				var filterArr:Array = [];
				filterArr.push(new FileFilter("Open Office WordList","*.dic"));
				file = new File();
				file.addEventListener(Event.SELECT, handleOpenOfficeLoad, false, 0, true);
				file.browse(filterArr);
			} else {
				out("");
				resultHash = parseDictionaryData(data,affixData);
				//addEventListener(Event.ENTER_FRAME,handleEnterFrame);
				var delayTimer:Timer = new Timer(100,1);
				delayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, handleTimer, false, 0, true);
				delayTimer.start();
			}
		}
		
		protected static function handleTimer(p_event:TimerEvent):void {
			handleEnterFrame(null);
		}
		
		protected static function handleOpenOfficeLoad(p_event:Event):void {
			importURL = p_event.target.url;
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE,handleLoad, false, 0, true);
			loader.load(new URLRequest(importURL));
			trace('LOADING')
		}
		
		protected static function handleEnterFrame(p_evt:Event):void {
			if (resultStr == null) {
				resultStr = postProcess2(resultHash);
			//	resultFld.text = resultStr;
			} else if (binaryDict == null) {
				//binaryDict = buildDictionary(resultStr);
			} else {
				//writeFiles(binaryDict,unmatchedPossessives);
				removeEventListener(Event.ENTER_FRAME,handleEnterFrame);
			}
				var wordArray:Array = resultStr.split("\n");
				var affArray:Array = [];
				trace("AFFIX DATA: " + affixData)
				var eventObj:WordListManagerEvent = new WordListManagerEvent(WordListManagerEvent.LIST_DATA_COMLETE, wordArray, affArray)
				dispatchEvent(eventObj);
		}
		
		protected static function parseAffixData(p_data:String):Object {
			out("***** Parsing Affix File *****");
			var affixHash:Object = {};
			var lineList:Array = p_data.split("\n");
			var l:uint = lineList.length;
			var i:int=-1;
			var curID:String;
			var curDef:Object;
			var affixCount:uint=0;
			var entryCount:uint=0;
			while (++i<l) {
				var line:String = lineList[i];
				var codes:Array = line.match(/\S+/g);
				if (codes[0] != "SFX" && codes[0] != "PFX") {
					continue;
				}
				
				if (codes[1] != curID) {
					// affix descriptor
					curID = codes[1];
					curDef = {id:curID,pre:codes[0]=="PFX",comb:(codes[2]=="Y"),entries:[]}
					affixHash[curID] = curDef;
					affixCount++;
					//out("affix: "+curID);
					//trace(curDef.id+" : "+curDef.pre+" : "+curDef.comb);
				} else {
					// entry descriptor
					entryCount++;
					var obj:Object = {del:((codes[2]=="0")?"":codes[2]),afx:codes[3],match:codes[4]};
					curDef.entries.push(obj);
				}
			}
			out("Contained "+entryCount+" entries for "+affixCount+" affixes.");
			return affixHash;
		}
		
		protected static function parseDictionaryData(p_data:String,p_afx:Object=null):Object {
			var lineList:Array = p_data.split("\n");
			if (!isNaN(parseInt(lineList[0]))) { lineList.shift(); }
			if (p_afx == null) { return lineList.join("\n"); }
			var expandedWordHash:Object = {};
			var i:int = -1;
			var l:uint = lineList.length;
			
			var addCount:uint=0;
			var combCount:uint=0;
			
			out("***** Parsing Dictionary File *****");
			out("Original dictionary contains "+l+" entries.");
			
			while (++i < l) {
				var codes:Array = lineList[i].split("/");
				var word:String = codes[0];
				expandedWordHash[word] = true;
				addCount++;
				
				// no affixes:
				if (codes[1] == null) { continue; }
				
				// we have affixes, so let's iterate on them:
				var afxs:String = codes[1];
				var al:uint = afxs.length;
				for (var j:uint=0;j<al;j++) {
					var afx:Object = p_afx[afxs.charAt(j)];
					//trace(codes);
					//trace("affix? "+afxs.charAt(j));
					var e:Object = getEntryMatch(word,afx.entries);
					if (e == null) { /*trace("eh: "+word); */continue; }
					
					var w:String = word;
					
					if (afx.pre) {
						w = e.afx+w.substr(e.del.length);
						// for prefixes that can be combined, we also want to do the combos:
						if (afx.comb) {
							for (var k:uint=0; k<al; k++) {
								var afx2:Object = p_afx[afxs.charAt(k)];
								if (!afx2.pre && afx2.comb) {
									var e2:Object = getEntryMatch(word,afx2.entries);
									if (e != null) {
										var w2:String = w.substr(0,w.length-e2.del.length)+e2.afx;
										combCount++;
										addCount++;
										expandedWordHash[w2] = true;
									}
								}
							}
						}
					} else {
						w = w.substr(0,w.length-e.del.length)+e.afx;
					}
					addCount++;
					expandedWordHash[w] = true;
				}
			}
			
			out("generated "+addCount+" expanded words.");
			out("total of "+combCount+" combination entries.");
			
			return expandedWordHash;
		}

		// simple post process (flatten):
		protected static function postProcess2(p_wordHash:Object):String {
			var arr:Array = [];
			for (var n:String in p_wordHash) {
				arr.push(n);
			}
			arr.sort(Array.CASEINSENSITIVE);
			return arr.join("\n");
		}
		
		protected static function getEntryMatch(word:String,entries:Array):Object {
			for (var k:uint=0;k<entries.length;k++) {
				var e:Object = entries[k];
				var re:String = (e.pre) ? "^"+e.match : e.match+"$";
				var regEx:RegExp = new RegExp(re);
				if (regEx.exec(word)) {
					return e;
				}
			}
			return null;
		}
		
		// ----------------------------------------------------------------
			
		public static function acceptFile(p_url:String):void {
			importURL = p_url;
			dispatchEvent(new WordListManagerEvent(WordListManagerEvent.IMPORTEE_SELECTED));
		}
		
		public static function writeFile(p_prefixes:Array, p_suffixes:Array, p_wordListData:Object):void {
		 	_wordHash = createWordHash((p_wordListData as ArrayCollection).source)
		 	_prefixes = p_prefixes;
			_suffixes = p_suffixes;
			_words = [];
			var l:uint = p_wordListData.length;
			for(var i:uint = 0; i< l; i++){
				_words.push(p_wordListData[i].label)
			}
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.WRITE);
			var stringData:String = (_fileType == ".txt") ? _words.join('\n') : postProcess();
			if(_compressed) {
				fileStream.writeBytes(compressWordList(stringData));
			} else {
				fileStream.writeUTFBytes(stringData);
			}
			dispatchEvent(new SaveEvent(SaveEvent.SAVED));
		}
		
// Protected Static Methods:

		protected static function postProcess():String {
			var capsCount:uint = 0;
			var newDict:Array = [];
			var newHash:Object = {};
			var prefixCount:uint = _prefixes.length;
			var affixes:Array = _prefixes.concat(_suffixes);
			var affixCount:uint = affixes.length;
			var affixStr:String = "";
			var counts:Array = [];
			var voidHash:Object = {};
			
			for (var i:uint=0; i<affixCount; i++) {
				counts[i] = 0;
				affixStr = affixStr+((i<prefixCount) ? "PFX" : "SFX" )+" "+affixes[i].string+"\n";
			}
			
			for (var n:String in _wordHash) {
				if (n.length < 1) { continue; }
				if (voidHash[n]) { continue; }
				voidHash[n] = true;
				
				var code:uint=0;
				for (i=0; i<affixCount; i++) {
					
					var newWord:String = (i<prefixCount) ? (affixes[i].string+n) : (n+affixes[i].string);
					
					if (_wordHash[newWord] && (newHash[newWord] == null || newHash[newWord] < 1)) {
						delete(newHash[newWord]);
						voidHash[newWord] = true;
						counts[i]++;
						code |= (1<<i);
					}
				}
				newHash[n] = code;
			}
			
			// assemble the string:
			for (n in newHash) {
				newDict.push(n);
			}
			newDict.sort(Array.CASEINSENSITIVE);
			var result:String = "";
			var l:uint = newDict.length;
			for (i=0;i<l;i++) {
				var str:String = newDict[i];
				code = newHash[str];
				result += ((i>0)?"\n":"")+str+((code>0)?"/"+(code).toString(32):"");
			}
			
			// generate report:
			out("compacted word list has "+l+" words.");
			out("compacted word list is "+result.length+" characters long.");
			for (i=0; i<affixCount; i++) {
				//out(((i<prefixCount)?"prefix":"suffix")+" \""+affixes[i].string+"\": "+counts[i]);
			}
			var event:WordListEvent = new WordListEvent(WordListEvent.CREATED, affixStr+result);
			dispatchEvent(event);
			return affixStr+result;
		}
		

		protected static function createWordHash(p_list:Array):Object {
			var obj:Object = {};
			var l:uint = p_list.length;
			for (var i:uint=0; i<l; i++) {
				//obj[p_list[i].label] = true;
				obj[p_list[i].label] = p_list[i].label;
			}
			return obj;
		}
		
		protected static function compressWordList(result:String):ByteArray {
			var binaryDictionary:ByteArray = new ByteArray();
			binaryDictionary.writeUTFBytes(result);
			binaryDictionary.compress();
			return binaryDictionary;
		}
		
		protected static function onSelectSave(p_event:Event):void {
			file = p_event.target as File;
			
			if(_fileType == ".txt") {
				if(file.url.slice(file.url.length-4) != ".txt") {
					file.url += _fileType;
				}
			}
			
			else if (_fileType == ".gspl") {
				if(file.url.slice(file.url.length-5) != ".gspl") {
					file.url += _fileType;
				}
			
			}
			
			//if(file.url.slice(file.url.length-4, file.url.length) != _fileType){
					//file.url += _fileType;
			//}
			
			dispatchEvent(new SaveEvent(SaveEvent.DIRECTORY_SELECTED));
		}
		
		protected static function onSelectImport(p_event:Event):void {
			importURL = p_event.target.url;
			dispatchEvent(new WordListManagerEvent(WordListManagerEvent.IMPORTEE_SELECTED));
		}
		
		protected static function onSelectOpenOfficeAffix(p_event:Event):void {
			importURL = p_event.target.url;
			dispatchEvent(new WordListManagerEvent(WordListManagerEvent.OPEN_OFFICE_SELECTED));
		}
		
		
		protected static function importWordList(p_event:Event):void {
			var wordList:Array = dictionaryLoader.data;
			var affixList:Array = dictionaryLoader.affixList;
			var prefixList:Array = dictionaryLoader.prefixList;
			var wordArray:Array = [];
			var affArray:Array = [];
			var l:uint = wordList.length;
			var i:uint = 0;
			// populates wordList
			for (i=0;i<l;i++){
				var wordObj:Object = { label:wordList[i] };
				wordArray.push(wordObj);
			}
			
			if(affixList){
				var len:uint = affixList.length;
				//populates affixList
				for(i=0; i<len; i++) {
					var affixObj:Object = { type: ((prefixList[i]) ? "PFX" : "SFX"), string:affixList[i] };
					affArray.push(affixObj);
				}
			}
			var eventObj:WordListManagerEvent = new WordListManagerEvent(WordListManagerEvent.LIST_DATA_COMLETE, wordArray, affArray)
			dispatchEvent(eventObj);
		}
		
		public static function mergeLists(p_listA:Array, p_listB:Array):Array {
			var newList:Array = SpellingUtils.mergeWordLists(p_listA, p_listB);
			return newList;
		}
		
		public static function mergeAffixes(p_listA:Array, p_listB:Array):Array {
			var newList:Array = SpellingUtils.mergeAffixLists(p_listA, p_listB);
			return newList;
		}
		
		protected static function out(p_str:String):void {
			trace(p_str);
		}
	}
}