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

		private var bitmapData:BitmapData;
		private var bitmap:Bitmap;

		private var pointerData:BitmapData;
		private var pointer:Bitmap;
//		private var numCols:int = 40;
//		private var numRows:int = 20;
//		private var pointerArray:Array = [];

		private var canMove:Boolean = false;

		public function FlowField()
		{
			bitmapData = new BitmapData(500, 250, false);
			bitmap = new Bitmap(bitmapData);
			addChild(bitmap);

			randomSeed = randomNumFromRange(1, 123456);

			//Populate offsets and speeds array
			for(var i:int = 0; i < numOctaves; i++)
			{
				offsets[i] = new Point(0, 0);
				speeds[i] = new Point(randomNumFromRange(-2, 2), randomNumFromRange(-0.5, 0.5))
			}

//			for(var i:int = 0; i <= numCols; i++)
//			{
//				for(var j:int = 0; j <= numRows; j++)
//				{
//					pointerData = new BitmapData(6, 1, false, 0xFF2200);
//					pointer = new Bitmap(pointerData);
//					pointer.x = (bitmap.width / numCols) * i;
//					pointer.y = (bitmap.height / numRows) * j;
//
//					pointerArray.push(pointer)
//					addChild(pointer);
//				}
//			}

			pointerData = new BitmapData(6, 1, false, 0xFF2200);
			pointer = new Bitmap(pointerData);
			pointer.x = (bitmap.width - pointer.width) / 2;
			pointer.y = (bitmap.height - pointer.height) / 2;

			addChild(pointer);

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

			var currentDarkestX:int = -1;
			var currentDarkestY:int = -1;
			var currentBrightness:Number = -1;

			for(var i:int = pointer.x - 1; i <= pointer.x + 1; i++)
			{
				for(var j:int = pointer.y - 1; j <= pointer.y + 1; j++)
				{
					var pixel:uint = bitmapData.getPixel(i, j);
					var brightness:Number = pixel / 0xFFFFFF;

					if(currentBrightness == -1)
					{
						currentDarkestX = i;
						currentDarkestY = j;
						currentBrightness = brightness;
					}

					if(currentBrightness < brightness)
					{
						currentDarkestX = i;
						currentDarkestY = j;
						currentBrightness = brightness;
					}
				}
			}

			var dx:Number = pointer.x - currentDarkestX;
			var dy:Number = pointer.y - currentDarkestY;

			var angle = -Math.atan2(dy, dx) / Math.PI * 180;
			pointer.x += Math.cos(angle) * (currentBrightness * 5);
			pointer.y += Math.sin(angle) * (currentBrightness * 5);
			pointer.rotation = angle;

//			for each(var agent in pointerArray)
//			{
//
//				var pixel:uint = bitmapData.getPixel(agent.x,  agent.y);
//				var brightness:Number = pixel / 0xFFFFFF;
//
//				if(canMove)
//				{
//					var speed:Number = brightness * 5;
//					var angle:Number = brightness * 360 * Math.PI / 180;
//
//					agent.x += Math.cos(angle) * speed;
//					agent.y += Math.sin(angle) * speed;
//				}
//
//				agent.rotation = brightness * 360;
//			}

			bitmapData.perlinNoise(baseX, baseY, numOctaves, randomSeed, stitch, fractalNoise, channelOptions, greyScale, offsets);
		}

		private function randomNumFromRange(min:Number,  max:Number) : Number
		{
			return Math.random() * (max - min) + min;
		}
	}
}
