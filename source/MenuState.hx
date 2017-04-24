package;

import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxSpriteUtil;
import flixel.addons.tile.FlxCaveGenerator;
import flixel.addons.display.FlxStarField.FlxStarField2D;
import flixel.FlxState;
import flixel.FlxG;
import flixel.util.FlxColor;

/**
 * ...
 * @author Gamepopper
 */
class MenuState extends FlxState 
{
	var globe:FlxSprite;
	var entries:FlxTypedGroup<FlxText>;
	var currentEntry = 0;
	
	var playerLegs:FlxSprite = new FlxSprite();
	var playerBody:FlxSprite = new FlxSprite();
	
	override public function create():Void 
	{
		super.create();
		
		FlxG.mouse.visible = false;
		
		FlxG.sound.playMusic("title");
		
		FlxG.camera.fade(FlxColor.BLACK, 1, true);
		
		var radius = 50;
		var map:Array<Array<Int>> = FlxCaveGenerator.generateCaveMatrix(radius, radius, 5, 0.5);		
		globe = new FlxSprite(FlxG.width * 0.8 - radius, FlxG.height * 0.2 - radius);
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
					if (map[Std.int(y / 2)][Std.int(x / 2)] == 0)
					{
						globe.pixels.setPixel(x, y, FlxColor.BLACK);
					}
				}
			}
		}
		
		var lineStyle:LineStyle = { color: FlxColor.WHITE, thickness: 4 };
		FlxSpriteUtil.drawCircle(globe, radius, radius, radius - 2, FlxColor.TRANSPARENT, lineStyle);
		
		var starfield:FlxStarField2D = new FlxStarField2D(0, 0, FlxG.width, FlxG.height, 300);
		starfield.setStarDepthColors(1, FlxColor.WHITE, FlxColor.WHITE);
		starfield.setStarSpeed(10, 30);
		
		entries = new FlxTypedGroup<FlxText>();
		for (i in 0...2)
		{
			var text:FlxText = new FlxText(0, FlxG.height / 2 + (i * 20), FlxG.width, "", 16);
			text.alignment = "center";
			entries.add(text);
		}
		
		var floor:FlxSprite = new FlxSprite(0, FlxG.height - 160);
		floor.makeGraphic(FlxG.width, 160);
		
		playerLegs = new FlxSprite();
		playerLegs.loadGraphic("assets/images/PlayerLegs.png", true, 24, 24);
		playerLegs.setPosition(FlxG.width / 2 - playerLegs.width / 2, FlxG.height - 160 - playerLegs.height);
		
		playerBody = new FlxSprite();
		playerBody.loadGraphic("assets/images/PlayerBody.png", true, 24, 24);
		playerBody.setPosition(FlxG.width / 2 - playerLegs.width / 2, FlxG.height - 160 - playerLegs.height);
		
		var logo = new FlxSprite();
		logo.loadGraphic("assets/images/logo.png");
		logo.setPosition(50, 50);
		
		add(starfield);
		add(globe);
		add(floor);
		add(playerLegs);
		add(playerBody);
		add(entries);
		add(logo);
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		var gamepad = FlxG.gamepads.getFirstActiveGamepad();
		
		if (FlxG.keys.justPressed.UP || (gamepad != null && (gamepad.justPressed.DPAD_UP || (gamepad.analog.justMoved.LEFT_STICK_Y && gamepad.analog.value.LEFT_STICK_Y < 0))))
		{
			currentEntry = (currentEntry - 1 + entries.length) % entries.length;
			FlxG.sound.play("select");
		}
		
		if (FlxG.keys.justPressed.DOWN || (gamepad != null && (gamepad.justPressed.DPAD_DOWN || (gamepad.analog.justMoved.LEFT_STICK_Y && gamepad.analog.value.LEFT_STICK_Y > 0))))
		{
			currentEntry = (currentEntry + 1 + entries.length) % entries.length;
			FlxG.sound.play("select");
		}
		
		if (FlxG.keys.justPressed.LEFT || (gamepad != null && (gamepad.justPressed.DPAD_LEFT || gamepad.analog.justMoved.LEFT_STICK_X)))
		{
			if (currentEntry == 1)
			{
				PlayState.follow = !PlayState.follow;
				FlxG.sound.play("select");
			}
		}
		
		if (FlxG.keys.justPressed.RIGHT)
		{
			if (currentEntry == 1)
			{
				PlayState.follow = !PlayState.follow;			
				FlxG.sound.play("select");
			}
		}
		
		if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE || (gamepad != null && gamepad.justPressed.A))
		{
			if (currentEntry == 0)
			{
				playerBody.kill();
				playerLegs.loadGraphic("assets/images/star.png");
				playerLegs.acceleration.y = -200;
				playerLegs.angularAcceleration = 800;			
				
				FlxG.sound.music.stop();
				FlxG.sound.play("win");
				FlxG.camera.flash();
			}
		}
		
		if (playerLegs.y + playerLegs.height < 0)
		{
			FlxG.switchState(new PlayState());
		}
		
		entries.members[0].text = "START GAME";
		entries.members[1].text = "CAMERA MODE: " + (PlayState.follow ? "FOLLOW" : "STATIC");
		
		entries.members[currentEntry].text = "< " + entries.members[currentEntry].text + " >";
	}
}