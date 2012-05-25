package 
{
	import flash.display.Sprite;
	import flash.text.TextField;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class TutorialArrow extends Sprite
	{
		public var labelField:Sprite;
		public var arrowText:String;
		public function TutorialArrow() 
		{
			labelField = this.indicador;
			this.indicador.mouseChildren = false;
			this.indicador.buttonMode = true;
		}
		
		override public function get rotation():Number 
		{
			return super.rotation;
		}
		
		override public function set rotation(value:Number):void 
		{
			super.rotation = value;
			this.indicador.rotation = -value;
		}
		
		public function set label(str:String):void
		{
			this.indicador.label.text = str;
		}
		
	}

}