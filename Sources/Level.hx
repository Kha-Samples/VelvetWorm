package;

import kha.graphics2.Graphics;

//
// Level
//
// The level/tilemap in which the game takes place
//
class Level {
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
	
	public function render(g: Graphics) {
		// TODO
	}
}
