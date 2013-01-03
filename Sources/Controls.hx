package;

import kha.Button;

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
