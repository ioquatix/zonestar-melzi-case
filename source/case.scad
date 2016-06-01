
include <bolts.scad>;

// Melzi Dimensions 210mm x 50mm x 17mm

melzi_offset = [-14, -25/2, 0];
melzi_corner = [42/2, 201/2, 0];
box_size = [80, 210+25+10, 64];
box_thickness = 4;
reset_offset = melzi_offset + [-20, 0, 0];

// This function creates a cube with a given x/y either above (f=1) or below (f=-1) the z axis.
module baseline_cube(dimensions, z=0, f=1) {
	translate([0, 0, dimensions[2]/2 * f + z]) cube(dimensions, true);
}

module box(dimensions, lateral_thickness=box_thickness, inset=[0, 0, 0]) {
	difference() {
		minkowski() {
			baseline_cube(dimensions-inset, lateral_thickness);
			union() {
				translate([0, 0, -lateral_thickness]) cylinder(r=lateral_thickness,h=lateral_thickness,$fn=32);
				cylinder(r1=lateral_thickness,r2=0,h=lateral_thickness,$fn=32);
			}
		}
		baseline_cube(dimensions, lateral_thickness);
	}
}

module cable_holes() {
	// USB cut out, size/position not accurate.
	color("blue") translate([-box_size[0]/2, -60, 15]) minkowski() {
		cube([10, 40, 10], true);
		rotate(90, [0, 1, 0]) cylinder(h=1, r=5);
	}
	
	// Upper stepper motor cable hole:
	color("blue") translate([box_size[0]/2, 60, 15]) minkowski() {
		cube([10, 40, 10], true);
		rotate(90, [0, 1, 0]) cylinder(h=1, r=5);
	}
	
	// Upper stepper motor cable hole:
	color("blue") translate([box_size[0]/2, -60, 15]) minkowski() {
		cube([10, 40, 10], true);
		rotate(90, [0, 1, 0]) cylinder(h=1, r=5);
	}
}

module fan_cutout(height=box_thickness) {
	translate([0, 0, -height/2]) {
		cylinder_outer(height*2, 58/2, 128);
		for (a = [0:90:360]) {
			rotate(a, [0, 0, 1]) translate([25, 25, 0]) hole(depth=height*2, inset=0);
		}
	}
}

module lid_split() {
	// Lid
	lid_inset_size = [box_size[0]+box_thickness*2+1, box_size[1]-28*2, box_size[2]];
	edge_inset_size = [lid_inset_size[0]-box_thickness, lid_inset_size[1]+box_thickness, lid_inset_size[2]];
	difference() {
		union() {
			baseline_cube(lid_inset_size, 15);
			baseline_cube(edge_inset_size, 15-box_thickness/2);
			baseline_cube(box_size*2, box_size[2]+box_thickness);
		}
		
		//baseline_cube(box_size, box_thickness);
	}
}

module corner_holes() {
	// Lid screw holes:
	corner = [box_size[0]/2-box_thickness/2, box_size[1]/2-box_thickness/2, box_thickness];
	for (a = [0:180:360]) {
		rotate(a, [0, 0, 1]) translate(corner) mounting_hole(depth=box_size[2], outset=box_thickness);
		rotate(a, [0, 0, 1]) mirror() translate(corner) mounting_hole(depth=box_size[2], outset=box_thickness);
	}
}

module reset_button_hole(inset = 8) {
	translate(reset_offset) {
		baseline_cube([10, 10, inset + box_thickness], box_size[2] + box_thickness*2, -1);
		
		baseline_cube([2, 12, inset], box_size[2] + box_thickness, -1);
		baseline_cube([12, 2, inset], box_size[2] + box_thickness, -1);
	}
}

module reset_button_mount(inset = 8) {
	translate(reset_offset) baseline_cube([24, 24, inset], box_size[2] + box_thickness, -1);
}

module reset_button(inset = 8) {
	translate(reset_offset) {
		baseline_cube([10, 10, inset + box_thickness], box_size[2] + box_thickness*2, -1);
		baseline_cube([5, 5, box_size[2]-10], box_size[2] + box_thickness*2, -1);
		
		baseline_cube([2, 12, inset], box_size[2] + box_thickness, -1);
		baseline_cube([12, 2, inset], box_size[2] + box_thickness, -1);
	}
}

module case() {
	difference() {
		union() {
			color("white") box(box_size);
			
			corner_holes();
			
			translate([0, 0, box_thickness] + melzi_offset) {
				//color([0, 0, 1, 0.5]) translate([0, 0, 17/2]) cube([50, 210, 17], true);
				
				for (a = [0:180:360]) {
					rotate(a, [0, 0, 1]) translate(melzi_corner) mounting_hole();
					rotate(a, [0, 0, 1]) mirror([1, 0, 0]) translate(melzi_corner) mounting_hole();
				}
			}
			
			reset_button_mount();
		}
		
		reset_button_hole();
		
		// Fan cutout
		translate([0, box_size[1] / 2 + box_thickness, box_size[2] / 2 + box_thickness]) rotate(90, [1, 0, 0]) fan_cutout();
		translate([0, -(box_size[1] / 2), box_size[2] / 2 + box_thickness]) rotate(90, [1, 0, 0]) fan_cutout();
		
		cable_holes();
	}
}

module case_base() {
	difference() {
		case();
		scale(0.999) lid_split();
	}
}

module case_lid() {
	difference() {
		intersection() {
			color("red") case();
			lid_split();
		}
		
		corner = [box_size[0]/2-box_thickness/2, box_size[1]/2-box_thickness/2, box_size[2] + box_thickness];
		
		for (a = [0:180:360]) {
			rotate(a, [0, 0, 1]) translate(corner) hole(depth=box_thickness, outset=box_thickness);
			rotate(a, [0, 0, 1]) mirror([1, 0, 0]) translate(corner) hole(depth=box_thickness, outset=box_thickness);
		}
		
		translate([-box_size[0]/2+5, -box_size[1]/2+5, box_size[2]]) linear_extrude(box_thickness*3) text("MELZI");
		
		reset_button_hole();
	}
}

module fan() {
	color("orange", 0.5) translate([0, box_size[1] / 2 - 25/2, box_size[2] / 2 + box_thickness]) cube([60, 25, 60], true);
}

translate([0, 25/2, 0]) {
	fan();
	//case();
	case_base();
	//case_lid();
	reset_button();
}