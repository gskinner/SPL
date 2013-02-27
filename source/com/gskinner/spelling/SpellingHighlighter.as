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

	import com.gskinner.spelling.ui.AbstractSpellingUIPlugin;
	import com.gskinner.spelling.ui.ContextMenuPlugin;
	import com.gskinner.text.TextHighlighter;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	
	/**
	 * SpellingHighlighter underlines mispelled words in a text field, and provides a right click contextual menu for
	 * spelling suggestions and custom word list access.
	 */
	public class SpellingHighlighter extends TextHighlighter {

		/**
		 * This static property allows you to set a default underline pattern for all instances of
		 * SpellingHighlighter. Note that existing instances will not reflect the change until they
		 * are invalidated and redrawn. Note that setting this to null will cause errors.
		 */
		public static var defaultUnderlinePattern:BitmapData;

		/**
		 * This static property allows you to set a default spelling dictionary to use
		 * with all instances of SpellingHighlighter. If this is not set, it will default to
		 * the SpellingDictionary instance returned by SpellingDictionary.getInstance(). This
		 * is provided for use with subclasses of SpellingDictionary. Existing instances will not
		 * reflect changes to this property.
		 */
		public static var defaultSpellingDictionary:SpellingDictionary;

		/** @private */
		protected var underlineBmpd:BitmapData;
		
		/** @private */
		protected var _spellingDictionary:SpellingDictionary;
		
		/** @private */
		protected var _contextMenuEnabled:Boolean = true;
		
		/** @private */
		protected var _menu:AbstractSpellingUIPlugin;

		/** @private */
		protected var _customDictionaryEditsEnabled:Boolean = true;

		/**
		 * Creates an instance of SpellingHighlighter.
		 *
		 * @param target The text field or component to spell check. If the target is not a TextField instance, it will iterate through the immediate children of the target to find the largest textfield to use as its text field target.
		 * @param spellingDictionary The SpellingDictionary to use when spell checking. This would normally not be specified, and will default to the defaultSpellingDictionary.
		 * @param pluginFactories The plugin factories to use with this highlighter.
		 */
		public function SpellingHighlighter(target:Object=null,spellingDictionary:SpellingDictionary=null, pluginFactories:Array = null, contextMenu:AbstractSpellingUIPlugin = null) {
			if (defaultUnderlinePattern == null) {
				var bmpd:BitmapData = new BitmapData(4, 2, true, 0);
				bmpd.setPixel32(0,0,0x99FF0000);
				bmpd.setPixel32(0,1,0x39FF0000);
				bmpd.setPixel32(1,0,0xCCFF0000);
				bmpd.setPixel32(1,1,0x99FF0000);
				bmpd.setPixel32(2,0,0x99FF0000);
				bmpd.setPixel32(2,1,0x39FF0000);
				bmpd.setPixel32(3,0,0x49FF0000);
				defaultUnderlinePattern = bmpd;
			}
			
			super(target, null, pluginFactories);
			
			this.spellingDictionary = spellingDictionary;
			_ignoreCase = false;
			_color = 0xFFFF0000;
			
			//Initilize the default context menu.
			contextMenuEnabled = true;
			menu = contextMenu;
		}
		
		public function set menu(value:AbstractSpellingUIPlugin):void {
			_menu = value==null?new ContextMenuPlugin():value;
			draw();
		}
		
		/**
		 * Indicates whether to include custom dictionary editing options in the context menu
		 * displayed when a user right clicks a word in the text field.
		 */
		public function set customDictionaryEditsEnabled(value:Boolean):void {
			_customDictionaryEditsEnabled = value;
			_menu.customDictionaryEditsEnabled = value;
		}
		public function get customDictionaryEditsEnabled():Boolean {
			return _customDictionaryEditsEnabled;
		}

		/**
		 * Indicates whether to display the spell check options in the context menu for
		 * the text field.
		 */
		public function get contextMenuEnabled():Boolean {
			return _contextMenuEnabled;
		}
		public function set contextMenuEnabled(value:Boolean):void {
			_contextMenuEnabled = value;
			invalidate();
		}

		/**
		 * Sets the SpellingDictionary instance to use when spell checking. If set to null, the instance specified by the static SpellingHighlighter.defaultSpellingDictionary property will be used.
		 */
		public function get spellingDictionary():SpellingDictionary {
			return _spellingDictionary;
		}
		public function set spellingDictionary(value:SpellingDictionary):void {
			_spellingDictionary = (spellingDictionary) ? spellingDictionary : (defaultSpellingDictionary) ? defaultSpellingDictionary : SpellingDictionary.getInstance();
			if (!_spellingDictionary.active) {
				_spellingDictionary.addEventListener(SpellingDictionaryEvent.ACTIVE,handleDictionaryActive);
			}
			invalidate();
		}

		/** @private */
		override public function set wordList(wordList:Array):void {
			// do nothing, inherited from TextHighlighter, but not needed here.
		}

		/**
		 * Sets the RGB color of the underline effect. This color will completely overwrite any colors
		 * in the underline pattern. You can specify a 32bit ARGB color value to fade the underline,
		 * or use a 24bit RGB color value to preserve its alpha.
		 */
		override public function set color(value:uint):void {
			super.color = value;
		}

		/**
		 * Sets a custom pattern for the underline effect. This can be a display object or bitmapdata object to use as the repeating underline pattern.
		 * This is drawn into a new BitmapData instance for internal use, and is always returned as a BitmapData object.
		 */
		public function get underlinePattern():IBitmapDrawable {
			return underlineBmpd;
		}
		public function set underlinePattern(value:IBitmapDrawable):void {
			if (underlineBmpd) {
				underlineBmpd.dispose();
			}
			
			if (value == null) {
				underlineBmpd = null;
			} else if (value is BitmapData) {
				underlineBmpd = (value as BitmapData).clone();
			} else {
				underlineBmpd = new BitmapData((value as DisplayObject).width,(value as DisplayObject).height,true,0);
				underlineBmpd.draw(value);
			}
			
			invalidate();
		}

		/** @private */
		override protected function setupListeners(forceOff:Boolean=false):void {
			if (forceOff) { _menu.enabled = false; }
			super.setupListeners(forceOff);
		}
		
		/** @private */
		override protected function draw():void {
			// disable during a draw if the dictionary is not active:
			var enabledVal:Boolean = _enabled;
			_enabled = _enabled && _spellingDictionary.active;
			
			if (plugin is ISpellingHighlighterPlugin) {
				(plugin as ISpellingHighlighterPlugin).underlinePattern = underlineBmpd;
			}
			
			if (_menu) {
				_menu.spellingDictionary = _spellingDictionary;
				_menu.textHighlighterPlugin = plugin;
				_menu.enabled = enabled && _contextMenuEnabled;
				_menu.target = target;
				_menu.customDictionaryEditsEnabled = _customDictionaryEditsEnabled;
			}
			
			super.draw();
			
			_enabled = enabledVal;
		}

		/** @private */
		protected function handleDictionaryActive(evt:SpellingDictionaryEvent):void {
			invalidate();
		}

		/** @private */
		override protected function checkWord(word:String):Boolean {
			return !_spellingDictionary.checkWord(word);
		}
	}
}