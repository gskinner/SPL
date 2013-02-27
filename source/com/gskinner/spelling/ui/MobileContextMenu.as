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
package com.gskinner.spelling.ui {
	
	import flash.display.DisplayObjectContainer;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.utils.Dictionary;
	
	/**
	 * Context menu displayed when using the MobileContextMenuPlugin.
	 * 
	 */
	public class MobileContextMenu extends SPLComponent {
		
		/** @private */
		protected var _items:Array;
		
		/** @private */
		protected var _itemHeight:Number = 30;
		
		/** @private */
		protected var _itemHash:Dictionary;
		
		/** @private */
		protected var _renderHash:Dictionary;
		
		/** @private */
		protected var _padding:int = 1;
		
		/** @private */
		protected var hiddenItem:SPLContextMenuItemRenderer;
		
		/** @private */
		protected var itemContainer:Sprite;
		
		/** @private */
		protected var hilite:Shape;
		
		public function MobileContextMenu() {
			_items = [];
			_itemHash = new Dictionary(true);
			_renderHash = new Dictionary(true);
			
			super();
			
			filters = [new DropShadowFilter(4, 45, 0, 0.35)];
		}
		
		/*
		* Public API
		*/
		
		/**
		 * Shows this menu in the correct context on screen,
		 * normally we will attach this to stage.
		 * 
		 * @param parent The parent item to attach this menu to.
		 * @param x The x position on the parent to attach this menu to.
		 * @param y The y position on the parent to attach this menu to.
		 * 
		 */
		public function display(parent:DisplayObjectContainer, x:Number, y:Number):void {
			if (!parent.contains(this))	parent.addChild(this);
			
			// logic to make sure we are on screen/entirely visible
			this.x = x;
			this.y = y;
			
			visible = true;
		}
		
		/**
		 * Removes this item from the display list.
		 * 
		 */
		public function hide():void {
			if (parent) { parent.removeChild(this);	}
			visible = false;
		}
		
		/**
		 * Adds a new row to this menu.
		 * 
		 */
		public function addItem(item:SPLContextMenuItem):void {
			if (!_itemHash[item]) {
				
				_items[_items.length] = item;
				
				_itemHash[item] = true;
				
				invalidate();
			}
		}
		
		/**
		 * Removes an item from view.
		 * 
		 */
		public function removeItem(item:SPLContextMenuItem):void {
			var index:int = _items.indexOf(item);
			if (index != -1) { _items.splice(index, 1); }
			
			var renderer:SPLContextMenuItemRenderer = _itemHash[item];
			
			_itemHash[item] = null;
			delete _itemHash[item];
			
			_renderHash[renderer] = null;
			delete _renderHash[renderer];
			
			invalidate();
			
		}
		
		/**
		 * Removes all items from view.
		 * 
		 */
		public function removeAll():void {									
			_items.length = 0;
			_itemHash = new Dictionary(true);
			_renderHash = new Dictionary(true);
			
			invalidate();
		}
		
		/**
		 * Internal
		 */
		/** @private */
		override protected function draw():void {
			while (itemContainer.numChildren) { itemContainer.removeChildAt(0).removeEventListener(MouseEvent.CLICK, handleItemClick); }
			
			var nw:Number = 0;
			var nh:Number = 0;
			for (var n:* in _itemHash) {
				hiddenItem.label = n.caption;
				hiddenItem.drawNow();
				nw = Math.max(nw, hiddenItem.textWidth+_padding);
			}
			
			var render:SPLContextMenuItemRenderer;
			var separator:SPLContextMenuItemSeparator;
			var item:SPLContextMenuItem;
			for (var i:int= 0, l:int=_items.length; i < l; i++) {
				item = _items[i];
				
				if (item.separatorBefore) { 
					separator = new SPLContextMenuItemSeparator();
					separator.enabled = false;
					separator.y = nh;
					separator.width = nw;
					separator.height = _itemHeight >> 1;
					separator.drawNow();
					nh += _itemHeight >> 1;
					itemContainer.addChild(separator);
				}
				
				render = new SPLContextMenuItemRenderer(item.caption);
				render.addEventListener(MouseEvent.CLICK, handleItemClick);
				render.enabled = item.enabled;
				render.y = nh;
				render.height = _itemHeight;
				render.width = nw;
				render.drawNow();
				nh += _itemHeight;
				itemContainer.addChild(render);
				
				_renderHash[render] = item;
				_itemHash[item] = render;
			}
			
			_width = nw;
			_height = nh+_padding;
			
			itemContainer.x = itemContainer.y = _padding;
			hilite.x = hilite.y = _padding;
			
			
			var g:Graphics = hilite.graphics;
			g.clear();
			
			var m:Matrix = new Matrix();
			m.createGradientBox(_width, 16, Math.PI/2);
			
			g.beginGradientFill(GradientType.LINEAR, [0xb3b3b3, 0xb3b3b3], [1, 0.25], [0, 255], m);
			g.drawRect(0, 0, _width, 16);
			g.endFill();
			
			g = graphics;
			g.clear();
			g.beginFill(0x1a1a1a);
			g.drawRoundRect(0, 0, _width+(_padding*2), _height+_padding, 0);
			
			g.endFill();
		}
		
		/** @private */
		override protected function createChildren():void {
			hiddenItem = new SPLContextMenuItemRenderer('');
			
			addChild(itemContainer = new Sprite);
			addChild(hilite = new Shape);
		}
		
		/*
		* Event Handlers
		*/
		/** @private */
		protected function handleItemClick(event:MouseEvent):void {
			var renderer:SPLContextMenuItemRenderer = event.target as SPLContextMenuItemRenderer;
			var item:SPLContextMenuItem = _renderHash[event.target];
			
			if (item) { item.dispatchEvent(new SPLContextMenuEvent(SPLContextMenuEvent.MENU_ITEM_SELECT)); }
		}
	}
}