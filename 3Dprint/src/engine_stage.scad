use <library.scad>
include <global_parameters.scad>

inner_radius = 32 / 2;
height = stage_height;
motor_top = 173;
motor_bottom = 10;

// classic fins
fin_r = radius + 50;
fin_h = 25;
fin_angle = 16;

module motor_holder(wall) {
        rotate([0, 0, 11])
        translate([0, 0, -wall * 3])
        difference () {
            cylinder(r = radius - wall, h = wall * 3, $fn = resolution);
            translate([0, 0, -1])
            cylinder(r = inner_radius, h = (wall * 3) + 2, $fn = resolution);
        }
        
        difference () {
            cylinder(r = radius - wall, h = wall * 3, $fn = resolution);
            
            translate([0, 0, wall * 2])
                cylinder(r = 3, h = wall, $fn = resolution);
        }        
}


module inner_ring(angle = 11, segments) {
    rotate([0, 0, angle])
    //translate([0, 0, -wall * 3])
    difference () {
        cylinder(r = inner_radius + wall*3, h = wall*2, $fn=segments);
        cylinder(r = inner_radius + wall, h = wall*2, $fn=segments);
    }
}


module fins(outer_r, inner_r, wall, height, count, angle) {
    for (i = [1 : count]) {
        rotate([0, 0, i * 360/count])
        translate([-wall / 2, inner_r, 0])
        difference () {
            cube([wall, outer_r - inner_r, height]);
          
            color("red")
            translate([-1, 0, height])
            rotate([-angle, 0, 0])
            cube([wall + 2, (outer_r - inner_r) + height, height]);
        }
    }
    inner_points = [ for (i = [0 : count - 1]) [sin(i * 360/count) * (outer_r) , cos(i * 360/count) * (outer_r)]];
    outer_points = [ for (i = [0 : count - 1]) [sin(i * 360/count) * (outer_r + wall) , cos(i * 360/count) * (outer_r+wall)]];
    polygon_paths = [ [ for (i = [0 : count-1]) i ], [ for (i = [count : 2*count-1]) i ]];

    echo("outer points = ", outer_points);
    echo("inner points = ", inner_points);
    echo("paths = ", polygon_paths);
    
    linear_extrude(height = height - (tan(angle)*(outer_r - inner_r)))
        polygon(
            points =  concat(outer_points, inner_points),
            paths = polygon_paths
        );
}


module hull(radius, inner_radius, height, wall, motor_bottom, connection_lenght) {
	difference () {                 // hull shell
		cylinder(r = radius, h = height - connection_lenght , $fn=resolution);
		cylinder(r = radius - wall, h = height - connection_lenght, $fn=resolution);
	}


	difference () {
		union () {
			twisted_ribs(
				radius - (wall / 2),
				inner_radius,
				height,
				90,
				rib_count,
				rib_wall
			);						
		}
		
                cylinder(               // bevel inner ring for motor exhaust. 
			r1 = radius - wall,
			r2 = inner_radius,
			h = motor_bottom
		);
                
// connection to the next rocket stage
                translate([0, 0, height - connection_lenght])   // remove ribs to place stage connection section
                difference () {                
                        cylinder(r = radius, h = connection_lenght , $fn=resolution);
                        cylinder(r = radius- 1.5*wall, h = connection_lenght, $fn=resolution);
                }
        }

        translate([0, 0, height - connection_lenght])
        difference () {                 // hull shell
                cylinder(r = radius - wall - clear, h = connection_lenght , $fn=resolution);
                cylinder(r = radius - 2*wall - clear, h = connection_lenght, $fn=resolution);
        }

        translate([0, 0, height - connection_lenght - 2*wall])        
        difference () {                
            cylinder(               // bevel/smooth transformation between connection and rest of the rocket hull 
                    r = radius,
                    h = 2*wall,
                    $fn=resolution
            );

            cylinder(               // bevel/smooth transformation between connection and rest of the rocket hull 
                    r1 = radius - wall,
                    r2 = radius - 2*wall ,
                    h = 2*wall,
                    $fn=resolution
            );
        }        
}

module engine_stage () {
    difference () {
	    union () {
		    hull(radius, inner_radius, height, rib_wall, motor_bottom, connection_lenght);
                    
                    translate([0, 0, motor_bottom + 5])
                    inner_ring(5, rib_count);
                    
                    color("blue")
		    translate([0, 0, motor_top])
		    motor_holder(wall);
	    }
    }

    //color("red")
    fins(fin_r, radius - rib_wall, rib_wall , fin_h, 9, fin_angle);
}