package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.effects.particles.FlxEmitter;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.addons.tile.FlxCaveGenerator;

class PlayState extends FlxState
{
	var globe:FlxSprite;
	var globeSelfDestruct:Bool = false;
	var globeSelfDestructTimer:Float = 0;
	
	var player:Player;
	var playerBody:OrbitalSprite;
	var playerGun:Gun;
	
	var rocketGroup:Rockets;
	
	var spikeGroup:FlxTypedGroup<Spike>;
	var spikeSmokeGroup:FlxGroup;
	
	var goombaGroup:FlxTypedGroup<Goomba>;
	var goombaTimer:FlxTimer;
	
	var escape:Escape;
	var escapeTimer:FlxTimer;
	
	var timeText:FlxText;
	var selfDestructText:FlxText;
	var activeGame = true;
	
	var radius = 100;
	
	var explosionSound:FlxSound;
	var deadSound:FlxSound;
	
	public static var time:Float = 0.0;
	public static var level:Int = 1;
	public static var follow:Bool = false;
	
	override public function create():Void
	{
		super.create();
		
		if (!FlxG.sound.music.playing)
			FlxG.sound.playMusic("game");
		
		explosionSound = new FlxSound();
		explosionSound.loadEmbedded("explosion");
		
		deadSound = new FlxSound();
		deadSound.loadEmbedded("lose");
		
		FlxG.cameras.reset();
		
		var camera:FlxCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		camera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(camera);
		
		var activeCam = [FlxG.cameras.list[0]];
		var uiCam = [FlxG.cameras.list[1]];
		
		if (level > 2 && (FlxG.random.bool()))
			radius += FlxG.random.int( -20, 25);
		
		FlxG.camera.zoom = 100 / radius;
		FlxG.camera.angle = 0;
		
		var halfRad = Std.int(radius / 2);
		var map:Array<Array<Int>> = FlxCaveGenerator.generateCaveMatrix(halfRad, halfRad, 5, 0.5);
		
		globe = new FlxSprite(FlxG.width / 2 - radius, FlxG.height / 2 - radius);
		globe.cameras = activeCam;
		globe.immovable = true;
		globe.makeGraphic(radius * 2, radius * 2, FlxColor.TRANSPARENT, true);
		FlxSpriteUtil.drawCircle(globe, radius, radius, radius - 4);
		
		for (x in 0...radius * 2)
		{
			for (y in 0...radius * 2)
			{
				var pixel = globe.pixels.getPixel(x, y);
				
				if (pixel != 0)
				{
					if (map[Std.int(y / 4)][Std.int(x / 4)] == 0)
					{
						globe.pixels.setPixel(x, y, FlxColor.BLACK);
					}
				}
			}
		}
		
		var lineStyle:LineStyle = { color: FlxColor.WHITE, thickness: 4 };
		FlxSpriteUtil.drawCircle(globe, radius, radius, radius - 2, FlxColor.TRANSPARENT, lineStyle);
		
		player = new Player(12, radius);
		player.cameras = activeCam;
		playerBody = new OrbitalSprite(12, radius);
		playerBody.cameras = activeCam;
		playerBody.enableAcceleration = false;
		playerBody.loadGraphic("assets/images/PlayerBody.png", true, 24, 24);
		playerBody.animation.add("up", [0]);
		playerBody.animation.add("forward", [1]);
		playerBody.animation.add("down", [2]);
		
		playerGun = new Gun(radius);
		
		var bulletCount = 10;		
		for (i in 0...bulletCount)
		{
			var bullet = new FlxSprite();
			bullet.loadGraphic("assets/images/bullet.png");
			bullet.cameras = activeCam;
			bullet.kill();
			playerGun.add(bullet);
		}
		
		var rocketCount:Int = 1 + level;
		var spikeCount:Int = level > 2 ? Std.int(level / 2) * 2 : 0;
		var goombaCount:Int = 3 + level;
		
		rocketGroup = new Rockets(rocketCount);
		
		spikeGroup = new FlxTypedGroup<Spike>(spikeCount);
		spikeSmokeGroup = new FlxGroup(spikeCount);
		for (i in 0...spikeCount)
		{
			var spike = new Spike(16, radius, i % 2 == 0 ? 0 : 2);
			spike.loadGraphic("assets/images/spike.png");
			spike.color = FlxColor.RED;
			spike.orbitPos = (360 / spikeCount) * i;
			spike.orbitPos += 45;
			spike.cameras = activeCam;
			spikeGroup.add(spike);
			
			for (j in 0...spike.smoke.length)
				spike.smoke.members[i].cameras = activeCam;
				
			spikeSmokeGroup.add(spike.smoke);
		}
		
		goombaGroup = new FlxTypedGroup<Goomba>(goombaCount);
		for (i in 0...goombaCount)
		{
			var goomba:Goomba;
			
			if (FlxG.random.bool(30))
			{
				goomba = new Goomba(8, radius);
				goomba.loadGraphic("assets/images/spring.png");
				goomba.orbitPos = FlxG.random.float(45, 315);
				goomba.bounce = true;
			}
			else
			{
				goomba = new Goomba(12, radius);
				goomba.loadGraphic("assets/images/bot.png", true, 24, 24);
				goomba.animation.add("walk", [0, 1], 4);
				goomba.animation.play("walk");
				goomba.orbitPos = FlxG.random.float(45, 315);
			}
			
			goomba.cameras = activeCam;
			goomba.color = FlxColor.RED;
			goomba.kill();			
			goombaGroup.add(goomba);
		}
		goombaTimer = new FlxTimer();
		goombaTimer.start(1, spawnGoomba);
		
		escape = new Escape(24, radius);
		escape.cameras = activeCam;
		escape.loadGraphic("assets/images/escape.png");
		escape.kill();
		
		escapeTimer = new FlxTimer();
		escapeTimer.start(30, escapeEnable);
		
		timeText = new FlxText(0, 0, FlxG.width, "", 16);
		timeText.alignment = "centre";
		timeText.cameras = uiCam;
		
		selfDestructText = new FlxText(0, 460, FlxG.width, "", 16);
		selfDestructText.alignment = "centre";
		selfDestructText.cameras = uiCam;
		
		add(spikeGroup);
		add(spikeSmokeGroup);
		add(globe);
		add(player);
		add(playerBody);
		add(playerGun);
		add(goombaGroup);
		add(rocketGroup);
		add(escape);
		add(timeText);
		add(selfDestructText);
	}
	
