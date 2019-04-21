// ClampedDeviceHolder.scad
// 
// Holder for an electronic device that mounts to a round clamp.


// (1) CONVENTIONS
// ======================================================================

// - Directions: left/right, top/bottom and front/back are as used 
//   naturally when looking at the x/z plane into positive y direction.
// - Thing orientation: place part in natural orientation (means, so that 
//   the above orientations apply to it.) It may have to be rotated for 
//   printing.
// - Thing position: The thing should be in the first octant ("only use 
//   positive coordinates"). Because that's the only practical universal 
//   convention for the origin.
// - Units: millimeters and 0-360 degrees only.
// - Abbreviations:
//   - w = width (local x coordinate)
//   - d = depth (local y coordinate)
//   - h = height (local z coordinate)
//   - r = radius
//   - t = wall thickness (can be any local coordinate; can be whole 
//     part thickness if part is a wall)
// - Variable names:
//   - Use one-word names for parts. This prevents confusing variable 
//     names that start with the same word.
//   - Call the whole geometry "thing" (inspired by Thiniverse).
// - Part initial position: create parts centered around their local origin 
//   (as that is "natural"). Means, use "center = true".
// - Part creation in x/y plane: Draw it so that as few rotations as 
//   possible bring it into its final alignment. For that, imagine the 
//   reverse: how to rotate the final object's part into the x/y plane.
// - Polygon points: Start with the one closes to the origin and then 
//   move CCW (mathematical spin direction, which is the shortest rotation 
//   transforming x to y axis).
// - Module content: create one part per modules, without a color and 
//   without moving or rotating it for assembly.
// - Avoid z-fighting for difference() by making the cutout larger. Hide 
//   z-fighting for union() by giving parts the same color. No need to 
//   avoid it here, as it's just a visual annoyance and not even hiding 
//   anything one would want to see in the preview.


// (2) PARAMETERS
// ======================================================================

// Global resolution.
// ----------------------------------------------------------------------

// Smallest facet size to generate. [mm]
$fs = 0.1;
// Largest angle to generate. [degrees]
$fa = 5;

// Electronic device.
// ----------------------------------------------------------------------

// Depth of electronic device to mount. [mm] (Exclude protruding keys, as there will be a cutout for them.)
device_d = 28;
// Width of electronic device to mount. [mm]
device_w = 60.5;

// Holder for the electronic device.
// ----------------------------------------------------------------------

// Additional width / height for loose fit. [mm]
holder_play = 3;
// Wall thickness of holder. [mm]
holder_t = 3.5;
// Width of holder (x dimension). [mm]
holder_w = device_w + holder_play + 2 * holder_t;
// Depth of holder (y dimension). [mm]
holder_d = device_d + holder_play + 2 * holder_t;
// Height of holder (z dimension). [mm]
holder_h = 80;
// Corner radius of the inner shell corners. [mm]
holder_corner_r_inner = 6;
// Corner radius of the outer shell corners. [mm]
holder_corner_r_outer = holder_corner_r_inner + holder_t;

// Wall thickness of the connectors between holer and mount cylinder. [mm]
support_t = 6;

// Clamp mount to which the thing can be connected.
// ----------------------------------------------------------------------

// Optimum radius of clamped parts. [mm] (Rather larger than smaller, as the octagon shape we need for printability may deform in the clamp slightly.)
mount_r = 27/2;
// Width of the clamp. [mm]
mount_w = 20;

// Cylinder (rather, octagon) that is clamped by the mount.
// ----------------------------------------------------------------------

// Circumradius of the clamped octagon. [mm]
mountee_r_outer = mount_r;
// Inradius of the clamped octagon. [mm]
mountee_r_inner = sin(67.5) * mountee_r_outer;
    // How this is calculated:
    // (1) Split the octagon into 16 idential triangles. One side of each 
    //     is the inradius ri, one side is the circumradius ro.
    // (2) Law of sines says: ri / ro = sin(67.5°) / sin(90°)
    // (3) It follows ri = sin(67.5°) / sin(90°) * ro = sin(67.5°) * ro

// Additional width of the clamped cylinder for an easy fit. [mm]
mountee_play = 2;
// Additional width of the clamped cylinder beyond the support connectors. [mm] (Must be positive to prevent z-fighting in the OpenSCAD preview.)
mountee_overhang = 0;
// Total width of the cylinder. [mm]
mountee_w = mount_w + mountee_play + 2 * support_t + 2 * mountee_overhang;
// Air gap between octagon and device holder. [mm]
mountee_gap = 8.5; // TODO: Better define as outer radius to device holder.
// Octagon edge length. [mm]
mountee_edge = 2 * mountee_r_inner * (sqrt(2) - 1);
    // As per https://de.wikipedia.org/wiki/Achteck#Formeln
// Unsupported portion of the octagon, up to start of bottom edge. [mm]
mountee_support_offset = (2 * mountee_r_inner - mountee_edge) / 2;

// Support connectors between device holder and clamped cylinder.
// ----------------------------------------------------------------------

// Depth (y) of the support connectors. [mm]
support_d = mountee_r_inner + mountee_edge / 2 + mountee_gap;
// Height (z) of the support connectors. [mm]
support_h = 2 * mountee_r_inner + support_d;
    // (…) is to create a 45° angle at the support, which is that far from the case.

// Thing total dimensions.
// ----------------------------------------------------------------------

// Bounding box width (x). [mm]
thing_w = holder_w;
// Bounding box depth (y). [mm]
thing_d = holder_d + mountee_gap + 2 * mountee_r_inner;
// Bounding box height (z). [mm]
thing_h = holder_h;

