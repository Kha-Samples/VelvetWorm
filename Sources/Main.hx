package;

import kha.System;

class Main {
	public static function main() {
		System.init({width: 640, height: 480, title: "Velvet Worm"}, function () {
			new VelvetWorm();
		});
	}
}
