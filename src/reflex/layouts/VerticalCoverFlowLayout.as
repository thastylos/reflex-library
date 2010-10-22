package reflex.layouts
{
	import com.theflashblog.util3d.SimpleZSorter;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.IEventDispatcher;
	import flash.geom.Matrix3D;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	import reflex.binding.Bind;
	import reflex.data.IPosition;
	import reflex.invalidation.Invalidation;
	import reflex.layouts.ILayout;
	import reflex.layouts.Layout;
	import reflex.measurement.resolveWidth;
	
	[LayoutProperty(name="width", measure="true")]
	[LayoutProperty(name="height", measure="true")]
	
	
	/**
	 * @alpha
	 **/
	public class VerticalCoverFlowLayout extends Layout implements ILayout
	{
		
		[Bindable]
		[Binding(target="target.position")]
		public var vertical:IPosition;
		/*
		[Bindable]
		[Binding(target="target.skin.container")]
		public var container:Object;
		*/
		[Bindable] public var gap:Number = 5;
		
		public function VerticalCoverFlowLayout():void {
			super();
		}
		
		override public function measure(children:Array):Point
		{
			super.measure(children);
			var point:Point = new Point(gap, 0);
			for each(var child:Object in children) {
				var width:Number = reflex.measurement.resolveWidth(child);
				var height:Number = reflex.measurement.resolveHeight(child);
				point.x = Math.max(point.x, width);
				point.y += height + gap;
			}
			//point.y += height;
			return point;
		}
		
		override public function update(children:Array, rectangle:Rectangle):void
		{
			super.update(children, rectangle);
			if(children && vertical) {
				var percent:Number = (vertical.value-vertical.minimum)/(vertical.maximum-vertical.minimum);
				
				var center:Number = ((target as Object).height - 800) * percent + 400;
				
				var perspective:PerspectiveProjection = new PerspectiveProjection();
				perspective.projectionCenter = new Point(rectangle.width/2, center);
				(target as DisplayObject).transform.perspectiveProjection = perspective;
				
				/*
				var graphics:Graphics = (target as Sprite).graphics;
				graphics.clear();
				graphics.beginFill(0x006699, 1);
				graphics.drawCircle(-50, center, 6);
				graphics.endFill();
				*/
				var centerIndex:int = 0;
				var closest:Number = 10000;
				var position:Number = gap;
				var length:int = children.length;
				for(var i:int = 0; i < length; i++) {
					var child:DisplayObject = children[i] as DisplayObject;
					var width:Number = reflex.measurement.resolveWidth(child);
					var height:Number = reflex.measurement.resolveHeight(child);
					
					var distance:Number = (center-position-height/2);
					if(Math.abs(distance) < closest) {
						centerIndex = i;
						closest = Math.abs(distance);
					}
					var tilt:Number = 0 + distance/2;
					tilt = Math.min(tilt, 60);
					tilt = Math.max(tilt, -60);
					
					var zBoost:Number = 0;
					if(tilt < 60 && tilt > -60) {
						var boost:Number = 1 - Math.abs(tilt)/60;
						zBoost = height/2 * boost * -1;
					}
					
					var matrix:Matrix3D = child.transform.matrix3D;
					if(!matrix) { matrix = new Matrix3D(); }
					matrix.identity();
					matrix.prependTranslation(width/2, height/2, 0);
					matrix.prependTranslation(rectangle.width/2 - width/2, position, zBoost);
					matrix.prependRotation(tilt, Vector3D.X_AXIS);
					matrix.prependTranslation(width/2 * -1, height/2 * -1, 0);
					child.transform.matrix3D = matrix;
					
					// fast path?
					
					position += height/1.5 + gap;
				}
				sort(children, centerIndex);
			}
		}
		
		private function sort(children:Array, centerIndex:int = 0):void {
			//var indexes:Array = children.sortOn("z", Array.DESCENDING | Array.NUMERIC | Array.RETURNINDEXEDARRAY);
			var z:int = 0
			var i:int = 0;
			var child:DisplayObject;
			var length:int = children.length;
			for(i = 0; i < centerIndex; i++) {
				child = children[i] as DisplayObject;
				(target as DisplayObjectContainer).setChildIndex(child, z);
				z++;
			}
			for(i = length-1; i >= centerIndex; i--) {
				child = children[i] as DisplayObject;
				(target as DisplayObjectContainer).setChildIndex(child, z);
				z++;
			}
		}
		
		[EventListener(type="valueChange", target="vertical")]
		public function onPositionChange(event:Event):void {
			if(target) {
				Invalidation.invalidate(target as DisplayObject, "layout");
			}
		}
		
	}
}