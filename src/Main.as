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
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import pipwerks.SCORM;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Main extends BaseMain
	{
		private var gearsLayer:Sprite;
		
		private var cronometer:Cronometer;
		private var cronometerGear:Cronometer;
		private var timerPaused:Boolean;
		
		private var nDentesBig:Array;
		private var nDentesSmall:Array;
		
		private var omegas:Array;
		
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
			
			if (ExternalInterface.available) {
				initLMSConnection();
				
				if (!completed) iniciaTutorial();
			}else {
				iniciaTutorial();
			}
		}
		
		private function initVariables():void
		{
			initGearsDentes();
			omegas = [3, 3.5, 4, 4.5, 5, 5.5, 6];
			
			cronometer = new Cronometer();
			cronometerGear = new Cronometer();
			timerPaused = true;
			gears = new Vector.<Gear>();
			
			gearsLayer = new Sprite();
			addChild(gearsLayer);
			setChildIndex(gearsLayer, 0);
			
			cronometro.time.mouseEnabled = false;
			infoBar.mouseEnabled = false;
		}
		
		private function initGearsDentes():void
		{
			//nDentesSmall = [8, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24];
			//nDentesBig = [12, 25, 26, 27, 28, 29, 30, 32, 33, 34, 35, 36];
			nDentesSmall = [10, 15, 20];
			nDentesBig = [25, 30, 35];
		}
		
		private function preparaBolinhas():void
		{
			if (gears.length > 0) {
				for (var i:int = gears.length - 1; i >= 0 ; i--) 
				{
					gearsLayer.removeChild(gears[i]);
				}
				
				gears.splice(0, gears.length);
			}
			
			initGearsDentes();
			
			nGears = Math.round(Math.random() * (maxGears - minGears)) + minGears;
			//nGears = 3;
			var nSort:int;
			
			for (i = 0; i < nGears; i++)
			{
				if (i == 0) {//Sorteia raio grande
					nSort = Math.floor(Math.random() * nDentesBig.length);
					//nSort = 0;
					var bGear:Gear = new Gear(nDentesBig[nSort], getRaio(nDentesBig[nSort]), new (getDefinitionByName("Gear" + String(nDentesBig[nSort]))));
					bGear.omega = Math.random() * 2 + 0.2;
					//bGear.omega = omegas[Math.floor(Math.random() * omegas.length)];
					//bGear.omega = 1;
					bGear.scaleX = bGear.scaleY = 1.3;
					gears.push(bGear);
				}else {//sorteia raios(s) pequeno(s)
					nSort = Math.floor(Math.random() * nDentesSmall.length);
					//nSort = 0;
					var sGear:Gear = new Gear(nDentesSmall[nSort], getRaio(nDentesSmall[nSort]), new (getDefinitionByName("Gear" + String(nDentesSmall[nSort]))));
					sGear.omega = gears[i - 1].omega * (gears[i - 1].raio / sGear.raio) * -1;
					sGear.scaleX = sGear.scaleY = 1.3;
					gears.push(sGear);
					nDentesSmall.splice(nSort, 1);
				}
				gearsLayer.addChild(gears[gears.length - 1]);
			}
			animatedEntrance();
		}
		
		private var menorRaio:Number = 84.5 * 1.3;
		private var minDentes:int = 35;
		
		private function getRaio(nDentes:int):Number 
		{
			return (menorRaio * nDentes) / minDentes;
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
					//var angle:Number = Math.random() * 30 * (Math.random() > 0.5 ? 1 : -1);
					var angle:Number = 0;
					setInicialAngle(gears[i - 1], angle, gears[i]);
					if(left){
						gears[i].posFinal = new Point(
							gears[i - 1].posFinal.x + (gears[i - 1].raio + gears[i].raio) * Math.cos(angle * Math.PI / 180), 
							gears[i - 1].posFinal.y + (gears[i - 1].raio + gears[i].raio) * Math.sin(angle * Math.PI / 180)
						);
						posX = 800;
					}else {
						gears[i].posFinal = new Point(
							gears[i - 1].posFinal.x - (gears[i - 1].raio + gears[i].raio) * Math.cos(angle * Math.PI / 180), 
							gears[i - 1].posFinal.y + (gears[i - 1].raio + gears[i].raio) * Math.sin(angle * Math.PI / 180)
						);
						posX = -100;
					}
					posY = (angle < 0 ? 0 : 500);
				}
				
				gears[i].posInicial = new Point(posX, posY);
				gears[i].moveToInicial();
				
				if ( i == nGears - 1) Actuate.tween(gears[i], 0.5, { x: gears[i].posFinal.x, y: gears[i].posFinal.y } ).ease(Cubic.easeOut).delay(delay).onComplete(startAnimation);
				else Actuate.tween(gears[i], 0.5, { x: gears[i].posFinal.x, y: gears[i].posFinal.y } ).ease(Cubic.easeOut).delay(delay);
				delay += 0.1;
			}
		}
		
		private function setInicialAngle(gearAnt:Gear, angle:Number, gearToRotate:Gear):void 
		{
			
		}
		
		private function animatedExit():void
		{
			stopAnimation();
			
			var delay:Number = 0;
			for (var i:int = nGears - 1; i >= 0; i--)
			{
				if (i == 0) Actuate.tween(gears[i], 0.5, { x: gears[i].posInicial.x, y: gears[i].posInicial.y } ).ease(Cubic.easeOut).onComplete(preparaBolinhas).delay(delay);
				else Actuate.tween(gears[i], 0.5, { x: gears[i].posInicial.x, y: gears[i].posInicial.y } ).ease(Cubic.easeOut).delay(delay);
				
				delay += 0.1;
			}
		}
		
		private function startAnimation():void
		{
			cronometerGear.start();
			stage.addEventListener(Event.ENTER_FRAME, updateGears);
		}
		
		private function updateGears(e:Event):void 
		{
			var time:Number = cronometerGear.read() / 1000;
			for each (var item:Gear in gears)
			{
				item.update(time);
			}
		}
		
		private function stopAnimation():void
		{
			stage.removeEventListener(Event.ENTER_FRAME, updateGears);
			cronometerGear.stop();
			cronometerGear.reset();
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
		}
		
		private function resetaCronometro(e:MouseEvent):void 
		{
			
			removeEventListener(Event.ENTER_FRAME, refreshCron);
			
			cronometer.stop();
			cronometer.reset();
			
			cronometro.time.text = "0";
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
					setInfoMsg("Licença e créditos.");
					break;
				case "Gear":
					setInfoMsg("Engrenagem de raio " + Gear(e.target).raio.toFixed(2) + " unidades de comprimento.");
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
			animatedExit();
		}
		
		override public function iniciaTutorial(e:MouseEvent = null):void
		{
			
		}
		
		
		/*------------------------------------------------------------------------------------------------*/
		//SCORM:
		
		private const PING_INTERVAL:Number = 5 * 60 * 1000; // 5 minutos
		private var completed:Boolean;
		private var scorm:SCORM;
		private var scormExercise:int;
		private var connected:Boolean;
		private var score:int = 0;
		private var pingTimer:Timer;
		private var mementoSerialized:String = "";
		
		/**
		 * @private
		 * Inicia a conexão com o LMS.
		 */
		private function initLMSConnection () : void
		{
			completed = false;
			connected = false;
			scorm = new SCORM();
			
			pingTimer = new Timer(PING_INTERVAL);
			pingTimer.addEventListener(TimerEvent.TIMER, pingLMS);
			
			connected = scorm.connect();
			
			if (connected) {
				scorm.set("cmi.exit", "suspend");
				// Verifica se a AI já foi concluída.
				var status:String = scorm.get("cmi.completion_status");	
				mementoSerialized = scorm.get("cmi.suspend_data");
				var stringScore:String = scorm.get("cmi.score.raw");
				
				switch(status)
				{
					// Primeiro acesso à AI
					case "not attempted":
					case "unknown":
					default:
						completed = false;
						break;
					
					// Continuando a AI...
					case "incomplete":
						completed = false;
						break;
					
					// A AI já foi completada.
					case "completed":
						completed = true;
						//setMessage("ATENÇÃO: esta Atividade Interativa já foi completada. Você pode refazê-la quantas vezes quiser, mas não valerá nota.");
						break;
				}
				
				//unmarshalObjects(mementoSerialized);
				scormExercise = 1;
				score = Number(stringScore.replace(",", "."));
				
				var success:Boolean = scorm.set("cmi.score.min", "0");
				if (success) success = scorm.set("cmi.score.max", "100");
				
				if (success)
				{
					scorm.save();
					pingTimer.start();
				}
				else
				{
					//trace("Falha ao enviar dados para o LMS.");
					connected = false;
				}
			}
			else
			{
				trace("Esta Atividade Interativa não está conectada a um LMS: seu aproveitamento nela NÃO será salvo.");
				mementoSerialized = ExternalInterface.call("getLocalStorageString");
			}
			
			//reset();
		}
		
		/**
		 * @private
		 * Salva cmi.score.raw, cmi.location e cmi.completion_status no LMS
		 */ 
		private function commit()
		{
			if (connected)
			{
				// Salva no LMS a nota do aluno.
				var success:Boolean = scorm.set("cmi.score.raw", score.toString());

				// Notifica o LMS que esta atividade foi concluída.
				success = scorm.set("cmi.completion_status", (completed ? "completed" : "incomplete"));

				// Salva no LMS o exercício que deve ser exibido quando a AI for acessada novamente.
				success = scorm.set("cmi.location", scormExercise.toString());
				
				// Salva no LMS a string que representa a situação atual da AI para ser recuperada posteriormente.
				//mementoSerialized = marshalObjects();
				success = scorm.set("cmi.suspend_data", mementoSerialized.toString());

				if (success)
				{
					scorm.save();
				}
				else
				{
					pingTimer.stop();
					//setMessage("Falha na conexão com o LMS.");
					connected = false;
				}
			}else { //LocalStorage
				ExternalInterface.call("save2LS", mementoSerialized);
			}
		}
		
		/**
		 * @private
		 * Mantém a conexão com LMS ativa, atualizando a variável cmi.session_time
		 */
		private function pingLMS (event:TimerEvent)
		{
			//scorm.get("cmi.completion_status");
			commit();
		}
		
		private function saveStatus(e:Event = null):void
		{
			if (ExternalInterface.available) {
				//saveStatusForRecovery();
				if (connected) {
					scorm.set("cmi.suspend_data", mementoSerialized);
					commit();
				}else {//LocalStorage
					ExternalInterface.call("save2LS", mementoSerialized);
				}
			}
		}
	}

}