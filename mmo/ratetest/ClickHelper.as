package mmo.ratetest
{
	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;

	/**
	 * @author lixiangfei <br>
	 * 资源点击事件监听工具类<br>
	 * var clickHelper:ClickHelper = new ClickHelper(res);<br>
	 * clickHelper.regClickFunc("btnClose", function onClose():void{});<br>
	 * targetName为实际目标原件的名字<br>
	 * clickHelper.regRegexFunc("btnClose[0-9]+", function onCloseReg(targetName:String):void{});
	 * */
	public class ClickHelper extends EventDispatcher
	{
		public var res:DisplayObject;
		
		private var stateButtonEnable:Boolean = true;
		/**停止时间调度流程*/
		private var stopEvent:Boolean;
		/**普通函数注册*/
		private var clickFuncDictionary:Dictionary;
		/**正则表达式注册*/
		private var regexFuncDictionary:Dictionary;
		
		public function ClickHelper(context:DisplayObject)
		{
			this.clickFuncDictionary = new Dictionary(true);
			this.regexFuncDictionary = new Dictionary(true);
			this.res = context;
			this.res.addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
			this.res.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		/**
		 * 设置为false时,当按钮enable为false,禁止该按钮的点击事件
		 * */
		public function setStateButtonEnable(value:Boolean):void
		{
			this.stateButtonEnable = value;
		}
		
		public function setStopImmediatePropagation(value:Boolean):void
		{
			this.stopEvent = value;
		}
		
		public function regClickFunc(btnName:String, callBack:Function, theObj:* = null, argArray:Array = null):void
		{
			this.clickFuncDictionary[btnName] = {"func":callBack, "theObj":theObj, "argArray":argArray};
		}
		
		public function rmClickFunc(btnName:String):void
		{
			this.clickFuncDictionary[btnName] = null;
			delete clickFuncDictionary[btnName];
		}
		
		public function regRegexFunc(pattern:*, callBack:Function, theObj:* = null, argArray:Array = null):void
		{
			this.regexFuncDictionary[pattern] = {"func":callBack, "theObj":theObj, "argArray":argArray};
		}
		
		private function onClick(evt:MouseEvent):void
		{
			if(this.stopEvent)
			{
				evt.stopImmediatePropagation();
			}
			/**如果target是按钮,并且statebuttonEnable为false,按钮设置为不可点击,返回*/
			if(!stateButtonEnable && (evt.target as SimpleButton) && SimpleButton(evt.target).enabled == false)
			{
				return;
			}
			var targetName:String = evt.target.name;
			var isHit:Boolean = false;
			if(this.clickFuncDictionary.hasOwnProperty(targetName))
			{
				var clickFuncObj:Object = this.clickFuncDictionary[targetName];
				applyFunc(clickFuncObj["func"], clickFuncObj["theObj"], clickFuncObj["argArray"]);
				isHit = true;
			}else
			{
				for(var regex:* in regexFuncDictionary)
				{
					if(targetName.match(regex))
					{
						var regexFuncObj:Object = this.regexFuncDictionary[regex];
						var func:Function  = regexFuncObj["func"];
						var argArray:Array = regexFuncObj["argArray"];
						if(argArray)
						{
							argArray = [targetName].concat(argArray);
						}else
						{
							argArray = [targetName];
						}
						applyFunc(func, regexFuncObj["theObj"], argArray);
						isHit = true;
					}
				}
			}
			
			if(isHit)
			{
				this.dispatchEvent(new ClickHelperEvent(ClickHelperEvent.ON_HIT_REGISTER, targetName));
			}
		}
		
		private function onRemoved(evt:Event):void
		{
			dispose();
		}
		
		public function dispose():void
		{
			if(this.res == null)
			{
				return;
			}
			this.res.removeEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
			this.res.removeEventListener(MouseEvent.CLICK, onClick);
			this.res = null;
			for(var clickFuncKey:String in clickFuncDictionary)
			{
				this.clickFuncDictionary[clickFuncKey] = null;
				delete clickFuncDictionary[clickFuncKey];
			}
		}
		
		private function applyFunc(func:Function, thisArg:*=null, argArray:*=null):void
		{
			if(func != null)
			{
				func.apply(thisArg, argArray);
			}
		}
	}
}