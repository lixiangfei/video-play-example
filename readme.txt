调用as3 api，实现简单的video播放

flash中由于安全沙箱问题，无法用html2canvas库进行 视频流截图

		进行如下设置可以实现截图
			try
			{
				stream.audioSampleAccess = true;
			} 
			catch(error:Error) 
			{
				
			}