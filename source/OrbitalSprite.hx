package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;

/**
 * ...
 * @author Gamepopper
 */
class OrbitalSprite extends FlxSprite 
{
	private var worldRad = 0;
	private var objRad = 0;
	
	private var centreX = FlxG.width / 2.0;
	private var centreY = FlxG.height / 2.0;
	
	public var orbitPos = 0.0;
	public var orbitAcceleration = 981.0;
	public var enableAcceleration = true;
	
	public function new(objRadius:Int, worldRadius:Int, distanceOffset = 1.5) 
	{
		objRad = objRadius;
		worldRad = worldRadius;
		super(centreX - objRadius, centreY - (worldRadius * distanceOffset));
	}	
	
	override public function update(elapsed:Float):Void 
	{		
		super.update(elapsed);
		
		if (orbitPos < 0)
		{
			orbitPos += 360;
		}
		else if (orbitPos > 360)
		{
			orbitPos -= 360;
		}
		
		if (alive)
		{
			setOrbitPos();
		
			if (enableAcceleration)
			{
				var acc:FlxVector = new FlxVector();
				acc.set(0, 900);
				acc.rotateByDegrees(orbitPos);		
				acceleration.set(acc.x, acc.y);
			}
		
			angle = orbitPos;
		}
	}
	
	public function jump(vel:Float)
	{
		if (velocity.x == 0 && velocity.y == 0)
		{
			var vector:FlxVector = new FlxVector();
			vector.set(0, -vel);
			vector.rotateByDegrees(orbitPos);
			velocity.set(vector.x, vector.y);
			FlxG.sound.play("jump");
		}
	}
	
	public function getDirection(offset:Float = 0) : FlxPoint
	{
		var vector:FlxVector = new FlxVector();
		vector.set(1, 0);
		vector.rotateByDegrees(orbitPos - 90 + offset);
		
		return new FlxPoint(vector.x, vector.y);
	}
	
	function setOrbitPos()
	{
		//Get Current Distance
		var diff:FlxVector = new FlxVector();
		diff.set(x, y);
		diff.add(objRad, objRad);
		diff.subtract(centreX, centreY);
		
		var distance = diff.length;
		
		if (distance < worldRad + objRad)
		{
			distance = worldRad + objRad;
			velocity.set();
		}
		
		var pos:FlxVector = new FlxVector();
		pos.set(0, -distance);
		pos.rotateByDegrees(orbitPos);
		pos.add(centreX, centreY);
		pos.subtract(objRad, objRad);
		
		x = pos.x;
		y = pos.y;
	}
}