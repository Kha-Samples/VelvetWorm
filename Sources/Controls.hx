package;

import kha.input.KeyCode;

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
	
	public function buttonDown(button: KeyCode): Void {
		if (button == Left ) left  = true;
		if (button == Right) right = true;
		if (button == Up   ) up    = true;
		if (button == Down ) down  = true;
	}
	
	public function buttonUp(button: KeyCode): Void {
		if (button == Left ) left  = false;
		if (button == Right) right = false;
		if (button == Up   ) up    = false;
		if (button == Down ) down  = false;
	}
}
