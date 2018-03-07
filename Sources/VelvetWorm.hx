//
// Velvet Worm
//
// Velvet Worm is a game where you play a worm and have to collect boni that appear at random positions in the level.
// Velvet worms are segmented creatures, and each time you collect a bonus, the worm becomes longer and its speed
// increases. If the worm collides with the level or with itself, you lose the game.
//

package;

import kha.Assets;
import kha.Color;
import kha.FontStyle;
import kha.Framebuffer;
import kha.Image;
import kha.input.Keyboard;
import kha.input.KeyCode;
import kha.Scaler;
import kha.Scheduler;
import kha.System;

//
// VelvetWorm
//
// The game class. Controls everything for this game.
//
class VelvetWorm {
	static public var TILE_WIDTH  = 20;
	static public var TILE_HEIGHT = 20;
	
	var backbuffer: Image;
	
	// Game objects and controls
	var worm: Worm;
	var bonus: Bonus;
	var level: Level;
	var controls: Controls;

	// Start game only after everything has been loaded/initialized
	var initialized: Bool;
	
	// Random number generator
	var rand_seed: Int;
	
	private function rand(range: Int) : Int {
		rand_seed = rand_seed * 37 + 13;
		return (rand_seed & 0xFFFFFF) % range;
	}
	
	public function new() {
		worm    = new Worm();
		bonus    = new Bonus();
		level    = new Level();
		controls = new Controls();
		
		initialized = false;
	
		backbuffer = Image.createRenderTarget(640, 480);
		Assets.loadEverything(afterLoad);
	}
	
	function afterLoad(): Void {
		newGame();
		System.notifyOnRender(render);
		Scheduler.addTimeTask(update, 0, 1 / 60);
		Keyboard.get().notify(buttonDown, buttonUp, null);
		initialized = true;
	}
	
	// repositionBonus()
	//
	// Bonus is repositioned at the start of a level and each time a bonus has been collected.
	// The position for the bonus has to be chosen so that neither the level nor the snake
	// collides with it and it needs a minimum distance from the snake's head.
	private function repositionBonus(number: Int): Void {
		var MIN_DISTANCE_FROM_SNAKE_HEAD: Int = 5;
		
		// The chosen position
		var x: Int;
		var y: Int;
		
		var tries: Int; // Limited number of tries, because game must never freeze
		
		var snake_head_x: Int = worm.getHeadX();
		var snake_head_y: Int = worm.getHeadY();
		
		// Default positions for when there's no suitable position found:
		x = 0;
		y = 0;
		
		tries = 0;
		while (tries < 100) {
			// Try random position
			var try_x: Int = rand(level.width );
			var try_y: Int = rand(level.height);
			
			if (!level.isCollisionAt(try_x, try_y) && !worm.isAnyPartAt(try_x, try_y)) {
				var dx: Float = try_x - snake_head_x;
				var dy: Float = try_y - snake_head_y;
				var distance_from_snake_head: Float = Math.sqrt(dx * dx + dy * dy);
				
				if (distance_from_snake_head >= MIN_DISTANCE_FROM_SNAKE_HEAD) {
					// Position is okay.
					x = try_x;
					y = try_y;
					break;
				}
				
				// Note: You can get rid easily of the (slow) sqrt() if you use the square of MIN_DISTANCE_FROM_SNAKE_HEAD.
			}
			
			tries++; // Position wasn't okay, try another try
		}
		
		// Found or found not a position.
		// Reposition the bonus.
		bonus.reposition(x, y, number);
	}
	
	public function newGame(): Void {
		// Reset all game objects and controls
		level.reset(0);
		worm.newGame(level);
		repositionBonus(1);
		controls.reset();
		
		// Initialize random number generator
		rand_seed = 17;
	}
	
	public function update() : Void {
		if (!initialized) return; // Cancel if game has not been started yet
		
		worm.update(controls, level);
		bonus.update();
		
		// Collect boni
		if (worm.getHeadX() == bonus.x && worm.getHeadY() == bonus.y) {
			repositionBonus(bonus.number + 1);
			worm.extend(2);
			worm.increaseSpeed();
		}
		
		// Snake collision with level or itself
		if (worm.hasCollided()) {
			newGame();
		}
	}
	
	// render(): Draw snake, bonus, and level
	public function render(frame: Framebuffer): Void {
		if (!initialized) return; // Cancel if game has not been started yet
		
		var g = backbuffer.g2;
		g.begin();
		g.clear(Color.Black);
		g.font = Assets.fonts.arial;
		g.fontSize = 14;
		level.render(g);
		worm.render(g);
		bonus.render(g);
		g.end();
		
		frame.g2.begin();
		Scaler.scale(backbuffer, frame, System.screenRotation);
		frame.g2.end();
	}
	
	//
	// Controls
	//
	function buttonDown(button: KeyCode): Void {
		controls.buttonDown(button);
	}
	
	function buttonUp(button: KeyCode): Void {
		controls.buttonUp(button);
	}
}
