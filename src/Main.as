package  
{
	import BaseAssets.BaseMain;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Main extends BaseMain
	{
		private var timerPaused:Boolean;
		private var timerStart:Number;
		private var timeElapsed:Number;
		
		private var raiosGrandes:Array;
		private var raiosPequenos:Array;
		private var omegasGrandes:Array;
		private var omegaGrande:Number;
		private var omegaPequeno:Number;
		
		public function Main() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			initVariables();
			preparaBolinhas();
			initCronometro();
			addListeners();
			
		}
		
		private function initVariables():void
		{
			raiosGrandes = [100, 110, 120, 130, 140, 150];
			raiosPequenos = [20, 25, 30, 35, 40];
			omegasGrandes = [0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6];
		}
		
		private function preparaBolinhas():void
		{
			var raioGrande:int = Math.floor(Math.random() * raiosGrandes.length);
			var raioPequeno:int = Math.floor(Math.random() * raiosPequenos.length);
			
			bolaGrande.rotation = 0;
			bolaPequena.rotation = 0;
			
			bolaGrande.width = 2 * raiosGrandes[raioGrande];
			bolaGrande.height = 2 * raiosGrandes[raioGrande];
			bolaPequena.width = 2 * raiosPequenos[raioPequeno];
			bolaPequena.height = 2 * raiosPequenos[raioPequeno];
			
			bolaPequena.x = bolaGrande.x + raiosGrandes[raioGrande] + raiosPequenos[raioPequeno];
			//bolaPequena.x = bolaGrande.x + bolaGrande.width / 2 + bolaPequena.width / 2;
			rPequeno.x = bolaPequena.x - rPequeno.width / 2;
			
			omegaGrande = omegasGrandes[Math.floor(Math.random() * omegasGrandes.length)];
			omegaPequeno = omegaGrande * raiosGrandes[raioGrande] / raiosPequenos[raioPequeno];
			
			rGrande.text = "R = " + String(raiosGrandes[raioGrande]);
			rPequeno.text = "r = " + String(raiosPequenos[raioPequeno]);
		}
		
		private function rodaBolinhas():void
		{
			//var tempo:Number = Number(cronometro.time.text.replace("s", "").replace(",","."));
			//trace(tempo);
			var rotationGrande:Number = timeElapsed / 1000 * omegaGrande * 180/Math.PI % 360;
			var rotationPequeno:Number = timeElapsed / 1000 * omegaPequeno * 180 / Math.PI % 360;
			
			bolaGrande.rotation = rotationGrande;
			bolaPequena.rotation = -rotationPequeno;
		}
		
		private function initCronometro():void
		{
			timerPaused = true;
			
			cronometro.reset.buttonMode = true;
			cronometro.start.buttonMode = true;
			
			cronometro.start.addEventListener(MouseEvent.CLICK, startCronometro);
			cronometro.reset.addEventListener(MouseEvent.CLICK, resetaCronometro);
		}
		
		private function startCronometro(e:MouseEvent):void 
		{
			if (timerPaused) 
			{
				timerStart = getTimer();
				timerPaused = false;
				addEventListener(Event.ENTER_FRAME, enterFrameCronometro);
			} 
			else 
			{
				timerPaused = true;
				removeEventListener(Event.ENTER_FRAME, enterFrameCronometro);
			}
		}
		
		private function resetaCronometro(e:MouseEvent):void 
		{
			timeElapsed = 0;
			cronometro.time.text = "0s";
			timerPaused = true;
			removeEventListener(Event.ENTER_FRAME, enterFrameCronometro);
		}
		
		private function enterFrameCronometro(e:Event):void 
		{
			timeElapsed = (getTimer() - timerStart);
			cronometro.time.text = (timeElapsed / 1000).toFixed(1).replace(".", ",") + "s";
			rodaBolinhas();
		}
		
		private function addListeners():void
		{
			//resetButton.addEventListener(MouseEvent.CLICK, reset);
		}
		
		override public function reset(e:MouseEvent = null):void
		{
			resetaCronometro(null);
			preparaBolinhas();
		}
		
		override public function iniciaTutorial(e:MouseEvent = null):void
		{
			
		}
	}

}