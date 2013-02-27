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
package com.gskinner.containers {

	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.events.MouseEvent;
	import flash.events.Event
	import flash.geom.Point;
	import fl.controls.Button;
	import fl.core.InvalidationType;
	import fl.core.UIComponent;
	
	public class Window extends UIComponent {
		
		// Public Properties:
		public var closeButton:Button;
		public var bg:Sprite;
		public var windowTitle:TextField;
		public var header:Sprite;
		
		// Private Properties:
		protected var _title:String;
		protected var _showCloseButton:Boolean;
		protected var _autoSizeToContent:Boolean = true;
		protected var _draggable:Boolean = true;
		protected var _content:DisplayObject;
		protected var dragOffset:Point;
		
		private static var defaultStyles:Object = {
												  paddingLeft:5, paddingRight:5, paddingTop:5, paddingBottom:5,
												  headerSkin:'WindowHeader_skin', contentBackground:'Window_contentBg',
												  closeButton_upSkin:'CloseButton_upSkin', closeButton_downSkin:'CloseButton_downSkin',
												  closeButton_overSkin:'CloseButton_overSkin', closeButton_disabledSkin:'CloseButton_disabledSkin',
												  closeButton_selectedSkin:'CloseButton_selectedSkin'
												  };
												  
		public static function getStyleDefinition():Object { 
			return mergeStyles(defaultStyles, UIComponent.getStyleDefinition());
		}
		
		protected static const CLOSE_BUTTON_STYLES:Object = {
															upSkin:'closeButton_upSkin',
															overSkin:'closeButton_overSkin',
															selectedSkin:'closeButton_selectedSkin',
															downSkin:'closeButton_downSkin',
															disabledSkin:'CloseButton_disabledSkin'
															};
		
		public function Window() {
			super();
		}
		
		override protected function configUI():void {
			super.configUI();
			windowTitle = new TextField();
			windowTitle.type = TextFieldType.DYNAMIC;
			windowTitle.selectable = false;
			
			closeButton = new Button();
			closeButton.buttonMode = true;
			closeButton.useHandCursor = true;
			closeButton.addEventListener(MouseEvent.CLICK, doClose, false, 0, true);
			
			addChild(windowTitle);
		}
		
		// Public Methods:
		public function set autoSizeToContent(p_autoSizeToContent:Boolean):void { _autoSizeToContent =  p_autoSizeToContent;  }
		public function get autoSizeToContent():Boolean { return _autoSizeToContent; }
		
		public function set draggable(p_draggable:Boolean):void { _draggable =  p_draggable; invalidate(InvalidationType.STATE); }
		public function get draggable():Boolean { return _draggable; }
		
		public function set title(p_title:String):void { windowTitle.text = _title =  p_title; invalidate(InvalidationType.STATE); }
		public function get title():String { return _title; }
		
		public function set showCloseButton(p_show:Boolean):void { _showCloseButton = p_show; invalidate(InvalidationType.STATE); }
		public function get showCloseButton():Boolean { return _showCloseButton; }
		
		public function init(p_content:DisplayObject, p_title:String='', p_showClose:Boolean=true):void {
			title = p_title;
			showCloseButton = p_showClose;
			
			_content = p_content;
			
			invalidate(InvalidationType.ALL);
		}
		
		protected function initDraggable():void {
			if (_draggable) {
				header.addEventListener(MouseEvent.MOUSE_DOWN, doStartDrag, false, 0, true);
				header.addEventListener(MouseEvent.CLICK, doStopDrag, false, 0, true);
			} else {
				header.removeEventListener(MouseEvent.MOUSE_DOWN, doStartDrag);
				header.removeEventListener(MouseEvent.CLICK, doStopDrag);
			}
		}
		
		protected function doStartDrag(event:MouseEvent):void {
			dragOffset = new Point(stage.mouseX - x, stage.mouseY - y);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, doDrag, false, 0, true);
		}
		
		protected function doStopDrag(event:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, doDrag);
		}
		
		protected function doDrag(event:MouseEvent):void {
			x = Math.max(0, Math.min(stage.mouseX - dragOffset.x, stage.stageWidth - width));
			y = Math.max(0, Math.min(stage.mouseY - dragOffset.y, stage.stageHeight - height));
		}
		
		protected function drawLayout():void {
			header.width = width;
			bg.height = height - header.height;
			bg.y = header.height;
			
			if (_content && contains(_content)) { removeChild(_content); }
			
			if (_content) {
				_content.addEventListener(Event.RENDER, onContentRendered, false, 0, true);
				addChild(_content);
			}
			
			windowTitle.y = 0;
			windowTitle.x = getStyleValue('paddingLeft') as uint;
		}
		
		protected function onContentRendered(event:Event):void {
			_content.removeEventListener(Event.RENDER, onContentRendered);
			
			_content.y = header.height + (getStyleValue('paddingTop') as uint);
			_content.x = getStyleValue('paddingLeft') as uint;
			
			if (_autoSizeToContent) {
				bg.width = _content.width +  (getStyleValue('paddingLeft') as uint) + (getStyleValue('paddingRight') as uint);
				bg.height = _content.height +  (getStyleValue('paddingTop') as uint) + (getStyleValue('paddingBottom') as uint);
				
				header.width = bg.width;
			}
			
			closeButton.visible = showCloseButton;
			
			if (showCloseButton) {
				closeButton.x = header.width - closeButton.width - (getStyleValue('paddingLeft') as uint);
			}
		}
		
		protected function drawChildren():void {
			if (header && contains(header)) { removeChild(header); }
			if (bg && contains(bg)) { removeChild(bg); }
			if (closeButton && contains(closeButton)) { removeChild(closeButton); }
			
			header = getDisplayObjectInstance(getStyleValue('headerSkin')) as Sprite;
			bg = getDisplayObjectInstance(getStyleValue('contentBackground')) as Sprite;
			
			var closeBtnSkin:Sprite = getDisplayObjectInstance(getStyleValue('closeButton_upSkin')) as Sprite;
			closeButton.width = closeBtnSkin.width;
			closeButton.height = closeBtnSkin.height;
			
			copyStylesToChild(closeButton, CLOSE_BUTTON_STYLES);
			
			addChild(bg);
			addChild(header);
			addChild(closeButton);
			setChildIndex(windowTitle, numChildren-1);
			
			windowTitle.defaultTextFormat =getStyleValue('defaultTextFormat') as TextFormat;
			windowTitle.setTextFormat(getStyleValue('defaultTextFormat') as TextFormat);
		}
		
		protected function doClose(event:MouseEvent):void {
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		override protected function draw():void {
			if (isInvalid(InvalidationType.STYLES)) {
				drawChildren();
			}
			
			if (isInvalid(InvalidationType.STATE)) {
				initDraggable();
			}
			
			if (isInvalid(InvalidationType.SIZE), isInvalid(InvalidationType.STATE)) {
				drawLayout();
			}
			
			super.draw();
		}

	}
}