
use <bolts.scad>;
use <melzi.scad>;

box_size = [76, 210+25+10, 64];
box_thickness = 4;

melzi_offset = [-12, -10, 0];
reset_offset = melzi_offset + [-19, -1.2, 0];

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
				cylinder(r1=lateral_thickness,r2=lateral_thickness*0.4,h=lateral_thickness,$fn=32);
			}
		}
		baseline_cube(dimensions, lateral_thickness);
	}
}

module cable_hole_bevel() {
	rotate(90, [0, 1, 0]) translate([0, 0, -0.5]) cylinder(h=1, r=5);
}

module cable_holes() {
	edge_offset = box_size[0]/2+box_thickness/2;
	
	// USB cut out, size/position not accurate.
	color("blue") translate([-edge_offset, -66, 15]) minkowski() {
		cube([box_thickness, 28, 2], true);
		cable_hole_bevel();
	}
	
	// Upper stepper motor cable hole:
	color("blue") translate([edge_offset, 60, 15]) minkowski() {
		cube([box_thickness, 40, 2], true);
		cable_hole_bevel();
	}
	
	// Upper stepper motor cable hole:
	color("blue") translate([edge_offset, -60, 15]) minkowski() {
		cube([box_thickness, 40, 2], true);
		cable_hole_bevel();
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

module lid_split(edge_inset = 0, lip_inset = 0) {
	lid_inset_size = [box_size[0]+box_thickness*2, box_size[1]-28*2-lip_inset, box_size[2]];
	edge_inset_size = [lid_inset_size[0]-box_thickness-edge_inset, lid_inset_size[1]+box_thickness, lid_inset_size[2]-edge_inset];
	difference() {
		union() {
			baseline_cube(lid_inset_size, 15+lip_inset/2);
			baseline_cube(edge_inset_size, 15-box_thickness/2+lip_inset/2);
			baseline_cube(box_size*2, box_size[2]+box_thickness);
		}
	}
}

module corner_holes() {
	// Lid screw holes:
	corner = [box_size[0]/2-box_thickness/2, box_size[1]/2-box_thickness/2, box_thickness];
	for (a = [0:180:360]) {
		rotate(a, [0, 0, 1]) translate(corner) mounting_hole(diameter=1.8, depth=box_size[2], outset=box_thickness);
		rotate(a, [0, 0, 1]) mirror() translate(corner) mounting_hole(diameter=1.8, depth=box_size[2], outset=box_thickness);
	}
}

module reset_button_hole(inset = 20) {
	translate(reset_offset) {
		baseline_cube([10, 10, inset + box_thickness], box_size[2] + box_thickness*2, -1);
		
		baseline_cube([2, 12, inset], box_size[2] + box_thickness, -1);
		baseline_cube([12, 2, inset], box_size[2] + box_thickness, -1);
	}
}

module reset_button_mount(inset = 8) {
	translate(reset_offset) baseline_cube([14, 14, inset], box_size[2] + box_thickness, -1);
}

module reset_button(inset = 8) {
	translate(reset_offset) {
		baseline_cube([10, 10, inset + box_thickness], box_size[2] + box_thickness*2, -1);
		baseline_cube([5, 5, box_size[2]-5], box_size[2] + box_thickness*2, -1);
		
		scale_factor = 0.95;
		
		baseline_cube([1.8, 11.8, inset], box_size[2] + box_thickness, -1);
		baseline_cube([11.8, 1.8, inset], box_size[2] + box_thickness, -1);
	}
}

module melzi_mount(height = 6) {
	translate([0, 0, box_thickness] + melzi_offset) rotate(-90, [0, 0, 1]) {
		translate([0, 0, height]) melzi_pcb();
		melzi_holes() mounting_hole(diameter=2.8, depth=height);
	}
}

module case() {
	difference() {
		union() {
			box(box_size);
			
			corner_holes();
			
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
		lid_split();
		translate([6, -18, 0]) rotate(90, [0, 0, 1]) melzi_holes() hole(depth=4);
	}
}

module lid_baffle() {
	length = box_size[1] * 0.8;
	
	translate([0, 0, 50]) difference() {
		cube([box_size[0], length, 40], true);
		hull() {
			translate([0, length/2, 0]) cube([60, 10, 40], true);
			translate([-10, 0, -10]) cube([50, 10, 30], true);
		}
		hull() {
			translate([-10, 0, -10]) cube([50, 10, 30], true);
			translate([-10, -length/2, -10]) cube([50, 10, 30], true);
		}
	}
}

module case_lid() {
	difference() {
		intersection() {
			case();
			lid_split(0.6, 0.6);
		}
		
		corner = [box_size[0]/2-box_thickness/2, box_size[1]/2-box_thickness/2, box_size[2] + box_thickness];
		
		for (a = [0:180:360]) {
			rotate(a, [0, 0, 1]) translate(corner) countersunk_hole(diameter=2, depth=box_thickness-0.5, outset=box_thickness);
			rotate(a, [0, 0, 1]) mirror([1, 0, 0]) translate(corner) countersunk_hole(diameter=2, depth=box_thickness-0.5, outset=box_thickness);
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
	melzi_mount();
	//case();
	color("white") render() case_base();
	color("red") render() case_lid();
	//color("blue") reset_button();
}
