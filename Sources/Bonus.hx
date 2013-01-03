package;

import kha.Painter;

//
// Bonus
//
// The worm has to collect these.
//
class Bonus {
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
