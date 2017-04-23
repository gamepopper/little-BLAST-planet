package;

import flixel.FlxG;

/**
 * ...
 * @author Gamepopper
 */
class Player extends OrbitalSprite 
{
	public var isJumping = false;
	public var isShooting = false;
	public var gunDirection = 0.0;
	
	public function new(objRadius:Int, worldRadius:Int) 
	{
		super(objRadius, worldRadius);
		loadGraphic("assets/images/PlayerLegs.png", true, 24, 24);
		animation.add("stand", [0]);
		animation.add("run", [1, 2, 2, 3, 2, 2], 6);
		animation.add("jump", [4]);
		animation.play("stand");
	}
	
	override public function kill():Void 
	{
		alive = false;
		enableAcceleration = false;
		acceleration.set();
		velocity.set();
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		var playerVel = 0.0;
		isShooting = false;
		isJumping = false;
		
		if (FlxG.keys.pressed.UP)
		{
			gunDirection = 0;
		}
		
		if (FlxG.keys.pressed.LEFT)
		{
			playerVel -= 120 * elapsed;
			gunDirection = -90;
			flipX = true;
		}
		
		if (FlxG.keys.pressed.RIGHT)
		{
			playerVel += 120 * elapsed;
			gunDirection = 90;
			flipX = false;
		}
		
		if (FlxG.keys.pressed.DOWN && (velocity.x != 0 || velocity.y != 0))
		{
			gunDirection = 180;
		}
		
		if (velocity.x == 0 && velocity.y == 0)
		{
			if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.RIGHT)
			{
				animation.play("run");
			}
			else
			{
				if (animation.curAnim.name != "stand")
				{
					animation.play("stand");
				}
			}
		}
		else
		{
			animation.play("jump");
		}
		
		if (FlxG.keys.pressed.Z)
		{
			isShooting = true;
		}
		
		if (FlxG.keys.justPressed.X)
		{
			isJumping = true;
		}
		
		orbitPos += playerVel;
	}
}