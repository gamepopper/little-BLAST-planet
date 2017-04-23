package;

import flixel.FlxSprite;
import flixel.effects.particles.FlxEmitter.FlxTypedEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.FlxG;

/**
 * ...
 * @author Gamepopper
 */
class DestructableSprite extends FlxTypedEmitter<FlxParticle>
{
	public function loadParticlesDestruct(Graphics:FlxGraphicAsset, Quantity:Int = 50, Width:Int = 0, Height:Int = 0):FlxTypedEmitter<FlxParticle>
	{
		maxSize = Quantity;
		var totalFrames:Int = 1;
		
		var sprite = new FlxSprite();
		sprite.loadGraphic(Graphics, true, Width, Height);
		totalFrames = sprite.numFrames;
		sprite.destroy();
			
		for (i in 0...Quantity)
			add(loadParticleDestruct(Graphics, Quantity, Width, Height, totalFrames));
		
		return this;
	}
	
	private function loadParticleDestruct(Graphics:FlxGraphicAsset, Quantity:Int, Width:Int, Height:Int, TotalFrames:Int):FlxParticle
	{
		var particle:FlxParticle = Type.createInstance(particleClass, []);
		var frame = FlxG.random.int(0, TotalFrames - 1);
		
		particle.loadGraphic(Graphics, true, Width, Height);
		particle.animation.frameIndex = frame;
		
		return particle;
	}
}