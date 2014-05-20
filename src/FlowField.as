package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	public class FlowField extends Sprite
	{
		private var baseX:Number = 100;
		private var baseY:Number = 100;
		private var numOctaves:Number = 4;
		private var randomSeed:Number;
		private var stitch:Boolean = true;
		private var fractalNoise:Boolean = true;
		private var channelOptions:Number = 7;
		private var greyScale:Boolean = true;
		private var offsets:Array = [];
		private var speeds:Array = [];
		private var externalForce:Point;

		private var bitmapData:BitmapData;
		private var bitmap:Bitmap;

		private var pointerData:BitmapData;
		private var pointer:Bitmap;
		private var numCols:int = 40;
		private var numRows:int = 20;
		private var pointerArray:Array = [];

		private var canMove:Boolean = false;

		public function FlowField()
		{
			bitmapData = new BitmapData(500, 250, false);
			bitmap = new Bitmap(bitmapData);
			addChild(bitmap);

			randomSeed = randomNumFromRange(1, 999999);

			//Populate offsets and speeds array
			for(var i:int = 0; i < numOctaves; i++)
			{
				offsets[i] = new Point(0, 0);
				speeds[i] = new Point(randomNumFromRange(-2, 2), randomNumFromRange(-0.5, 0.5))
			}

			for(var i:int = 0; i <= numCols; i++)
			{
				for(var j:int = 0; j <= numRows; j++)
				{
					pointerData = new BitmapData(6, 1, false, 0xFF2200);
					pointer = new Bitmap(pointerData);
					pointer.x = (bitmap.width / numCols) * i;
					pointer.y = (bitmap.height / numRows) * j;

					pointerArray.push(pointer)
					addChild(pointer);
				}
			}

			externalForce = new Point(-1, 0);

			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.CLICK, onMouseClick)
		}

		private function onMouseClick(e:MouseEvent) : void
		{
			canMove = !canMove;
		}

		private function onEnterFrame(e:Event) : void
		{
			for(var i:int = 0; i < numOctaves; i++)
			{
				offsets[i].x += speeds[i].x;
				offsets[i].y += speeds[i].y;
			}

			for each(var agent in pointerArray)
			{
				var pixel:uint = bitmapData.getPixel(agent.x,  agent.y);
				var brightness:Number = pixel / 0xFFFFFF;

				if(canMove)
				{
					var speed:Number = brightness * 5;
					var angle:Number = brightness * 360 * Math.PI / 180;

					agent.x += (Math.cos(angle) * speed) + externalForce.x;
					agent.y += (Math.sin(angle) * speed) + externalForce.y;
				}

				agent.rotation = brightness * 360;
			}

			bitmapData.perlinNoise(baseX, baseY, numOctaves, randomSeed, stitch, fractalNoise, channelOptions, greyScale, offsets);
		}

		private function randomNumFromRange(min:Number,  max:Number) : Number
		{
			return Math.random() * (max - min) + min;
		}
	}
}