	function bulletDestroy(bullet:FlxSprite, other:FlxSprite)
	{
		bullet.kill();
		other.kill();
		FlxG.sound.play("hurt");
	}
	
	function touchPlayer(object:FlxSprite, player:FlxSprite)
	{
		EndGame(false);
	}
	
	function spikeToPlayer(spike:FlxSprite, player:FlxSprite)
	{
		var diff:FlxVector = new FlxVector();
		diff.set(spike.x, spike.y);
		diff.add(spike.width / 2.0, spike.height / 2.0);
		var length = diff.distanceTo(new FlxPoint(FlxG.width / 2.0, FlxG.height / 2.0));
		
		if (length > radius)
		{
			EndGame(false);
		}
	}
	
	function rocketToGlobe(rocket:FlxSprite, globe:FlxSprite)
	{
		var diff:FlxVector = new FlxVector();
		diff.set(rocket.x, rocket.y);
		diff.add(rocket.width / 2.0, rocket.width / 2.0);
		diff.subtract(FlxG.width / 2.0, FlxG.height / 2.0);
		
		if (diff.length < radius + rocket.width / 2.0)
		{
			EndGame(true);
		}
	}
	
	function spawnGoomba(timer:FlxTimer)
	{
		if (goombaGroup.active)
		{
			var goomba:Goomba;
			
			goomba = goombaGroup.getFirstDead();
			
			if (goomba != null)
			{
				goomba.revive();
				goomba.setPosition( -goomba.width / 2, -radius * 4 - (goomba.height / 2));
				goomba.orbitPos = FlxG.random.float(player.orbitPos + 45, player.orbitPos + 315);
			}
			
			goombaTimer.start(2, spawnGoomba);
		}
	}
	
