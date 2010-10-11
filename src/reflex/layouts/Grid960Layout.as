package reflex.layouts
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import reflex.layouts.ILayout;
	import reflex.layouts.Layout;
	import reflex.measurement.setSize;
	import reflex.styles.resolveStyle;
	
	[LayoutProperty(name="style.grid", measure="true")]
	[LayoutProperty(name="style.prefix", measure="true")]
	[LayoutProperty(name="style.suffix", measure="true")]
	public class Grid960Layout extends Layout implements ILayout
	{
		
		public var columnWidth:Number = 60;
		public var gutterWidth:Number = 20;
		public var columnCount:Number = 12;
		public var fluid:Boolean = false;
		
		public function Grid960Layout()
		{
			super();
		}
		
		override public function measure(children:Array):Point {
			super.measure(children);
			return new Point(960, 1200);
		}
		
		override public function update(children:Array, rectangle:Rectangle):void {
			super.update(children, rectangle);
			
			if(fluid) {
				columnWidth = Math.max((rectangle.width-20*12) / 12, 60);
				//gutterWidth = Math.max(columnWidth/3, 20);
			}
			
			var size:Number = columnWidth*columnCount + gutterWidth*(columnCount-1);
			var margin:Number = (rectangle.width - size)/2;
			
			var column:int = 0;
			var vertical:Number = gutterWidth;
			var maxHeight:Number = columnWidth;
			var length:int = children.length;
			for(var i:int = 0; i < length; i++) {
				var child:Object = children[i];
				var width:Number = reflex.measurement.resolveWidth(child);
				var height:Number = reflex.measurement.resolveHeight(child);
				var grid:int = int(reflex.styles.resolveStyle(child, "grid", null, 0));
				var prefix:int = int(reflex.styles.resolveStyle(child, "prefix", null, 0));
				var suffix:int = int(reflex.styles.resolveStyle(child, "suffix", null, 0));
				
				column += prefix;
				
				while(column >= 12) {
					column -= 12;
					vertical += maxHeight + gutterWidth;
					maxHeight = columnWidth + gutterWidth;
				}
				
				child.x = margin + column*columnWidth + column*gutterWidth;
				child.y = vertical;
				if(grid > 0) {
					width = (grid*columnWidth) + (grid-1)*gutterWidth;
				}
				
				reflex.measurement.setSize(child, width, height);
				
				column +=  grid + suffix;
				while(column >= 12) {
					column -= 12;
					vertical += maxHeight + gutterWidth;
					maxHeight = columnWidth + gutterWidth;
				}
				
				if(!isNaN(height)) {
					//maxHeight = Math.max(vertical, height);
				}
			}
		}
		
	}
}