// Idiom to finish the parameters section.
// Prevents non-user-configurable parameters to show up on the form.
module unused() {}

// Fix for z-fighting (see https://en.wikipedia.org/wiki/Z-fighting ).
// z_peace is the chosen amount of overlap to "extend our cuts and 
// embed our joins" (see http://forum.openscad.org/id-tp20439p20460.html ).
peace = 1;


// (3) UTILITIES
// ======================================================================

// Bevelled Cube
// Parameters:
//   size: cube size
//   cr:   corner radius (if cr==0, a standar cube is built)
//   cres: Corner resolution (in points). cres=0 means flat corners
// Source:
//   bevel edge cube
//   Copyright © 2012 Juan Gonzalez-Gomez (Obijuan)
//   https://github.com/Obijuan/obiscad/blob/master/obiscad/bcube.scad
//   Licence: CC-BY-SA 3.0
module bcube(size, cr = 0, cres = 0) {
    // internal cube size
    bsize = size - 2 * [cr, cr, 0];

    // Get the (x,y) coorner coordinates in the first quadrant.
    x = bsize[0] / 2;
    y = bsize[1] / 2;

    // A corner radius of 0 means a standar cube.
    if (cr == 0)
        cube(bsize, center = true);
    else {
        // The height of minkowski object is double. So we cale by 0.5.
        scale([1, 1, 0.5]) {

            // center the minkowski object
            translate([-x, -y, 0]) {

                // build the beveled cube with minkowski()
                minkowski() {

                    // internal cube
                    cube(bsize, center = true);

                    // cylinder in the corner (first cuadrant)
                    translate([x, y, 0])
                        cylinder(r = cr, h = bsize[2], center = true, $fn = 4*(cres+1));
                }
            }
        }
    }
}

// triangle(), regular_polygon(), octagon(), octagon_prism()
// Source:
//   OpenSCAD Shapes Library (www.openscad.org)
//   https://github.com/openscad/MCAD/blob/master/regular_shapes.scad
//   Copyright (C) 2010-2011  Giles Bathgate, Elmo Mäntynen
//   License: GPL3 or later, LGPL 2.1 or later

module triangle(radius) {
    o = radius/2;		    // equivalent to radius*sin(30)
    a = radius*sqrt(3)/2;	// equivalent to radius*cos(30)
    polygon(points = [[-a,-o], [0,radius], [a,-o]], paths=[[0,1,2]]);
}

module regular_polygon(sides, radius) {
    function dia(r) = sqrt(pow(r*2,2)/2);  // sqrt((r*2^2)/2) if only we had an exponention op
    if(sides < 2) square([radius,0]);
    if(sides == 3) triangle(radius);
    if(sides == 4) square([dia(radius),dia(radius)],center=true);
    if(sides > 4) {
        angles = [ for (i = [0:sides-1]) i*(360/sides) ];
        coords = [ for (th=angles) [radius*cos(th), radius*sin(th)] ];
        polygon(coords);
    }
}

module octagon(radius) {
    regular_polygon(8, radius);
}

module octagon_prism(height, radius) {
    translate([0, 0, -height/2]) {
        linear_extrude(height = height) octagon(radius);
    }
}


// (3) PART GEOMETRIES
// ======================================================================

// Clamped octagon.
module mountee() {
    octagon_prism(height = mountee_w, radius = mountee_r_outer);
}

// Holder for the electronic device.
module holder() {
    difference() {
        // outer holder geometry
        bcube([holder_w, holder_d, holder_h], cr = holder_corner_r_outer, cres = 10);
    
        // inner holder geometry
        translate([0, 0, holder_t/2 + peace]) {
            bcube([holder_w - 2*holder_t, holder_d - 2*holder_t, holder_h - holder_t + peace], cr = holder_corner_r_inner, cres = 10);
        }
    }
}

// One of two identical support connectors between device holder and clamped cylinder.
module support_wall() {
    linear_extrude(height = support_t, center = true) {
        translate([-support_h/2, -support_d/2, 0]) { // center to origin
            polygon([
                [0, 0], 
                [support_h, 0], 
                [support_h, support_d], 
                [support_d, support_d]
            ]);
        }
    }
}


// (4) PART ASSEMBLY
// ======================================================================

module main() {
    union() {
        
        // Clamped octagon.
        translate([thing_w/2, thing_d - mountee_r_inner, thing_h - mountee_r_inner]) {
            rotate([0, 90, 0]) {
                edge_to_face = 360 / 8 / 2; // To rotate a face to the top.
                rotate([0, 0, edge_to_face]) {
                    color("blue") mountee();
                }
            }
        }

        // Support connectors: left, right.
        offset_x = mountee_w/2 - mountee_overhang - support_t/2;
        // offset_y = 2 * mountee_r_inner - mountee_edge/2;
        offset_y = support_d/2 + mountee_support_offset;
        translate([thing_w/2 - offset_x, thing_d - offset_y, thing_h - support_h/2]) {
            rotate([0, -90, 0]) {
                color("blue") support_wall();
            }
        }
        translate([thing_w/2 + offset_x, thing_d - offset_y, thing_h - support_h/2]) {
            rotate([0, -90, 0]) {
                color("blue") support_wall();
            }
        }

        // Device holder.
        translate([thing_w/2, holder_d/2, thing_h/2]) {
            color("yellow") holder();
        }
    }
}


// (5) MAIN PROGRAM
// ======================================================================

main();

octagon();
