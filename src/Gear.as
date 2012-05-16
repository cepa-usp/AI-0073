package 
{
	import cepa.utils.Cronometer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Gear extends Sprite
	{
		private var _nDentes:int;
		private var _raio:Number;
		private var _omega:Number = 0;
		private var _rotacao:Number;
		public var posFinal:Point;
		public var posInicial:Point;
		
		private var gearSpr:Sprite;
		
		private var internalTimer:Cronometer;
		
		public function Gear(spr:Sprite, cron:Cronometer, raio:Number, nDentes:int, omega:Number) 
		{
			this.mouseChildren = false;
			//gearSpr = gearSprStage;
			gearSpr = spr;
			addChild(gearSpr);
			
			internalTimer = cron;
			_raio = raio;
			_nDentes = nDentes;
			_omega = omega;
		}
		
		public function setCron(cron:Cronometer):void
		{
			internalTimer = cron;
		}
		
		public function startRotating():void
		{
			addEventListener(Event.ENTER_FRAME, rotating);
		}
		
		private function rotating(e:Event):void 
		{
			_rotacao = internalTimer.read() / 1000 * omega * 180 / Math.PI % 360;
			gearSpr.rotation = rotacao;
		}
		
		public function update():void
		{
			rotating(null);
		}
		
		public function stopRotating():void
		{
			removeEventListener(Event.ENTER_FRAME, rotating);
		}
		
		public function get raio():Number 
		{
			return _raio;
		}
		
		public function set raio(value:Number):void 
		{
			_raio = value;
			gearSpr.width = gearSpr.height = 2 * value;
		}
		
		public function get omega():Number 
		{
			return _omega;
		}
		
		public function set omega(value:Number):void 
		{
			_omega = value;
		}
		
		public function get rotacao():Number 
		{
			return _rotacao;
		}
		
		public function get nDentes():int 
		{
			return _nDentes;
		}
		
		public function set nDentes(value:int):void 
		{
			_nDentes = value;
		}
		
		public function moveToInicial():void
		{
			this.x = posInicial.x;
			this.y = posInicial.y;
		}
		
	}

}