package;
import flixel.effects.particles.FlxEmitter;
import flixel.math.FlxVector;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxG;

/**
 * ...
 * @author Gamepopper
 */
class Spike extends OrbitalSprite 
{
	var moveIn:Bool = false;
	var spikeTimer:FlxTimer;
	
	public var smoke:FlxEmitter;
	var smokeTimer:FlxTimer;
	
	public function new(objRadius:Int, worldRadius:Int, delay:Float = 0) 
	{
		super(objRadius, Std.int(worldRadius * 0.5));
		
		smokeTimer = new FlxTimer();
		smokeTimer.start(2 + delay - 1, emitSmoke);
		
		smoke = new FlxEmitter();
		smoke.loadParticles("assets/images/smoke.png", 6);
		smoke.launchMode = FlxEmitterMode.CIRCLE;
		
		spikeTimer = new FlxTimer();
		spikeTimer.start(2 + delay, moveSpike);
		
		enableAcceleration = false;
	}
	
	override public function kill():Void 
	{
		active = false;
	}
	
	function emitSmoke(timer:FlxTimer)
	{
		smoke.launchAngle.set(orbitPos - 90 - 10, orbitPos - 90 + 10);
		smoke.setPosition(x + (width / 2.0), y + (height / 2.0));
		smoke.speed.set(100, 200);
		smoke.lifespan.set(1);
		smoke.alpha.set(1, 1, 0, 0);
		smoke.start(true);
		
		FlxG.sound.play("smoke");
	}
	
	function moveSpike(timer:FlxTimer)
	{
		var distanceA:Float = 0;
		var distanceB:Float = 0;
		
		if (moveIn)
		{
			distanceA = (worldRad * 2) + objRad;
			distanceB = worldRad;
			spikeTimer.start(2, moveSpike);
			
			if (active)
				smokeTimer.start(1, emitSmoke);
		}
		else
		{
			distanceA = worldRad;
			distanceB = (worldRad * 2) + objRad;
			
			if (active)
				spikeTimer.start(1, moveSpike);
			
			FlxG.sound.play("spike");
		}
		
		moveIn = !moveIn;
		
		var vectorA:FlxVector = new FlxVector();
		vectorA.set(0, -distanceA);
		vectorA.rotateByDegrees(orbitPos);
		vectorA.add(FlxG.width / 2.0, FlxG.height / 2.0);
		vectorA.subtract(objRad, objRad);
		
		var vectorB:FlxVector = new FlxVector();
		vectorB.set(0, -distanceB);
		vectorB.rotateByDegrees(orbitPos);
		vectorB.add(FlxG.width / 2.0, FlxG.height / 2.0);
		vectorB.subtract(objRad, objRad);
		
		x = vectorA.x;
		y = vectorA.y;
		FlxTween.tween(this, { x: vectorB.x, y: vectorB.y }, 1.0, { ease: FlxEase.quintOut });
	}
}