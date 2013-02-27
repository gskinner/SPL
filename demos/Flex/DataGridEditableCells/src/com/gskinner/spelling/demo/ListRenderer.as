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
package com.gskinner.spelling.demo {
	
	import mx.core.UIComponent;
	import mx.controls.listClasses.BaseListData;
	import mx.containers.HBox;
	import mx.controls.Text;
	
	import mx.core.UITextField;
	import flash.text.TextFieldType;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import mx.events.ListEvent;
	import flash.filters.DropShadowFilter;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import mx.controls.List;
	import com.gskinner.spelling.SPLTagFlex;
	import com.gskinner.spelling.SpellingHighlighter;
	import mx.controls.TextInput;
	import mx.controls.Label;
	
	public class ListRenderer extends UIComponent implements mx.core.IDataRenderer,mx.controls.listClasses.IDropInListItemRenderer,mx.controls.listClasses.IListItemRenderer {
		
		protected var _data:Object;
		protected var _listData:BaseListData;
		protected var label:Label;
		protected var countTxt:Text;
		
		public function ListRenderer() {
			_spellingHighlighter = new SpellingHighlighter();
		}
		
		protected var _spellingHighlighter:SpellingHighlighter
		
		public function set data(p_data:Object):void {
			_data = p_data;
			
			label.text = (_data is String)?p_data as String:_data.label;
		}
		
		public function get data():Object { return _data; }
		
		public function set listData(p_data:BaseListData):void {
			_listData = p_data;
		}
		public function get listData():BaseListData { return _listData; }
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			label.width = unscaledWidth;
			label.height = unscaledHeight;
			_spellingHighlighter.update();
			super.updateDisplayList(unscaledWidth, unscaledHeight);
		}
		
		override protected function createChildren():void {
        	super.createChildren();
        	
        	label = new Label();
        	addChild(label);
        	
        	_spellingHighlighter.target = label;
	 	}
		
	}
	
}