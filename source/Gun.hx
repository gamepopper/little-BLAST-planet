package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.system.FlxSound;

/**
 * ...
 * @author Gamepopper
 */
class Gun extends FlxTypedGroup<FlxSprite>
{
	private var delay:Float = 0.0;
	private var worldRad:Int = 0;
	public var fireRate:Float = 0.2;
	
	private var bulletSound:FlxSound;
	
	public function new(worldRadius:Int, MaxSize:Int = 0)
	{
		super(MaxSize);
		worldRad = worldRadius;
		
		bulletSound = new FlxSound();
		bulletSound.loadEmbedded("shoot");
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);		
		forEachAlive(processActive);
		
		delay += elapsed;
	}
	
	public function fire(position:FlxPoint, direction:FlxPoint, radius:Float)
	{
		if (delay > fireRate)
		{
			delay = 0;
			
			var bullet = recycle(FlxSprite);
			
			if (bullet != null)
			{
				var vector:FlxVector = new FlxVector();
				vector.set(direction.x, direction.y);
				bullet.velocity.set(500 * direction.x, 500 * direction.y);
				bullet.angle = vector.angleBetween(new FlxPoint(1, 0));
				bullet.setPosition(
				position.x + (radius) + (radius * direction.x) - (bullet.width / 2), 
				position.y + (radius) + (radius * direction.y) - bullet.height / 2);
				
				bulletSound.play();
			}
		}
	}
	
	function processActive(sprite:FlxSprite)
	{
		if (sprite.x > FlxG.width ||
			sprite.y > FlxG.height ||
			sprite.x < -sprite.width ||
			sprite.y < -sprite.height)
			{
				sprite.kill();
				return;
			}
			
		var centreX = FlxG.width / 2.0;
		var centreY = FlxG.height / 2.0;
			
		var diff:FlxVector = new FlxVector();
		diff.set(sprite.x, sprite.y);
		diff.add(sprite.width/2, sprite.height/2);
		diff.subtract(centreX, centreY);
		
		var distance = diff.length;
		
		if (distance < worldRad + sprite.width / 2 ||
			distance < worldRad + sprite.height / 2)
		{
			sprite.kill();
			return;
		}
	}
}