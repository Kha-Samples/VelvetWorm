package;

import kha.Color;
import kha.graphics2.Graphics;

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
	
	public function render(g: Graphics): Void {
		var TILE_WIDTH : Int = VelvetWorm.TILE_WIDTH ;
		var TILE_HEIGHT: Int = VelvetWorm.TILE_HEIGHT;
		
		g.color = Color.White;
		g.fillRect(x * TILE_WIDTH, y * TILE_HEIGHT, TILE_WIDTH, TILE_HEIGHT);
	}
}

//
// Worm
//
// The velvet worm itself!
//
class Worm {
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
	public function render(g: Graphics): Void {
		for (i in 0 ... parts.length) {
			parts[i].render(g);
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
