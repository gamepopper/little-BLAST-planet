package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxVector;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

/**
 * ...
 * @author Gamepopper
 */
class Rockets extends FlxTypedGroup<FlxSprite>
{
	var timer:FlxTimer;
	var speed = 50;

	public function new(MaxSize:Int=0) 
	{
		super(MaxSize);
		
		for (i in 0...MaxSize)
		{
			var rocket = new FlxSprite();
			rocket.loadGraphic("assets/images/rocket.png");
			rocket.color = FlxColor.RED;
			rocket.cameras = [FlxG.cameras.list[0]];
			rocket.kill();
			add(rocket);
		}
		
		timer = new FlxTimer();
		timer.start(2, spawnRocket);
	}
	
	function spawnRocket(timer:FlxTimer)
	{
		var rocket = getFirstDead();
		
		if (rocket != null)
		{
			rocket.revive();
			
			var angle = FlxG.random.float(0.0, 360.0);
			
			var vector:FlxVector = new FlxVector();
			vector.set(FlxG.width * 0.75, 0);
			vector.rotateByDegrees(angle);
			vector.add(FlxG.width / 2.0, FlxG.height / 2.0);
			rocket.setPosition(vector.x - (rocket.width / 2.0), vector.y - (rocket.height / 2.0));
			
			vector.set(FlxG.width / 2.0, FlxG.height / 2.0);
			vector.subtract(rocket.x + (rocket.width / 2.0), rocket.y + (rocket.height / 2.0));
			vector.normalize();
			rocket.velocity.set(vector.x * speed, vector.y * speed);
			
			rocket.angle = angle + 180;
			
			speed += 5;
			
			timer.start(2, spawnRocket);
		}
	}
	
}