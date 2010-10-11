package reflex.text
{
	import flash.geom.Rectangle;
	import flash.text.engine.CFFHinting;
	import flash.text.engine.RenderingMode;
	
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.Configuration;
	import flashx.textLayout.elements.IConfiguration;
	import flashx.textLayout.elements.TextFlow;
	
	import reflex.binding.DataChange;
	import reflex.display.Display;
	import reflex.metadata.resolveCommitProperties;
	
	[Style(name="left")]
	[Style(name="right")]
	[Style(name="top")]
	[Style(name="bottom")]
	[Style(name="horizontalCenter")]
	[Style(name="verticalCenter")]
	[Style(name="dock")]
	[Style(name="align")]
	
	public class TextLayoutDisplay extends Display
	{
		
		private var _text:Object;
		private var _format:String;
		
		private var flow:TextFlow;
		private var configuration:IConfiguration;
		private var controller:ContainerController;
		
		[Bindable(event="textChange")]
		public function get text():Object { return _text; }
		public function set text(value:Object):void {
			if(_text == value) {
				return;
			}
			if(value is TextFlow) {
				flow = value as TextFlow;
				//flow.flowComposer.removeAllControllers();
				flow.flowComposer.addController(controller);
			} else if(value is ContainerController) {
				controller = value as ContainerController;
			} else {
				flow = TextConverter.importToFlow(value, _format, new Configuration(true));
				flow.flowComposer.addController(controller);
			}
			DataChange.change(this, "text", _text, _text = value);
			flow.flowComposer.updateAllControllers();
			measure();
		}
		
		[Bindable(event="formatChange")]
		public function get format():String { return _format; }
		public function set format(value:String):void {
			DataChange.change(this, "format", _format, _format = value);
		}
		
		public function TextLayoutDisplay()
		{
			super();
			_text = "";
			_format = TextConverter.PLAIN_TEXT_FORMAT;
			configuration = new Configuration(true);
			controller = new ContainerController(this, 100, 100);
			flow = new TextFlow(configuration);
			flow.flowComposer.addController(controller);
			flow.cffHinting = CFFHinting.HORIZONTAL_STEM;
		}
		
		private function measure():void {
			var rectangle:Rectangle = controller.getContentBounds();
			measured.width = rectangle.width;
			measured.height = rectangle.height;
		}
		/*
		private function updateSize():void {
			controller.setCompositionSize(unscaledWidth, unscaledHeight);
		}
		*/
		override public function setSize(width:Number, height:Number):void {
			super.setSize(width, height);
			controller.setCompositionSize(unscaledWidth, unscaledHeight);
			flow.flowComposer.updateAllControllers();
		}
		
	}
}