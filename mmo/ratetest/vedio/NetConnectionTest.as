package mmo.ratetest.vedio
{
	import flash.display.Sprite;
	import flash.system.Security;
	
	public class NetConnectionTest extends Sprite
	{
		public function NetConnectionTest()
		{
			trace("pageDomain:",Security.pageDomain);
			var netConEx:NetConnectionExample = new NetConnectionExample(stage);
			addChild(netConEx);
		}
	}
}