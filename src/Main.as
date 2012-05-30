package  
{
	import BaseAssets.BaseMain;
	import cepa.utils.Angle;
	import cepa.utils.Cronometer;
	import com.adobe.serialization.json.JSON;
	import com.eclecticdesignstudio.motion.Actuate;
	import com.eclecticdesignstudio.motion.easing.Cubic;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.ui.Keyboard;
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
		private var tutoLayer:Sprite;
		
		private var cronometer:Cronometer;
		private var cronometerGear:Cronometer;
		private var timerPaused:Boolean;
		
		private var nDentesBig:Array;
		private var nDentesSmall:Array;
		
		private var omegas:Array;
		
		private var gears:Vector.<Gear>;
		private var nGears:int;
		private var maxGears:int = 6;
		private var minGears:int = 2;
		
		private var menorRaio:Number = 84.5 * 1.3;
		private var minDentes:int = 35;
		
		private var stats:Object = new Object();
		private var goalScore:Number = 50;
		
		private var answerTuto:CaixaTexto;
		
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
			createStats();
			
			if (ExternalInterface.available) {
				initLMSConnection();
				
				if (mementoSerialized != null) {
					if(mementoSerialized != "" && mementoSerialized != "null") recoverStatus();
				}
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
			
			tutoLayer = new Sprite();
			gearsLayer = new Sprite();
			addChild(tutoLayer);
			addChild(gearsLayer);
			
			setChildIndex(tutoLayer, 0);
			setChildIndex(gearsLayer, 0);
			setChildIndex(fundo, 0);
			
			cronometro.time.mouseEnabled = false;
			infoBar.mouseEnabled = false;
			
			TextField(resposta).restrict = "-0123456789,.";
			
			answerTuto = new CaixaTexto(true, false);
			addChild(answerTuto);
			
			reiniciar.visible = false;
		}
		
		private function initGearsDentes():void
		{
			//nDentesSmall = [8, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24];
			//nDentesBig = [12, 25, 26, 27, 28, 29, 30, 32, 33, 34, 35, 36];
			nDentesSmall = [10, 15, 20];
			nDentesBig = [25, 30, 35];
		}
		
		private function createStats():void 
		{
			stats.nTotal = 0;
			stats.nValendo = 0;
			stats.nNaoValendo = 0;
			stats.scoreMin = goalScore;
			stats.scoreTotal = 0;
			stats.scoreValendo = 0;
			stats.valendo = false;
		}
		
		override protected function openStats(e:MouseEvent):void 
		{
			statsScreen.updateStatics(stats);
			super.openStats(e);
		}
		
		private var left:Boolean;
		private var sortedGear:Gear;
		private function preparaBolinhas():void
		{
			if (gears.length > 0) {
				for (var i:int = gears.length - 1; i >= 0 ; i--) 
				{
					gearsLayer.removeChild(gears[i]);
				}
				
				gears.splice(0, gears.length);
			}
			
			//initGearsDentes();
			
			nGears = Math.round(Math.random() * (maxGears - minGears)) + minGears;
			var nSort:int;
			var sortedGearN:int = Math.floor(Math.random() * (nGears - 1)) + 1;
			var angle:Angle = new Angle();
			left = (Math.random() > 0.5 ? true : false);
			
			for (i = 0; i < nGears; i++)
			{
				
				if (i == 0) {//Sorteia raio grande
					nSort = Math.floor(Math.random() * nDentesBig.length);
					var bGear:Gear = new Gear(nDentesBig[nSort], getRaio(nDentesBig[nSort]), new (getDefinitionByName("Gear" + String(nDentesBig[nSort]))));
					bGear.omega = Number((Math.random() * 2 + 1).toFixed(2)) * (Math.random() > 0.5 ? 1 : -1);
					//bGear.omega = omegas[Math.floor(Math.random() * omegas.length)];
					//bGear.omega = 0.1;
					bGear.rotacaoInicial = 0;
					gears.push(bGear);
					bGear.setIndicador();
				}else {//sorteia raios(s) pequeno(s)
					nSort = Math.floor(Math.random() * nDentesSmall.length);
					var sGear:Gear = new Gear(nDentesSmall[nSort], getRaio(nDentesSmall[nSort]), new (getDefinitionByName("Gear" + String(nDentesSmall[nSort]))));
					sGear.omega = gears[i - 1].omega * (gears[i - 1].raio / sGear.raio) * -1;
					gears.push(sGear);
					//nDentesSmall.splice(nSort, 1);
					
					if (i == sortedGearN) {
						sortedGear = sGear;
						setInfoOut(null);
						sGear.filters = [RED_FILTER];
						trace(sortedGear.omega * -1);
					}
				}
				
				gears[i].scaleX = gears[i].scaleY = 1.3;
				gears[i].rotation = 90;
				angle.degrees = Math.round(Math.random() * 30) * (i % 2 == 0 ? 1 : -1);
				if (!left) angle.degrees += 180;
				gears[i].angle.degrees = angle.degrees;
				
				if(i > 0) gears[i].rotacaoInicial = 180 + 360 / gears[i].nDentes / 2 - gears[i-1].rotacaoInicial * gears[i-1].nDentes / gears[i].nDentes + gears[i].angle.degrees * (gears[i-1].nDentes + gears[i].nDentes) / gears[i].nDentes;
				
				gearsLayer.addChild(gears[gears.length - 1]);
				
			}
			animatedEntrance();
		}
		
		private function getRaio(nDentes:int):Number 
		{
			return (menorRaio * nDentes) / minDentes;
		}
		
		private function animatedEntrance():void
		{
			var posX:Number;
			var posY:Number;
			
			var delay:Number = 0;
			
			for (var i:int = 0; i < nGears; i++)
			{
				if (i == 0) {
					if (left) {
						//gears[i].posFinal = new Point((Math.random() * 100) + 200, (Math.random() * 100) + 200);
						gears[i].posFinal = new Point(20 + gears[i].raio, 270);
						posX = -200;
					}
					else {
						//gears[i].posFinal = new Point(500 - (Math.random() * 100), (Math.random() * 100) + 200);
						gears[i].posFinal = new Point(650 - gears[i].raio, 270);
						posX = 900;
					}
					posY = (Math.random() > 0.5 ? 0 : 500);
				}else {
					
					if(left){
						gears[i].posFinal = new Point(
							gears[i - 1].posFinal.x + (gears[i - 1].raio + gears[i].raio) * Math.cos(gears[i].angle.radians), 
							gears[i - 1].posFinal.y + (gears[i - 1].raio + gears[i].raio) * Math.sin(gears[i].angle.radians)
						);
						posX = 800;
					}else {
						gears[i].posFinal = new Point(
							gears[i - 1].posFinal.x + (gears[i - 1].raio + gears[i].raio) * Math.cos(gears[i].angle.radians), 
							gears[i - 1].posFinal.y + (gears[i - 1].raio + gears[i].raio) * Math.sin(gears[i].angle.radians)
						);
						posX = -100;
					}
					posY = (gears[i - 1].angle.degrees < 0 ? 0 : 500);
				}
				
				gears[i].posInicial = new Point(posX, posY);
				gears[i].moveToInicial();
				
				if ( i == nGears - 1) Actuate.tween(gears[i], 0.5, { x: gears[i].posFinal.x, y: gears[i].posFinal.y } ).ease(Cubic.easeOut).delay(delay).onComplete(startAnimation);
				else Actuate.tween(gears[i], 0.5, { x: gears[i].posFinal.x, y: gears[i].posFinal.y } ).ease(Cubic.easeOut).delay(delay);
				delay += 0.1;
			}
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
			if (!completed && !tutorialExibido) {
				tutorialExibido = true;
				iniciaTutorial();
			}
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
			
			cronometro.start.addEventListener(MouseEvent.MOUSE_DOWN, startCronometro);
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
			
			//trace(classe);
			
			switch(classe) {
				case "BtReiniciar":
					setInfoMsg("Novo exercício.");
					break;
				case "BtOK":
					setInfoMsg("Responder exercício.");
					break;
				case "BtValendoNota":
					setInfoMsg("Faz o exercício valer nota.");
					break;
				case "Cronometro":
					setInfoMsg("Cronômetro.");
					break;
				case "Start":
					if(cronometer.isRunning()) setInfoMsg("Pausa o cronômetro.");
					else setInfoMsg("Inicia o cronômetro.");
					break;
				case "Reset":
					setInfoMsg("Zera o cronômetro.");
					break;
				case "Btn_info":
					setInfoMsg("Inicia tutorial.");
					break;
				case "Btn_Instructions":
					setInfoMsg("Abrir tela de orientações.");
					break;
				case "Btn_Reset":
					setInfoMsg("Novo exercício.");
					break;
				case "Btn_CC":
					setInfoMsg("Licença e créditos.");
					break;
				case "BtEstatisticas":
					setInfoMsg("Abrir tela de desempenho.");
					break;
				case "Gear":
					setInfoMsg("Roda de raio " + Gear(e.target).raio.toFixed(2) + " unidades de comprimento (" + Gear(e.target).nDentes + " dentes).");
					break;
				case "TutorialArrow":
					setInfoMsg("Velocidade linear.");
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
			setInfoMsg("Qual é a velocidade angular na roda azul?");
		}
		
		private function setInfoMsg(msg:String):void
		{
			infoBar.texto.text = msg;
		}
		
		private function addListeners():void
		{
			stage.addEventListener(MouseEvent.MOUSE_OVER, setInfo);
			stage.addEventListener(MouseEvent.MOUSE_OUT, setInfoOut);
			btAnswer.addEventListener(MouseEvent.CLICK, answerExercise);
			feedbackScreen.addEventListener(Event.CLOSE, fazValer);
			btValendoNota.addEventListener(MouseEvent.CLICK, openValendoNotaScreen);
			reiniciar.addEventListener(MouseEvent.CLICK, reset);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownListener);
		}
		
		private function keyDownListener(e:KeyboardEvent):void 
		{
			if (e.keyCode == Keyboard.SPACE) {
				startCronometro(null);
			}
		}
		
		private function answerExercise(e:MouseEvent):void 
		{
			feedbackScreen.okCancelMode = false;
			if (resposta.text == "") feedbackScreen.setText("Você precisa digitar algo para ser avaliado.");
			else if(isNaN(Number(resposta.text.replace(",", ".")))) feedbackScreen.setText("Você precisa digitar um número válido para ser avaliado.");
			else {
				var resp:Number = Number(resposta.text.replace(",", "."));
				var currentScore:Number = getScore(resp);
				
				stats.nTotal += 1;
				
				if (stats.valendo) {
					stats.nValendo += 1;
					stats.scoreValendo = ((stats.scoreValendo * (stats.nValendo - 1) + currentScore) / stats.nValendo).toFixed(0);
				}else {
					stats.nNaoValendo += 1;
				}
				
				stats.scoreTotal = ((stats.scoreTotal * (stats.nTotal - 1) + currentScore) / stats.nTotal).toFixed(0);
				
				if (currentScore >= 90) {
					initSolveTutorial(false);
					feedbackScreen.setText("Parabéns, você acertou. Sua pontuação foi de " + currentScore.toFixed(0).replace(".", "") + "%.");
				}else if (currentScore >= 60) {
					initSolveTutorial(false);
					feedbackScreen.setText("Chegou perto. Deve ter medido o tempo um pouco errado. Sua pontuação foi de " + currentScore.toFixed(0).replace(".", "") + "%.");
				}else if(currentScore > 0) {
					initSolveTutorial(true);
					feedbackScreen.setText("Você deve ter errado na medida do tempo. Procure medir o tempo de uma volta mais de uma vez para ter certeza. Sua pontuação foi de " + currentScore.toFixed(0).replace(".", "") + "%.");
				}else {
					initSolveTutorial(true);
					if (getScore(-resp) >= 90) {
						feedbackScreen.setText("Ops!... atenção ao sinal da velocidade angular. Sua pontuação foi de 0%.");
					}else {
						feedbackScreen.setText("Ops!... alguma coisa está errada. Sua pontuação foi de 0%.");
					}
				}
				
				//btAnswer.mouseEnabled = false;
				//btAnswer.filters = [GRAYSCALE_FILTER];
				//btAnswer.alpha = 0.5;
				
				btAnswer.visible = false;
				reiniciar.visible = true;
				
				TextField(resposta).mouseEnabled = false;
				
				saveStatus();
			}
		}
		
		private function openValendoNotaScreen(e:MouseEvent):void
		{
			feedbackScreen.okCancelMode = true;
			feedbackScreen.setText("Ao entrar no modo de avaliação e a partir do próximo lançamento, sua pontuação será contabilizada na sua nota. Além disso, não será possível retornar para o modo de investigação. Confirma a alteração para o modo de avaliação?");
			setChildIndex(feedbackScreen, numChildren - 1);
		}
		
		private function fazValer(e:Event = null):void
		{
			stats.valendo = true;
			//btValendoNota.filters = [GRAYSCALE_FILTER];
			//btValendoNota.alpha = 0.5;
			//btValendoNota.mouseEnabled = false;
			
			lock(btValendoNota);
			lock(botoes.resetButton);
			
			if (e != null) {
				reset();
				saveStatus();
			}
		}
		
		private function getScore(resp:Number):Number 
		{
			var score:Number;
			
			var omega_usuário:Number = resp;
			var omega_certo:Number = (sortedGear.omega * -1);
			var z_maior:Number = gears[0].nDentes;
			var z_azul:Number = sortedGear.nDentes;
			var omega_maior:Number = gears[0].omega * -1;
			var erro_tempo:Number =  0.05;
			var erro_maximo_em_omega:Number = z_maior / z_azul * Math.pow(omega_maior, 2) * erro_tempo / 2 * Math.PI;
			
			score = Math.max(0, 100 - 100 * Math.abs(omega_usuário - omega_certo) / erro_maximo_em_omega);
			
			return score;
		}
		
		private var tutorialArrows:Vector.<TutorialArrow> = new Vector.<TutorialArrow>();
		private var ind:Indicador;
		private function initSolveTutorial(errado:Boolean = false):void
		{
			removeSolveTutorial();
			
			ind = new Indicador();
			ind.mouseChildren = false;
			ind.buttonMode = true;
			ind.label.text = "1";
			tutoLayer.addChild(ind);
			ind.x = gears[0].x;
			ind.y = gears[0].y - gears[0].raio / 2;
			ind.addEventListener(MouseEvent.MOUSE_OVER, overTutoArrow, false, 0, true);
			ind.addEventListener(MouseEvent.MOUSE_OUT, outTutoArrow, false, 0, true);
			
			tutoLoop: for (var i:int = 1; i < gears.length; i++) 
			{
				
				if (!errado && gears[i] != sortedGear) continue tutoLoop;
				
				var tutoArrow:TutorialArrow = new TutorialArrow();
				if (errado) tutoArrow.label = String(i + 1);
				else tutoArrow.label = "2";
				
				tutoLayer.addChild(tutoArrow);
				tutorialArrows.push(tutoArrow);
				
				var angle:Angle = new Angle();
				angle.radians = Math.atan2(gears[i].y - gears[i - 1].y, gears[i].x - gears[i - 1].x);
				var posX:Number  = gears[i - 1].raio * Math.cos(angle.radians) + gears[i - 1].x;
				var posY:Number  = gears[i - 1].raio * Math.sin(angle.radians) + gears[i - 1].y;
				
				tutoArrow.x = posX;
				tutoArrow.y = posY;
				tutoArrow.rotation = (gears[i - 1].omega > 0 ? angle.degrees + 90 : angle.degrees - 90);
				tutoArrow.labelField.addEventListener(MouseEvent.MOUSE_OVER, overTutoArrow, false, 0, true);
				tutoArrow.labelField.addEventListener(MouseEvent.MOUSE_OUT, outTutoArrow, false, 0, true);
				tutoArrow.arrowText = "A velocidade LINEAR das rodas 1 e 2 neste ponto são iguais (" + Math.abs(gears[i].omega * gears[i].raio).toFixed(2).replace(".", ",") + " unidades de comprimento por segundo), de modo que ω<font size='8'>1</font> r<font size='8'>1</font> = ω<font size='8'>2</font> r<font size='8'>2</font>. Daí resulta ω<font size='8'>2</font> = " + (gears[i].omega * -1).toFixed(2).replace(".", ",") + " rad/s.";
				
				if (gears[i] == sortedGear) break tutoLoop;
			}
		}
		
		private function overTutoArrow(e:MouseEvent):void 
		{
			var pos:Point;
			if (e.target.parent is TutorialArrow) pos = Sprite(e.target).parent.localToGlobal(new Point(e.target.x, e.target.y));
			else pos = new Point(e.target.x, e.target.y);
			
			var horizontalAlign:String = CaixaTexto.CENTER;
			if (pos.x > stage.stageWidth / 2 + 200) {
				horizontalAlign = CaixaTexto.LAST;
			}else if(pos.x < stage.stageWidth / 2 - 200){
				horizontalAlign = CaixaTexto.FIRST;
			}
			
			var verticalAlign:String;
			if (pos.y > stage.stageHeight / 2) {
				verticalAlign = CaixaTexto.BOTTON;
			}else {
				verticalAlign = CaixaTexto.TOP;
			}
			
			if (e.target.parent is TutorialArrow) answerTuto.setText(TutorialArrow(e.target.parent).arrowText, verticalAlign, horizontalAlign);
			else {
				var txt:String = "Meça o tempo t gasto pela roda maior para dar uma volta e calcule a velocidade angular dela: ω = 2π / t = " + String(gears[0].omega * -1).replace(".", ",") + " rad/s.Em seguida, sabendo o raio r da roda, calcule a velocidade linear: v = ωr.";
				answerTuto.setText(txt, verticalAlign, horizontalAlign);
			}
			answerTuto.setPosition(pos.x, pos.y);
		}
		
		private function outTutoArrow(e:MouseEvent):void 
		{
			answerTuto.visible = false;
		}
		
		private function removeSolveTutorial():void
		{
			if (tutorialArrows.length > 0) {
				tutoLayer.removeChild(ind);
				ind = null;
			
				for (var i:int = 0; i < tutorialArrows.length; i++) 
				{
					tutoLayer.removeChild(tutorialArrows[i]);
				}
				
				tutorialArrows.splice(0, tutorialArrows.length);
			}
		}
		
		override public function reset(e:MouseEvent = null):void
		{
			removeSolveTutorial();
			resetaCronometro(null);
			animatedExit();
			
			btAnswer.mouseEnabled = true;
			btAnswer.filters = [];
			btAnswer.alpha = 1;
			
			btAnswer.visible = true;
			reiniciar.visible = false;
			
			TextField(resposta).mouseEnabled = true;
			TextField(resposta).text = "";
		}
		
		
		//---------------- Tutorial -----------------------
		
		private var tutorialExibido:Boolean = false;
		private var gearPos:Point = new Point();
		private var balao:CaixaTexto;
		private var pointsTuto:Array;
		private var tutoBaloonPos:Array;
		private var tutoPos:int;
		private var tutoSequence:Array = ["Qual é a velocidade angular da roda azul?", 
										  "Passe o mouse sobre uma roda para ver o raio dela.",
										  "Pressione para iniciar/parar o cronômetro (você também pode usar a barra de espaço para isso).",
										  "Pressione para zerar o cronômetro.",
										  "Digite aqui a velocidade angular da roda azul. ATENÇÃO para o sentido da rotação.",
										  "Pressione \"terminei\" para verificar sua resposta.",
										  "Pressione quando você estiver pronto(a) para ser avaliado(a).",
										  "Veja aqui o seu desempenho.",
										  "Pressione para começar um novo exercício."];
		
		
		override public function iniciaTutorial(e:MouseEvent = null):void  
		{
			tutoPos = 0;
			if(balao == null){
				balao = new CaixaTexto(true);
				addChild(balao);
				balao.visible = false;
				
				pointsTuto = 	[new Point(infoBar.x + 50, infoBar.y),
								gearPos,
								new Point(577, 74),
								new Point(638, 58),
								new Point(113, 54),
								new Point(61, 83),
								new Point(165, 83),
								new Point(655, 325),
								new Point(61, 83)];
								
				tutoBaloonPos = [[CaixaTexto.BOTTON, CaixaTexto.FIRST],
								[CaixaTexto.TOP, CaixaTexto.CENTER],
								[CaixaTexto.RIGHT, CaixaTexto.CENTER],
								[CaixaTexto.RIGHT, CaixaTexto.FIRST],
								[CaixaTexto.TOP, CaixaTexto.FIRST],
								[CaixaTexto.TOP, CaixaTexto.FIRST],
								[CaixaTexto.TOP, CaixaTexto.CENTER],
								[CaixaTexto.RIGHT, CaixaTexto.CENTER],
								[CaixaTexto.TOP, CaixaTexto.FIRST]];
			}
			updateParametersBalao();
			balao.removeEventListener(Event.CLOSE, closeBalao);
			
			balao.setText(tutoSequence[tutoPos], tutoBaloonPos[tutoPos][0], tutoBaloonPos[tutoPos][1]);
			balao.setPosition(pointsTuto[tutoPos].x, pointsTuto[tutoPos].y);
			balao.addEventListener(Event.CLOSE, closeBalao);
			balao.visible = true;
		}
		
		private function updateParametersBalao():void {
			gearPos.x = gears[1].posFinal.x;
			if (gears[1].posFinal.y > stage.stageHeight / 2) {
				gearPos.y = gears[1].posFinal.y - gears[1].raio;
				tutoBaloonPos[1][0] = CaixaTexto.BOTTON;
			}
			else {
				gearPos.y = gears[1].posFinal.y + gears[1].raio;
				tutoBaloonPos[1][0] = CaixaTexto.TOP;
			}
		}
		
		private function closeBalao(e:Event):void 
		{
			updateParametersBalao();
			tutoPos++;
			if (tutoPos >= tutoSequence.length) {
				balao.removeEventListener(Event.CLOSE, closeBalao);
				balao.visible = false;
			}else if (tutoPos == tutoSequence.length - 1 && reiniciar.visible == false) {
				balao.removeEventListener(Event.CLOSE, closeBalao);
				balao.visible = false;
				feedbackScreen.addEventListener("FEEDBACK_CLOSED", iniciaSegundoTuto);
			}else {
				balao.setText(tutoSequence[tutoPos], tutoBaloonPos[tutoPos][0], tutoBaloonPos[tutoPos][1]);
				balao.setPosition(pointsTuto[tutoPos].x, pointsTuto[tutoPos].y);
			}
		}
		
		private function iniciaSegundoTuto(e:Event):void 
		{
			if(reiniciar.visible){
				feedbackScreen.removeEventListener("FEEDBACK_CLOSED", iniciaSegundoTuto);
				balao.addEventListener(Event.CLOSE, closeBalao);
				balao.setText(tutoSequence[tutoPos], tutoBaloonPos[tutoPos][0], tutoBaloonPos[tutoPos][1]);
				balao.setPosition(pointsTuto[tutoPos].x, pointsTuto[tutoPos].y);
			}
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
				
				if (scorm.get("cmi.mode") != "normal") return;
				
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
				if (scorm.get("cmi.mode") != "normal") return;
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
				saveStatusForRecovery();
				if (connected) {
					scorm.set("cmi.suspend_data", mementoSerialized);
					commit();
				}else {//LocalStorage
					ExternalInterface.call("save2LS", mementoSerialized);
				}
			}
		}
		
		private function saveStatusForRecovery():void 
		{
			mementoSerialized = JSON.encode(stats);
		}
		
		private function recoverStatus():void
		{
			var statsRecover:Object = JSON.decode(mementoSerialized);
			
			stats.nTotal = statsRecover.nTotal;
			stats.nValendo = statsRecover.nValendo;
			stats.nNaoValendo = statsRecover.nNaoValendo;
			stats.scoreMin = goalScore;
			stats.scoreTotal = statsRecover.scoreTotal;
			stats.scoreValendo = statsRecover.scoreValendo;
			if (statsRecover.valendo) fazValer();
		}
	}

}