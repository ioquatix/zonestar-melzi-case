
// Melzi Dimensions approx 210mm x 50mm x 17mm
melzi_dimensions = [208.3, 49.55, 1.7];
melzi_hole_offset = [3.81, 3.81, 0];

module melzi_pcb() {
	offset = [-melzi_dimensions[0]/2, -melzi_dimensions[1]/2, melzi_dimensions[2]];
	
	color("green") translate(offset) import("melzi_pcb.stl", convexity=4);
}

module melzi_holes() {
	offset = [-melzi_dimensions[0]/2, -melzi_dimensions[1]/2, 0];
	
	for (a = [0:180:360]) {
		rotate(a, [0, 0, 1]) translate(offset + melzi_hole_offset) children();
		rotate(a, [0, 0, 1]) mirror([1, 0, 0]) translate(offset + melzi_hole_offset) children();
	}
}

// Example PCB:
melzi_pcb();
