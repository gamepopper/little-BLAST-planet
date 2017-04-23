package;
import flixel.util.FlxColor;

/**
 * ...
 * @author Gamepopper
 */
class Escape extends OrbitalSprite 
{
	var colorIndex = 0;
	var delay = 0.0;
	
	public function new(objRadius:Int, worldRadius:Int) 
	{
		super(objRadius, worldRadius, 2);
		enableAcceleration = false;
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		orbitPos = 180;
		
		delay += elapsed;
		
		if (delay > 0.25)
		{
			delay = 0;
			
			var colors = 
			[
				FlxColor.fromHSB(0, 1, 1),
				FlxColor.fromHSB(60, 1, 1),
				FlxColor.fromHSB(120, 1, 1),
				FlxColor.fromHSB(180, 1, 1),
				FlxColor.fromHSB(240, 1, 1),
			];
			
			colorIndex = (colorIndex + colors.length + 1) % colors.length;
			color = colors[colorIndex];
		}		
	}
}