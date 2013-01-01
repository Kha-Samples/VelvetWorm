//
// Velvet Worm
//
// Velvet Worm is a game where you play a worm and have to collect boni that appear at random positions in the level.
// Velvet worms are segmented creatures, and each time you collect a bonus, the worm becomes longer and its speed
// increases. If the worm collides with the level or with itself, you lose the game.
//

package;

import kha.Direction;
import kha.Game;
import kha.Painter;
import kha.Sprite;
import kha.Image;
import kha.Loader;
import kha.Button;
import kha.Rectangle;

//
// Bonus
//
// The worm has to collect these.
//
private class Bonus {
	public var x: Int;
	public var y: Int;
	public var number: Int; // Current number of the bonus. Increases each time the snake collects a bonus.
	
	public function new(): Void {
	}
	
	// Reposition bonus. Is called by the main class.
	public function reposition(x: Int, y: Int, number: Int) {
		this.x = x;
		this.y = y;
		this.number = number;
	}
	
	public function update(): Void {
		// Nothing to do.
	}
	
	public function render(painter: Painter): Void {
		// Draw the bonus.
		// A rectangle with a number in it.
		
		var TILE_WIDTH : Int = VelvetWorm.TILE_WIDTH ;
		var TILE_HEIGHT: Int = VelvetWorm.TILE_HEIGHT;
		
		painter.setColor(255, 255, 255);
		painter.fillRect(x * TILE_WIDTH, y * TILE_HEIGHT, TILE_WIDTH, TILE_HEIGHT);
		
		painter.setColor(0, 0, 0);
		painter.drawString(Std.string(number), x * TILE_WIDTH, y * TILE_HEIGHT);
	}
}

//
// Part
//
// A part of the snake
//
private class Part {
	public var x: Int;
	public var y: Int;
	public var cnt: Int;
		// Countdown until the part moves.
		// New parts that are attached to the snake's tail, when a bonus has been collected,
		// do not instantly move. They wait until the old tail has moved away from them.
	
	public function new(x: Int, y: Int, cnt: Int): Void {
		this.x   = x;
		this.y   = y;
		this.cnt = cnt;
	}
	
	public function update(next_x: Int, next_y: Int): Void {
		if (cnt == 0) {
			x = next_x;
			y = next_y;
		}
		else {
			// Wait until part in front has moved away
			cnt--;
		}
	}
	
	public function render(painter: Painter): Void {
		var TILE_WIDTH : Int = VelvetWorm.TILE_WIDTH ;
		var TILE_HEIGHT: Int = VelvetWorm.TILE_HEIGHT;
		
		painter.setColor(255, 255, 255);
		painter.fillRect(x * TILE_WIDTH, y * TILE_HEIGHT, TILE_WIDTH, TILE_HEIGHT);
	}
}

//
// Worm
//
// The velvet worm itself!
//
private class Worm {
	static private var NUM_START_PARTS = 4; // Number of parts at start of a level
	
	var parts: Array<Part>;
	
	var cnt         : Int;       // Countdown until the next movement happens.
	var slowness    : Int;       // Expresses the speed of the snake (is used for 'cnt').
	var dir         : Direction; // Move direction. Player controls the snake with buttons.
	var has_collided: Bool;      // Indicates that the snake has collided with level or itself.
	
	public function new(): Void {
		parts = new Array<Part>();
	}
	
	// Start a new game.
	public function newGame(level: Level): Void {
		var x: Int = level.start_x;
		var y: Int = level.start_y;
		
		// Create all parts
		parts.splice(0, parts.length); // Delete parts from previous level/game
		for (i in 0 ... NUM_START_PARTS) {
			var part: Part = new Part(x, y, NUM_START_PARTS - 1 - i);
			parts.push(part);
		}
		
		slowness     = 10; // Speed at start
		cnt          = slowness;
		dir          = Direction.RIGHT;
		has_collided = false;
	}
	
	// Check all parts for collision:
	public function isAnyPartAt(x: Int, y: Int): Bool {
		for (i in 0 ... parts.length) {
			if (parts[i].x == x && parts[i].y == y) return true;
		}
		return false;
	}
	
	// Check collision with either level or any part of itself:
	private function isCollisionAt(x: Int, y: Int, level: Level): Bool {
		return isAnyPartAt(x, y) || level.isCollisionAt(x, y);
	}
	
