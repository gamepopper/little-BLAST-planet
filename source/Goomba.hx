package;

import flixel.FlxG;

/**
 * ...
 * @author Gamepopper
 */
class Goomba extends OrbitalSprite 
{
	var left:Bool = false;
	var vel = 30.0;
	
	public var bounce = false;
	
	public function new(objRadius:Int, worldRadius:Int) 
	{
		super(objRadius, worldRadius, 4);
		left = FlxG.random.bool();
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		if (left)
		{
			orbitPos -= vel * elapsed;
		}
		else
		{
			orbitPos += vel * elapsed;
		}
		
		if (bounce)
		{
			if (velocity.x == 0 && velocity.y == 0)
			{
				jump(600);
			}
		}
	}
}