	function escapeEnable(timer:FlxTimer)
	{
		escape.revive();
		globeSelfDestruct = true;
		FlxG.sound.play("play");
	}
	
	function escapePlanet(player:FlxSprite, escape:FlxSprite)
	{
		level++;
		FlxG.cameras.remove(FlxG.cameras.list[1]);
		FlxG.resetState();
		escape.kill();
	}
	
	function EndGame(destroyGlobe:Bool)
	{
		if (activeGame)
		{
			if (destroyGlobe)
			{				
				globe.kill();
				spikeGroup.kill();
				
				var emitter:DestructableSprite = new DestructableSprite();
				emitter.loadParticlesDestruct(globe.graphic, 80, Std.int(globe.width / 10), Std.int(globe.height / 10));
				emitter.angularVelocity.set( -50, 50);
				emitter.setPosition(FlxG.width / 2.0, FlxG.height / 2.0);
				emitter.start();
				add(emitter);
				
				explosionSound.play();
			}
			
			FlxG.sound.music.stop();
			
			player.kill();		
			player.enableAcceleration = false;
			
			deadSound.play();
			
			playerBody.alive = false;
			
			player.velocity.set(FlxG.random.int( -50, 50), FlxG.random.int( -50, 50));
			player.angularVelocity = FlxG.random.int( -100, 100, [0]);
			playerBody.velocity.set(FlxG.random.int( -50, 50), FlxG.random.int( -50, 50));
			
			playerGun.kill();
			spikeGroup.active = false;
			rocketGroup.active = false;
			goombaGroup.active = false;
			goombaTimer.cancel();
			activeGame = false;
		}
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		if (activeGame)
		{
			time += elapsed;
			
			if (globeSelfDestruct)
			{
				globeSelfDestructTimer += elapsed;			
				selfDestructText.text = "Escape the Planet before self-destruct in " + Std.int(10 - globeSelfDestructTimer);
			
				if (globeSelfDestructTimer > 10)
				{
					EndGame(true);
				}
			}
		}
		else
		{
			if (FlxG.keys.justPressed.R)
			{
				time = 0;
				level = 1;
				FlxG.cameras.remove(FlxG.cameras.list[1]);
				FlxG.resetState();
			}
			
			if (FlxG.keys.justPressed.M)
			{
				time = 0;
				level = 1;
				FlxG.cameras.remove(FlxG.cameras.list[1]);
				FlxG.resetGame();
			}
		}
			
		if (follow)
			FlxG.camera.angle = -player.orbitPos;
		
		if (player.isShooting)
		{
			playerGun.fire(new FlxPoint(player.x, player.y), player.getDirection(player.gunDirection), 12);
		}
		
		if (player.isJumping)
		{
			player.jump(400);
		}
		
		playerBody.orbitPos = player.orbitPos;
		playerBody.setPosition(player.x, player.y);
		playerBody.flipX = player.flipX;
		
		if (player.gunDirection == 0)
		{
			playerBody.animation.play("up");
		}
		else if (player.gunDirection == 180)
		{
			playerBody.animation.play("down");
		}
		else
		{
			playerBody.animation.play("forward");
		}
		
		FlxG.collide(playerGun, rocketGroup, bulletDestroy);
		FlxG.collide(playerGun, goombaGroup, bulletDestroy);
		
		if (escape.alive)
			FlxG.collide(player, escape, escapePlanet);
		
		FlxG.overlap(rocketGroup, globe, rocketToGlobe);
		FlxG.overlap(spikeGroup, player, spikeToPlayer);
		FlxG.overlap(rocketGroup, player, touchPlayer);
		FlxG.overlap(goombaGroup, player, touchPlayer);
		
		if (!player.alive || !globe.alive)
		{
			selfDestructText.text = "You died. (R)estart or go to (M)enu.";
		}
		
		var milliseconds:Int = Std.int(time * 1000);
		timeText.text = "" + 
		Std.int(milliseconds / 60000) + " minutes " + 
		Std.int(milliseconds / 1000) % 60 + " seconds " + 
		(milliseconds % 1000) + " milliseconds";
	}
}