	public function update(controls: Controls, level: Level): Void {
		if (has_collided) {
			// Do not move or do anything else if snake has collided
			return;
		}
		
		// Choose new direction if player pressed a button.
		//
		// Do not allow snake to change into the reverse of the current direction,
		// because else the snake would instantly collide in this case, which is
		// something the player really doesn't like.
		if (controls.left  && dir != Direction.RIGHT) dir = Direction.LEFT ; else
		if (controls.right && dir != Direction.LEFT ) dir = Direction.RIGHT; else
		if (controls.up    && dir != Direction.DOWN ) dir = Direction.UP   ; else
		if (controls.down  && dir != Direction.UP   ) dir = Direction.DOWN;
		
		cnt--; // Countdown until next movement
		if (cnt == 0) {
			// Choose next position for the head of the snake, depending on the current direction
			var next_x: Int;
			var next_y: Int;
			var head_part: Part = parts[parts.length - 1];
			next_x = head_part.x;
			next_y = head_part.y;
			if (dir == Direction.LEFT ) next_x = head_part.x - 1;
			if (dir == Direction.RIGHT) next_x = head_part.x + 1;
			if (dir == Direction.UP   ) next_y = head_part.y - 1;
			if (dir == Direction.DOWN ) next_y = head_part.y + 1;
			// Loop position within level
			if (next_x <  0           ) next_x = level.width - 1;
			if (next_x >= level.width ) next_x = 0;
			if (next_y <  0           ) next_y = level.height - 1;
			if (next_y >= level.height) next_y = 0;
			
			// Check for collision
			if (isCollisionAt(next_x, next_y, level)) {
				has_collided = true;
			}
			else {
				// Move all parts and the head
				for (i in 0 ... parts.length - 1) {
					parts[i].update(parts[i + 1].x, parts[i + 1].y); // Each part is moved to part in front of it
				}
				head_part.update(next_x, next_y);
			}
			
			// Reset countdown for next movement
			cnt = slowness;
		}
	}
	
	// extend(): Attach to parts at the tail
	public function extend(extend_length: Int) {
		var tail_x: Int = parts[0].x;
		var tail_y: Int = parts[0].y;
		for (i in 0 ... extend_length) {
			var part: Part = new Part(tail_x, tail_y, extend_length - 1 - i);
			parts.insert(0, part);
		}
	}
	
	// increaseSpeed(): The snake's speed is increased after a bonus has been collected
	public function increaseSpeed(): Void {
		if (slowness > 1) slowness -= 1;
	}
	
	// render(): Draw all parts of the snake
	public function render(painter: Painter): Void {
		for (i in 0 ... parts.length) {
			parts[i].render(painter);
		}
	}
	
	public function hasCollided(): Bool {
		return has_collided;
	}
	
	public function getHeadX(): Int {
		return parts[parts.length - 1].x;
	}
	
	public function getHeadY(): Int {
		return parts[parts.length - 1].y;
	}
}

//
// Level
//
// The level/tilemap in which the game takes place
//
private class Level {
	public var width  : Int;
	public var height : Int;
	public var start_x: Int;
	public var start_y: Int;
	
	public function new(): Void {
	}
	
	public function reset(id: Int): Void {
		width   = 32;
		height  = 24;
		start_x = 12;
		start_y =  8;
	}
	
	public function isCollisionAt(x: Int, y: Int) {
		// TODO
		return false;
	}
	
	public function render(painter: Painter) {
		// TODO
	}
}

//
// Controls
//
// Info about which buttons are currently pressed
//
class Controls {
	public var left : Bool;
	public var right: Bool;
	public var up   : Bool;
	public var down : Bool;
	
	public function new(): Void {
	}
	
	public function reset(): Void {
		left  = false;
		right = false;
		up    = false;
		down  = false;
	}
	
	public function buttonDown(button: Button): Void {
		if (button == Button.LEFT ) left  = true;
		if (button == Button.RIGHT) right = true;
		if (button == Button.UP   ) up    = true;
		if (button == Button.DOWN ) down  = true;
	}
	
	public function buttonUp(button: Button): Void {
		if (button == Button.LEFT ) left  = false;
		if (button == Button.RIGHT) right = false;
		if (button == Button.UP   ) up    = false;
		if (button == Button.DOWN ) down  = false;
	}
}

//
// VelvetWorm
//
// The game class. Controls everything for this game.
//
class VelvetWorm extends Game {
	static public var TILE_WIDTH  = 20;
	static public var TILE_HEIGHT = 20;
	
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
		super("Velvet Worm", false);
		
		worm    = new Worm();
		bonus    = new Bonus();
		level    = new Level();
		controls = new Controls();
		
		initialized = false;
	}
	
	override public function init(): Void {
		afterLoad();
	}
	
	public function afterLoad(): Void {
		newGame();
		
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
	
	override public function update() : Void {
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
	override public function render(painter : Painter) : Void {
		if (!initialized) return; // Cancel if game has not been started yet
		
		level.render(painter);
		worm.render(painter);
		bonus.render(painter);
	}
	
	//
	// Controls
	//
	override public function buttonDown(button: Button): Void {
		controls.buttonDown(button);
	}
	override public function buttonUp(button: Button): Void {
		controls.buttonUp(button);
	}
}