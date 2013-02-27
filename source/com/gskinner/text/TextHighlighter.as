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

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FocusEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * Applies a highlight effect to specified words in a textfield.
	 */
	public class TextHighlighter extends EventDispatcher {

		/** @private */
		protected var plugin:ITextHighlighterPlugin;

		/** @private */
		protected var _target:Object;
		
		/** @private */
		protected var _wordList:Array;
		
		/** @private */
		protected var _enabled:Boolean=true;
		
		/** @private */
		protected var _ignoreCase:Boolean=true;
		
		/** @private */
		protected var _autoUpdate:Boolean=true;
		
		/** @private */
		protected var _color:uint=0xFFFFFF00;
		
		/** @private */
		protected var _entireWords:Boolean=true;
		
		/** @private */
		protected var validateTimer:Timer;
		
		/** @private */
		protected var valid:Boolean=false;
		
		/** @private */
		protected var _enableOnFocus:Boolean=false;
		
		/** @private */
		protected var _ignoreSelectedWord:Boolean=true;
		
		/** @private */
		protected var _updateOnValueCommit:Boolean=false;
		
		/** @private */
		protected var _pluginFactories:Array;

		/**
		 * Creates a new instance of TextHighlighter
		 *
		 * @param target The target object to apply highlights to. See the target property for more information.
		 * @param wordList An array of words to highlight in the text field.
		 * @param pluginFactories An Array of plugins used to enable SPL support for different types of text. For example to enable spelling support for TLF in the Flex Framework pass [new SpellingTLFPluginFactory()]
		 */
		public function TextHighlighter(target:Object=null,wordList:Array=null, pluginFactories:Array = null) {
			validateTimer = new Timer(5,1);
			validateTimer.addEventListener(TimerEvent.TIMER,validate,false,0,true);
			_pluginFactories = pluginFactories;
			this.wordList = wordList;
			this.target = target;
		}

		/**
		 * The target object to apply highlights to. If the target is a TextField instance, it will use it as the textField property.
		 * If not, it will use the textField property of the target if it exists. If the target does not have a textField property, but
		 * is an instance of DisplayObjectContainer, it will loop through all of the immediate children of the target and use the largest
		 * textfield it finds.
		 * <br/><br/>
		 * <b>Important note for RichTextEditor:</b><br/>
		 * To apply spell checking properly to a Flex RichTextEditor component, you must target the TextArea instance within it. In order
		 * for the highlighter to update appropriately based on text formatting changes, you must also add a simple change event handler
		 * to the RichTextEditor.<br/><code>
		 * &lt;mx:RichTextEditor id="myRTE”  change="{ splTagHighlighter.spellingHighlighter.update() }"/><br/>
		 * &lt;spelling:SPLTagFlex id="splTagHighlighter" target="{myRTE.textArea}" /></code>
		 */
		public function get target():Object {
			return _target;
		}
		public function set target(value:Object):void {
			_target = value;
			if (plugin) {
				plugin.removeEventListener(FocusEvent.FOCUS_IN,handleFocusEvent);
				plugin.removeEventListener(FocusEvent.FOCUS_OUT,handleFocusEvent);
				plugin.removeEventListener(Event.CHANGE,handleInvalidationEvent);
				plugin.dispose();
				plugin = null;
			}
			
			var factories:Array = _pluginFactories || PluginFactoryDefaults.factories;
			if (value != null && factories != null) {
				var l:uint = factories.length;
				for (var i:uint=0; i<l; i++) {
					plugin = factories[i].getPluginInstance(value);
					if (plugin) { break; }
				}
			}
			
			if (plugin) {
				plugin.addEventListener(FocusEvent.FOCUS_IN,handleFocusEvent,false,1,true);
				plugin.addEventListener(FocusEvent.FOCUS_OUT,handleFocusEvent,false,1,true);
				
				//wdg:: Need this as weakRefernce=false, so when using SPL in an dialog (Flex), listeners get removed :/
				plugin.addEventListener(Event.CHANGE,handleInvalidationEvent,false,1,false);
			} else if (value != null) {
				var factoryList:String = (factories == null || factories.length == 0) ? "\n ** NO FACTORIES FOUND **" : "\nAvailable factories: " + factories.join(",");
				throw(new Error("Unable to find a text highlighter plugin to use with target. Are you using the correct plugin factory?" + factoryList));
			}

			setupListeners();
			invalidate();
		}

		/**
		 * An array of words to highlight.
		 */
		public function get wordList():Array {
			return _wordList;
		}
		public function set wordList(value:Array):void {
			_wordList = value;
			invalidate();
		}

		/**
		 * Sets the ARGB color of the highlight effect.
		 */
		public function get color():uint {
			return _color;
		}
		public function set color(value:uint):void {
			_color = value;
			if (_color>>24 == 0) { _color = 0xFF<<24|_color; }
			invalidate();
		}

		/**
		 * Turns the highlights on or off. Setting enabled to false clears all current highlights,
		 * and removes all event listeners.
		 */
		public function get enabled():Boolean {
			return _enabled;
		}
		public function set enabled(value:Boolean):void {
			if (_enabled == value) { return; }

			_enabled = value;

			setupListeners();
			invalidate();
		}

		/**
		 * Specifies whether highlights should be automatically updated in response
		 * to user generated events on the text field such as scrolling or editing text.
		 */
		public function get autoUpdate():Boolean {
			return _autoUpdate;
		}
		public function set autoUpdate(value:Boolean):void {
			_autoUpdate = value;
			setupListeners();
		}

		/**
		 * If true, the text highlighter will automatically set enabled to false when the target text field
		 * loses focus, and enabled to true when it gains focus. Default is false.
		 */
		public function get enableOnFocus():Boolean {
			return _enableOnFocus;
		}
		public function set enableOnFocus(value:Boolean):void {
			_enableOnFocus = value;
			setupListeners();
			enabled = (plugin != null && plugin.isFocus);
		}

		/**
		 * If true, highlights will not be drawn on words that intersect the selection on the target text field. This
		 * can be used to prevent highlighting on a word as it is being edited.
		 */
		public function get ignoreSelectedWord():Boolean {
			return _ignoreSelectedWord;
		}
		public function set ignoreSelectedWord(value:Boolean):void {
			_ignoreSelectedWord = value;
			setupListeners();
		}

		/**
		 * If true, the TextHighlighter inistance will invalidate whenever a valueCommit event is dispatched from the target.
		 * This allows automatic updates when text is changed programmatically or through data binding on a Flex component, but
		 * it may result in unnecessary updates when unrelated properties are changed on the target.
		 */
		public function get updateOnValueCommit():Boolean {
			return _updateOnValueCommit;
		}
		public function set updateOnValueCommit(value:Boolean):void {
			_updateOnValueCommit = value;
			setupListeners();
		}

		/**
		 * Forces all highlights to be redrawn via invalidation.
		 */
		public function update():void {
			invalidate();
		}

		/**
		 * Forces all highlights to be redrawn immediately.
		 */
		public function updateNow():void {
			draw();
		}

		/**
		 * Clears all current highlights. This does not clear the word list or other properties.
		 */
		public function clear():void {
			if (plugin) { plugin.clear(); }
		}
		
		/** @private */
		protected function draw():void {
			if (plugin == null) { return; }
			plugin.clear();

			if (!_enabled || !plugin.startDraw()) {
				return;
			}
			
			plugin.color = _color;
			
			// isolate the text that's visible:
			var visibleRange:StringPosition = plugin.visibleRange;
			var beginIndex:uint = visibleRange.beginIndex;
			var endIndex:uint = visibleRange.endIndex;
			
			// logic for watching selection:
			var selBeginIndex:uint = plugin.selectionBeginIndex;
			var selEndIndex:uint = plugin.selectionEndIndex;
			var ignoreSel:Boolean = _ignoreSelectedWord && plugin.isFocus;

			var bi:uint = Math.max(0,beginIndex-40);
			var ei:uint = Math.min(plugin.text.length,endIndex+40);
			var str:String = plugin.text.substring(bi,ei);
			
			var wc:Array = CharacterSet.wordCharSet;
			var ic:Array = CharacterSet.innerWordCharSet;
			var xc:Array = CharacterSet.invalidWordCharSet;

			var l:uint = str.length;

			var wbi:uint = 0; // wordBeginIndex
			var i:uint = 0;
			var mode:uint=0; // 0=seekWord, 1=inWord, 2=badWord, 3=foundWord

			for(;i<l;) {
				var c:uint = str.charCodeAt(i);
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
					if (checkWord(str.substring(wbi,i)) && (!ignoreSel || wbi+bi > selEndIndex || i+bi < selBeginIndex)) {
						plugin.drawHighlight(Math.max(beginIndex,wbi+bi),Math.min(endIndex-1,i+bi-1));
					}
					mode = 0;
				}
				i++;
			}

			if (mode == 1) {
				if (checkWord(str.substring(wbi,i)) && (!ignoreSel || wbi+bi > selEndIndex || i+bi < selBeginIndex)) {
					plugin.drawHighlight(Math.max(beginIndex,wbi+bi),Math.min(endIndex-1,i+bi-1));
				}
			}
		}

		/** @private */
		protected function setupListeners(forceOff:Boolean=false):void {
			var targ:EventDispatcher = _target as EventDispatcher;
			if (targ) {
				if (forceOff || !_enabled || !_autoUpdate) {
					targ.removeEventListener(Event.RESIZE,handleInvalidationEvent);
				} else {
					targ.addEventListener(Event.RESIZE,handleInvalidationEvent,false,1,true);
				}

				if (forceOff || !_enabled || !_updateOnValueCommit) {
					// using string literals for the event type here, so that FlexEvent does not need to be imported:
					targ.removeEventListener("valueCommit",handleInvalidationEvent);
				} else {
					targ.addEventListener("valueCommit",handleInvalidationEvent,false,1,true);
				}
			}

			if (plugin) {
				plugin.setupListeners(!forceOff&&_enableOnFocus, !forceOff&&_enabled&&_autoUpdate, !forceOff&&_ignoreSelectedWord);
			}
		}

		/** @private */
		protected function checkWord(word:String):Boolean {
			return (_wordList) ? (_wordList.indexOf(word) != -1) : false;
		}

		/** @private */
		protected function invalidate():void {
			validateTimer.start();
			valid = false;
		}

		/** @private */
		protected function validate(evt:TimerEvent):void {
			validateTimer.reset();
			if (!valid) { draw(); }
			valid = true;
		}

		/** @private */
		protected function handleInvalidationEvent(evt:Event):void {
			if (_autoUpdate) { invalidate(); }
		}

		/** @private */
		protected function handleFocusEvent(evt:FocusEvent):void {
			enabled = (evt.type == FocusEvent.FOCUS_IN);
		}

	}

}