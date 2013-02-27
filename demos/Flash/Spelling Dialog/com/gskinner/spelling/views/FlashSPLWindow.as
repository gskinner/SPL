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
package com.gskinner.spelling.views {
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import fl.controls.Button;
	import fl.controls.TextInput;
	import fl.controls.TextArea;
	import fl.controls.List
	import fl.data.DataProvider;
	import com.gskinner.spelling.SpellingDictionaryEvent;
	import com.gskinner.text.StringPosition;
	import com.gskinner.spelling.SpellingDictionary;
	import com.gskinner.spelling.SPLTag;
	import flash.utils.getTimer;
	
	public class FlashSPLWindow extends Sprite {
		
	// Public Properties:
		public var suggestionsList:List;
		public var misspelledWord:TextInput;
		public var changeBtn:Button;
		public var ignoreBtn:Button;
		public var addBtn:Button;
		public var ignoreAllBtn:Button;
		public var closeBtn:Button;
		public var suggestedWord:TextInput;
		
	// Private Properties:
		protected var _target:Object;
		protected var _textField:TextField;
		protected var spellingDictionary:SpellingDictionary;
		protected var ignoreWordHash:Object;
		protected var lastCheckIndex:uint = 0;
		protected var currentStringPostion:StringPosition;
		protected var originalAlwaysShowSelection:Boolean;
	// UI Elements:
	
	// Initialization:
		public function FlashSPLWindow(p_target:Object = null) {
			if (p_target) { target = p_target; }
			init();
			addEventListener(Event.ADDED_TO_STAGE, onStage, false, 0, true);
        
        }
        
        protected function onStage(event:Event):void {
            addEventListener(Event.ENTER_FRAME, onFrame);
        }
        
        protected function onFrame(event:Event):void {
            removeEventListener(Event.ENTER_FRAME, onFrame);
            stage.invalidate();
        }

	
	// Public Methods:
		public function set target(value:Object):void {
			if (value == null) {
				_textField = null;
			} else if (value is TextField) {
				_textField = (value as TextField);
			} else if (value.hasOwnProperty("textField")) {
				_textField = value["textField"];
			} else if (value is DisplayObjectContainer) {
				// iterate to find largest child textField:
				var tf:TextField = null;
				var tfSize:Number = 0;
				for (var i:uint=0; i<value.numChildren; i++) {
					var child:DisplayObject = value.getChildAt(i) as TextField;
					if (child) {
						if (child.width+child.height > tfSize) {
							tf = child as TextField;
							tfSize = child.width+child.height;
						}
					}
				}
				_textField = tf;
			} else {
				_textField = null;
			}
			_target = value;
		}
		
		public function checkSpelling(p_target:Object = null):void {
			if (p_target) { target = p_target; }
			lastCheckIndex = 0;
			originalAlwaysShowSelection = _textField.alwaysShowSelection;
			if (!_textField.alwaysShowSelection) { _textField.alwaysShowSelection = true; }
			
			if (!spellingDictionary || !spellingDictionary.active) { init(); return; }
			onSpellingActivate(null);
		}
		
		protected function init():void {
			changeBtn.addEventListener(MouseEvent.CLICK, changeWord ,false, 0, true);
			ignoreBtn.addEventListener(MouseEvent.CLICK, ignoreWord ,false, 0, true);
			addBtn.addEventListener(MouseEvent.CLICK, addWord ,false, 0, true);
			ignoreAllBtn.addEventListener(MouseEvent.CLICK, ignoreAll ,false, 0, true);
			closeBtn.addEventListener(MouseEvent.CLICK, doClose ,false, 0, true);
			
			spellingDictionary = SpellingDictionary.getInstance();
			if (!spellingDictionary.active) {
				spellingDictionary.addEventListener(SpellingDictionaryEvent.ACTIVE, onSpellingActivate, false, 0, true);
				enableInterface(false);
				suggestionsList.dataProvider = new DataProvider([{label:'Waiting for Dictionary ...'}]);
			} else {
				onSpellingActivate(null);
			}
			
			suggestionsList.addEventListener(Event.CHANGE, onSuggestionListChange, false, 0, true);
			
			enableInterface(false);
		}
		
		protected function onSpellingActivate(event:SpellingDictionaryEvent):void {
			ignoreWordHash = { };
			enableInterface(true);
			spellingDictionary.checkString(_textField.text);
			checkNextWord();
		}
		
		protected function onComplete():void {
			showErrorMessage('Spelling complete');
			enableInterface(false);
		}
		
		protected function checkNextWord():void {
			currentStringPostion = spellingDictionary.getNextMisspelledWord(_textField.text, lastCheckIndex);
			if (!currentStringPostion) { onComplete(); return; }
			lastCheckIndex = currentStringPostion.endIndex;
			
			if (ignoreWordHash[currentStringPostion.subString]) { checkNextWord(); }
			
			suggestionsList.dataProvider = createDataProvider(spellingDictionary.getSpellingSuggestions(currentStringPostion.subString, 20, .6));
			
			if (suggestionsList.dataProvider.length) {
				suggestionsList.selectedIndex = 0;
				changeWordSuggestion();
				highlightCurrentWord();
			} else {
				showErrorMessage('No misspelled words');
				enableInterface(false);
				return;
			}
			
			misspelledWord.text = currentStringPostion.subString;
		}
		
		protected function showErrorMessage(p_message:String):void {
			suggestionsList.dataProvider = new DataProvider([{label:p_message}]);
		}
		
		protected function onSuggestionListChange(event:Event):void {
			changeWordSuggestion();
		}
		
		protected function enableInterface(p_enabled:Boolean):void {
			changeBtn.enabled = p_enabled;
			ignoreBtn.enabled = p_enabled;
			ignoreAllBtn.enabled = p_enabled;
			addBtn.enabled = p_enabled;
			suggestionsList.enabled = p_enabled;
		}
		
		protected function changeWordSuggestion():void {
			suggestedWord.text = suggestionsList.selectedItem.label;
		}
		
		protected function createDataProvider(array:Array):DataProvider {
			var l:uint = array.length;
			var dp:Array = [];
			
			for (var i:uint=0;i<l;i++) {
				dp.push({label:array[i]});
			}
			
			return new DataProvider(dp);
		}
		
		protected function doClose(event:MouseEvent):void {
			_textField.alwaysShowSelection = originalAlwaysShowSelection;
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		protected function changeWord(event:MouseEvent):void {
			var txt:String = _textField.text;
			_textField.text = txt.substring(0,currentStringPostion.beginIndex)+suggestedWord.text+txt.substring(currentStringPostion.endIndex);
			
			checkNextWord();
			_textField.dispatchEvent(new Event(Event.CHANGE,true,false));
		}
		
		protected function highlightCurrentWord():void {
			_textField.setSelection(currentStringPostion.beginIndex,currentStringPostion.endIndex);
		}
		
		protected function ignoreWord(event:MouseEvent):void {
			checkNextWord();
		}
		
		protected function ignoreAll(event:MouseEvent):void {
			ignoreWordHash[currentStringPostion.subString] = true;
			checkNextWord();
		}
		
		protected function addWord(event:MouseEvent):void {
			spellingDictionary.addCustomWord(currentStringPostion.subString);
			checkNextWord();
		}
	}
}