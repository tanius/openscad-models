// Credits: based on "Chair plug generator" by Thingiverse user jnalezny, 
// licenced CC-BY 4.0 and available from https://www.thingiverse.com/thing:3854961

// a high number is more round, low number is more lo-poly
$fn = 50;

// height of the part hidden in the tube
height = 25;

// height of the base, that sticks out of the tube
bottomHeight = 5;

// how much of a bevel on the base that sticks out of the tube.  0 would be no bevel at all
bevel = 2.0;

// diameter of the base part that sticks out of the tube
bottomDiameter = 44.0;


// Radius size in mm of the ridges that help make a snug fit into the tubing
ridge = 0.75;

// how many ridges would you like? 6 is a good number.
ridgeCount = 10;


// diameter of the tube into which the cap should fit
tubeInnerDiameter = 39.6;

// outer diameter of the part of the plug that goes into the tubing
outerDiameter = tubeInnerDiameter - 0.5 * (2 * ridge);

// hollow part of the part of the plug that goes into the tubing.  0 would be a solid, should be smaller than the outer diameter
innerDiameter = 31.6;


// if the tubing is not vertical, use an angle here to build a plug with an angled base
angle = 0;

// if you are using an angle, this helps you control exactly where the plug is cut off to meet the floor
extra_height = 0;


nothing = 0.01;

difference() {
    translate([0, 0, extra_height])
        rotate([angle, 0, 0])
            // Cap base shape. Constructed top to bottom.
            union() {
                // Tube insert part.
                translate([0, 0, bottomHeight - nothing])
                    difference() {
                        cylinder(r = outerDiameter / 2, h = height);
                        translate ([0, 0, 0.3 * height]) 
                            cylinder(r = innerDiameter / 2, h = height + nothing) ;  
                    };
                    
                // Lead-in for press-fit ridges.
                for (i = [0 : ridgeCount]) {
                    rotate([0, 0, (360 / ridgeCount) * i])
                    translate([outerDiameter / 2, 0, bottomHeight + 0.8 * height - nothing])
                        cylinder(r1 = ridge, r2 = nothing, h = 0.2 * height);
                }
                    
                // Press-fit ridges.
                for (i = [0 : ridgeCount]) {
                    rotate([0, 0, (360 / ridgeCount) * i])
                    translate([outerDiameter / 2, 0, bottomHeight])
                        cylinder(r = ridge, h = 0.8 * height);
                }
                
                // Cylindrical cap part.
                translate([0, 0, bevel])
                    cylinder(r = bottomDiameter / 2, h = bottomHeight - bevel);
                    
                // Chamfered cap part.
                intersection() {
                    cylinder(r = bottomDiameter / 2, h = bottomHeight);
                    cylinder(r1 = bottomDiameter / 2 - bevel, r2 = bottomDiameter / 2, h = bevel);
                }
            }
    
    // Cutter to cut the cap buttom, due to the cap being inclined against the floor.
    translate([-bottomDiameter, -bottomDiameter, -bottomDiameter + nothing])
        cube([bottomDiameter * 2, bottomDiameter * 2, bottomDiameter]);
}
