package 
{
	import cepa.utils.Angle;
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
		private var _rotacao:Angle = new Angle();
		private var _rotacaoInicial:Angle = new Angle();
		public var angle:Angle = new Angle();
		
		public var posFinal:Point;
		public var posInicial:Point;
		
		private var gearSpr:Sprite;
		
		public function Gear(nDentes:int, raio:Number, spr:Sprite) 
		{
			this.mouseChildren = false;
			_nDentes = nDentes;
			_raio = raio;
			gearSpr = spr;
			addChild(gearSpr);
			
			_rotacao.domain = Angle.MINUS_PI_TO_PLUS_PI;
			_rotacaoInicial.domain = Angle.MINUS_PI_TO_PLUS_PI;
		}
		
		public function setIndicador():void
		{
			var ind:IndicadorRoda = new IndicadorRoda();
			ind.x = -_raio / 1.3 - ind.height;
			ind.y = 0;
			ind.rotation = 90;
			addChild(ind);
			setChildIndex(ind, 0);
		}
		
		public function update(time:Number):void
		{
			_rotacao.radians = time * omega + _rotacaoInicial.radians;
			gearSpr.rotation = _rotacao.degrees;
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
			return _rotacao.degrees;
		}
		
		public function get nDentes():int 
		{
			return _nDentes;
		}
		
		public function set nDentes(value:int):void 
		{
			_nDentes = value;
		}
		
		public function set rotacaoInicial(value:Number):void 
		{
			_rotacaoInicial.degrees = value;
			gearSpr.rotation = _rotacaoInicial.degrees;
		}
		
		public function get rotacaoInicial():Number 
		{
			return _rotacaoInicial.degrees;
		}
		
		public function moveToInicial():void
		{
			this.x = posInicial.x;
			this.y = posInicial.y;
		}
		
		public function get beta():Number {
			var a:Number = 360 + rotacaoInicial;
			while (a < 270) { 
				a += (360 / nDentes);
			}
			return (270 - a);
			
		}
		
		public function get delta():Number
		{
			return 360 / _nDentes;
		}
		
		public function eraseMark():void
		{
			for (var i:int = 0; i < gearSpr.numChildren; i++) 
			{
				if (gearSpr.getChildAt(i) is IndicadorRoda) {
					gearSpr.getChildAt(i).visible = false;
					return;
				}
			}
		}
		
	}

}