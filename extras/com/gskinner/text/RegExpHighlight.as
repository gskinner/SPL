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
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	/*
	* Flex only:
	import mx.core.IToolTip;
	import mx.managers.ToolTipManager;
	*/
	public class RegExpHighlight extends Sprite {
		
		protected var _match:Object;
		/*
		* Flex only:
		protected var toolTip:IToolTip;
		*/
		
		public function RegExpHighlight() {
			addEventListener(MouseEvent.ROLL_OVER,handleOver);
			blendMode = "multiply";
		}
		
		public function setSize(width:Number,height:Number,type:uint=3):void {
			graphics.clear();
			graphics.beginFill(0x00AAFF,0.15);
			graphics.lineStyle(1,0x0099FF,0.45,true);
			var r:Number = (type>>1 == 1) ? 3 : 0;
			var l:Number = (type&1 == 1) ? 3 : 0;
			graphics.drawRoundRectComplex(0,0,width,height,l,r,l,r);
		}
		
		public function set match(value:Object):void {
			_match = value;
		}
		public function get match():Object {
			return _match;
		}
		
		protected function handleOver(evt:MouseEvent):void {
			var ttPoint:Point = new Point(0,0);
			ttPoint = localToGlobal(ttPoint);
			var ttText:String = "match: "+match[0]+"\nindex: "+match.index+"\nlength: "+match[0].length+"\ngroups: "+(match.length-1);
			for (var i:int=1; i<match.length; i++) {
				ttText += "\n   group "+i+": "+(match[i] == null ? "[NO MATCH]" : match[i]);
			}
			/*
			* Flex only:
			toolTip = ToolTipManager.createToolTip(ttText,ttPoint.x+width-20,ttPoint.y+height-2);
			toolTip.x = Math.min(toolTip.x,stage.stageWidth-toolTip.width-5);
			toolTip.y = Math.min(toolTip.y,stage.stageHeight-toolTip.height-5);
			*/
			addEventListener(MouseEvent.ROLL_OUT,handleOut);
		}
		
		protected function handleOut(evt:MouseEvent):void {
			/*
			* Flex only:
			ToolTipManager.destroyToolTip(toolTip);
			*/
			removeEventListener(MouseEvent.ROLL_OUT,handleOut);
		}

	}
}