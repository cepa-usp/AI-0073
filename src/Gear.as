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
		
		private var _rotacaoInicial:Number = 0;
		
		private var gearSpr:Sprite;
		
		public function Gear(nDentes:int, raio:Number, spr:Sprite) 
		{
			this.mouseChildren = false;
			_nDentes = nDentes;
			_raio = raio;
			gearSpr = spr;
			addChild(gearSpr);
		}
		
		public function update(time:Number):void
		{
			_rotacao = time * omega + _rotacaoInicial;
			gearSpr.rotation = rotacao * 180 / Math.PI % 360;
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
		
		public function set rotacaoInicial(value:Number):void 
		{
			_rotacaoInicial = value;
			gearSpr.rotation = value * 180 / Math.PI % 360;;
		}
		
		public function moveToInicial():void
		{
			this.x = posInicial.x;
			this.y = posInicial.y;
		}
		
	}

}