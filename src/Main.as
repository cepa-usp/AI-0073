package  
{
	import BaseAssets.BaseMain;
	import cepa.utils.Cronometer;
	import com.eclecticdesignstudio.motion.Actuate;
	import com.eclecticdesignstudio.motion.easing.Cubic;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Main extends BaseMain
	{
		private var gearsLayer:Sprite;
		
		private var cronometer:Cronometer;
		private var timerPaused:Boolean;
		
		private var raiosGrandes:Array;
		private var raiosPequenos:Array;
		private var raiosGrandesSpr:Array;
		private var raiosPequenosSpr:Array;
		private var omegasGrandes:Array;
		
		private var gears:Vector.<Gear>;
		private var nGears:int;
		private var maxGears:int = 4;
		private var minGears:int = 2;
		
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
			raiosGrandes = [[100, 10], [110, 10], [120, 10], [130, 10], [140, 10], [150, 10]];
			raiosPequenos = [[20, 10], [25, 10], [30, 10], [35, 10], [40, 10]];
			
			raiosGrandesSpr = [new Gear100(), new Gear110(), new Gear120(), new Gear130(), new Gear140(), new Gear150()];
			raiosPequenosSpr = [new Gear20(), new Gear25(), new Gear30(), new Gear35(), new Gear40()];
			
			//omegasGrandes = [0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6];
			omegasGrandes = [3, 3.5, 4, 4.5, 5, 5.5, 6];
			
			cronometer = new Cronometer();
			timerPaused = true;
			gears = new Vector.<Gear>();
			
			gearsLayer = new Sprite();
			addChild(gearsLayer);
			setChildIndex(gearsLayer, 0);
			
			cronometro.time.mouseEnabled = false;
			infoBar.mouseEnabled = false;
		}
		
		private function preparaBolinhas():void
		{
			for each (var item:Gear in gears)
			{
				item.update();
			}
			
			if (gears.length > 0) {
				for (var i:int = gears.length - 1; i >= 0 ; i--) 
				{
					gearsLayer.removeChild(gears[i]);
				}
				
				gears.splice(0, gears.length);
			}
			
			var rP:Array = [];
			var rPSpr:Array = [];
			for (i = 0; i < raiosPequenos.length; i++) 
			{
				rP.push(raiosPequenos[i]);
				rPSpr.push(raiosPequenosSpr[i]);
			}
			
			nGears = Math.round(Math.random() * (maxGears - minGears)) + minGears;
			var nSort:int;
			
			for (i = 0; i < nGears; i++)
			{
				if (i == 0) {//Sorteia raio grande
					nSort = Math.floor(Math.random() * raiosGrandes.length);
					gears.push(new Gear(raiosGrandesSpr[nSort], cronometer, raiosGrandes[nSort][0], raiosGrandes[nSort][1], omegasGrandes[Math.floor(Math.random() * omegasGrandes.length)]));
				}else {//sorteia raios(s) pequeno(s)
					nSort = Math.floor(Math.random() * rP.length);
					gears.push(new Gear(rPSpr[nSort], cronometer, rP[nSort][0], rP[nSort][1], gears[i - 1].omega * (gears[i - 1].raio / rP[nSort][0]) * -1));
					rP.splice(nSort, 1);
					rPSpr.splice(nSort, 1);
				}
				gearsLayer.addChild(gears[gears.length - 1]);
			}
			
			/*
			for (i = 0; i < nGears; i++)
			{
				if (i == 0) {
					gears[i].x = (Math.random() * 100) + 200;
					gears[i].y = (Math.random() * 100) + 200;
				}else {
					var angle:Number = Math.random() * 30 * (Math.random() > 0.5 ? 1 : -1);
					gears[i].x = gears[i-1].x + (gears[i - 1].raio + gears[i].raio) * Math.cos(angle * Math.PI / 180);
					gears[i].y = gears[i-1].y + (gears[i - 1].raio + gears[i].raio) * Math.sin(angle * Math.PI / 180);
				}
			}
			*/
			
			animatedEntrance();
		}
		
		private function animatedEntrance():void
		{
			var left:Boolean = (Math.random() > 0.5 ? true : false);
			
			var posX:Number;
			var posY:Number;
			
			var delay:Number = 0;
			
			for (var i:int = 0; i < nGears; i++)
			{
				if (i == 0) {
					if (left) {
						gears[i].posFinal = new Point((Math.random() * 100) + 200, (Math.random() * 100) + 200);
						posX = -200;
					}
					else {
						gears[i].posFinal = new Point(500 - (Math.random() * 100), (Math.random() * 100) + 200);
						posX = 900;
					}
					posY = (Math.random() > 0.5 ? 0 : 500);
				}else {
					var angle:Number = Math.random() * 30 * (Math.random() > 0.5 ? 1 : -1);
					if(left){
						gears[i].posFinal = new Point(
							gears[i - 1].posFinal.x + (gears[i - 1].raio + gears[i].raio) * Math.cos(angle * Math.PI / 180), 
							gears[i - 1].posFinal.y + (gears[i - 1].raio + gears[i].raio) * Math.sin(angle * Math.PI / 180)
						);
					}else {
						gears[i].posFinal = new Point(
							gears[i - 1].posFinal.x - (gears[i - 1].raio + gears[i].raio) * Math.cos(angle * Math.PI / 180), 
							gears[i - 1].posFinal.y + (gears[i - 1].raio + gears[i].raio) * Math.sin(angle * Math.PI / 180)
						);
					}
					
					if (i == 1) {
						posX = (left ? 700 : 0);
						posY =  - 100;
					}
					if (i == 2) {
						posX = (left ? 800: -100);
						posY = (angle < 0 ? 0 : 500);
					}
					if (i == 3) {
						posX = (left ? 700 : 0);
						posY = 600;
					}
				}
				
				gears[i].posInicial = new Point(posX, posY);
				gears[i].moveToInicial();
				
				Actuate.tween(gears[i], 0.5, { x: gears[i].posFinal.x, y: gears[i].posFinal.y } ).ease(Cubic.easeOut).delay(delay);
				delay += 0.1;
			}
		}
		
		private function animatedExit():void
		{
			var delay:Number = 0;
			for (var i:int = nGears - 1; i >= 0; i--)
			{
				if (i == 0) Actuate.tween(gears[i], 0.5, { x: gears[i].posInicial.x, y: gears[i].posInicial.y } ).ease(Cubic.easeOut).onComplete(preparaBolinhas).delay(delay);
				else Actuate.tween(gears[i], 0.5, { x: gears[i].posInicial.x, y: gears[i].posInicial.y } ).ease(Cubic.easeOut).delay(delay);
				
				delay += 0.1;
			}
		}
		
		private function initCronometro():void
		{
			cronometro.reset.buttonMode = true;
			cronometro.start.buttonMode = true;
			
			cronometro.start.addEventListener(MouseEvent.CLICK, startCronometro);
			cronometro.reset.addEventListener(MouseEvent.CLICK, resetaCronometro);
		}
		
		private function startCronometro(e:MouseEvent):void 
		{
			if (timerPaused) 
			{
				timerPaused = false;
				cronometer.start();
				//for each (var item:Gear in gears)
				//{
					//item.startRotating();
				//}
				addEventListener(Event.ENTER_FRAME, refreshCron);
			} 
			else 
			{
				timerPaused = true;
				cronometer.pause();
				removeEventListener(Event.ENTER_FRAME, refreshCron);
			}
		}
		
		private function refreshCron(e:Event):void 
		{
			cronometro.time.text = (cronometer.read() / 1000).toFixed(1);
			for each (var item:Gear in gears)
			{
				item.update();
			}
		}
		
		private function resetaCronometro(e:MouseEvent):void 
		{
			
			removeEventListener(Event.ENTER_FRAME, refreshCron);
			
			cronometer.stop();
			cronometer.reset();
			
			//for each (var item:Gear in gears)
			//{
				//item.stopRotating();
				//item.update();
			//}
			
			cronometro.time.text = "0s";
			timerPaused = true;
			
		}
		
		private function setInfo(e:MouseEvent):void 
		{
			var obj:* = e.target;
			var classe:String = getQualifiedClassName(obj);
			
			switch(classe) {
				case "Cronometro":
					setInfoMsg("Cronômetro");
					break;
				case "Start":
					if(cronometer.isRunning()) setInfoMsg("Pausa o cronômetro.");
					else setInfoMsg("Inicia o cronômetro");
					break;
				case "Reset":
					setInfoMsg("Reinicia o cronômetro");
					break;
				case "Btn_info":
					setInfoMsg("Inicia tutorial.");
					break;
				case "Btn_Instructions":
					setInfoMsg("Orientações.");
					break;
				case "Btn_Reset":
					setInfoMsg("Reinicia a atividade.");
					break;
				case "Btn_CC":
					setInfoMsg("Liçensa e créditos.");
					break;
				case "Gear":
					setInfoMsg("Engrenagem de raio " + String(Gear(e.target).raio) + " unidades de comprimento.");
					break;
				
				default:
					//if (e.target is Gear) {
						//setInfoMsg("Engrenagem de raio " + String(Gear(e.target).raio) + " unidades.");
					//}
					break;
			}
			
		}
		
		private function setInfoOut(e:MouseEvent):void 
		{
			setInfoMsg("");
		}
		
		private function setInfoMsg(msg:String):void
		{
			infoBar.texto.text = msg;
		}
		
		private function addListeners():void
		{
			stage.addEventListener(MouseEvent.MOUSE_OVER, setInfo);
			stage.addEventListener(MouseEvent.MOUSE_OUT, setInfoOut);
		}
		
		override public function reset(e:MouseEvent = null):void
		{
			resetaCronometro(null);
			//preparaBolinhas();
			animatedExit();
		}
		
		override public function iniciaTutorial(e:MouseEvent = null):void
		{
			
		}
	}

}