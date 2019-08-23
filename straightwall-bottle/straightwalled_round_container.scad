// Parametric round container with screw lid and straight walls
//
// Project URL:
//   [TODO]
// 
// Author:
//   tanius (https://www.thingiverse.com/tanius)
//
// Licence:
//   Creative Commons Attribution 4.0 International
// 
// Based on:
//   "Tall threaded tube" by sej7278
//   http://www.thingiverse.com/thing:2175003
//   licenced under Creative Commons Attribution (CC-BY)
// 
// Installation:
//   [TODO]
//
// Todo:
//   [TODO]
// 
// Code conventions:
// - Directions: left/right, top/bottom and front/back are as used 
//   naturally when looking at the x/z plane into positive y direction.
// - Thing orientation: place part in natural orientation (means, so that 
//   the above directions apply). It may have to be rotated for 
//   printing.
// - Thing position: The thing should be in the first octant ("only use 
//   positive coordinates"). Because that's the only practical universal 
//   convention for the origin, and it makes coordinates and part 
//   measurements idential. Exception: rotation symmetric parts should be 
//   centered around the positive half of one axis. This makes coordinates and 
//   radius related part measurements identical. The axis to center around is 
//   chosen depending on the natural orientation of the part (see above).
// - Units: millimeters and 0-360 degrees only.
// - Abbreviations:
//   - w = width (local x coordinate)
//   - d = depth (local y coordinate)
//   - h = height (local z coordinate)
//   - r = radius
//   - t = wall thickness (can be any local coordinate; can be whole 
//     part thickness if part is a wall)
// - Variable names:
//   - Use one-word names for parts. This prevents complicated multi-part variable 
//     names that start with the same word and then branch out.
//   - Call the whole geometry "thing" (inspired by Thiniverse).
// - Variable scope: Code meant to be re-usable must receive all input as module / 
//   function parameters. Other code may also access all global variables defined 
//   at the beginning of the .scad file (incl. those by OpenSCAD customizer). 
//   These are by convention never changed after initial assignment. This makes 
//   them constants, safe to access from global scope without side effects.
// - Code formatting: When chaining transformations, use {…} only when 
//   it applies to more than one commands. But always indent the commands 
//   that a chaining transformation applies to.
// - Part initial position: modules should create their parts in the first 
//   octant, with the bounding box starting at the origin. Means, use 
//   "center = false" when creating primitives. This leads to more 
//   intuitive translate() calls, avoiding the need to divide the whole 
//   calculation by two as in the case when objects start centered.
// - Part initial rotation: If the part is re-usable beyond the current 
//   thing, create it as if mounting it to the x/y plane. If the part 
//   is not re-usable, create it in the rotation needed for mounting it to 
//   the rest of the thing, because then that is the natural and only useful 
//   rotation of the part.
// - Part creation in x/y plane: Draw it so that as few rotations as 
//   possible bring it into its final alignment. For that, imagine the 
//   reverse: how to rotate the final object's part into the x/y plane.
// - Polygon points: Start with the one closes to the origin and then 
//   move CCW (mathematical spin direction, which is the shortest rotation 
//   transforming x to y axis).
// - Module content: create one part per module, without a color and 
//   without moving or rotating it for assembly.
// - Library choice: Try to use the MCAD library as much as possible. It is
//   the only library bundled by the OpenSCAD installer, so it can always 
//   be relied on without requiring the user to install anything first.
// - Avoid z-fighting for difference() by making the cutout larger, and 
//   avoid z-fighting for union() by making the parts overlap. Use the 
//   variable "nothing=0.01" for that (see below). Since union() 
//   z-fighting does not hide anything in preview mode and generates 
//   no errors when rendering, it is also ok to just hide these z-fighting 
//   artifacts visually by giving parts the same color.
// - Angles for printability: measure angles against vertical when discussing 
//   printability. Because the 45° rule for overhangs does so ("angles must be 
//   ≤45° to be printable on FDM printers").

//
// (1) INCLUDES
// ======================================================================

use <threads.scad>

//
// (2) PARAMETERS
// ======================================================================

/* [Render control] */
// ----------------------------------------------------------------------

// Which part to generate.
part = "body"; // ["lid", "body", "both"]

// Render quality. Fast preview does not render threads.
quality = "preview"; // ["fast preview", "preview", "final"]
// Fragment number in a full circle. (Threads set their own number.)
$fn = (quality == "final") ? 200 :
      (quality == "preview") ? 60 : 
      (quality == "fast preview") ? 30 : 30; // Same as the default $fa == 12.
thread_testmode = (quality == "fast preview") ? true : false;

/* [Measures] */
// ----------------------------------------------------------------------

// Inner height of the container (means, of the base; the lid adds zero inner height). [mm]
inner_h = 66;

// Smallest inner diameter of the container (means, at the opening). [mm]
inner_min_dia = 19;

// Widen the inner diameter below the threaded section as permitted by the configured minimum wall thickness.
inner_dia_widen = false;

// Lid height, as fraction of total outer height. [%]
lid_h_percent = 20;

// Minimum wall thickness. Used for threaded, top and bottom walls. [mm]
min_wall_t = 1.5;

// Lid turns to close resp. open it.
lid_turns = 3;

// Number of thread starts.
thread_starts = 1;

/* [Hidden] */
// ----------------------------------------------------------------------
// (This is a special section that OpenSCAD will not show in the 
// customizer. Used for derived parameters etc..)

outer_h = inner_h + 2*min_wall_t;

lid_h = outer_h * lid_h_percent;

inner_min_r = inner_min_dia / 2;

// Angle between on thread "V"'s flank and the orthogonal of the thread axis.
// Using 45° for printability.
thread_angle = 45;

thread_h = lid_h - min_wall_t;

thread_pitch = thread_h / lid_turns;

thread_grooves = lid_turns * thread_starts;

thread_groove_h = thread_h / thread_grooves;

// TODO: Document this calculation.
thread_r = (thread_groove_h / 2) / sin(thread_angle);

thread_gap_r = 1.25; // 1.25 mm radial gap between inner and outer thread gives a good fit.

// Outer radius based on the components in the lid section, from inside out.
outer_r = inner_min_r + min_wall_t + thread_r + thread_gap_r + min_wall_t;

//
// (3) UTILITY FUNCTIONS
// ======================================================================

// Cuboid cutters arranged in a circle.
//   radius: Circle radius on which to center the serration cutters.
//   segments: Number of segments, also the number of cutters to use.
module serrate(radius, segments, cube_x, cube_y, cube_z) {
    for (i = [0 : segments-1]) {
        translate ([radius*cos(i*(360/segments)), radius*sin(i*(360/segments)), 0])
            rotate([0, 0, i*(360/segments)])
                cube([cube_x, cube_y, cube_z], center=true);
    }
}
//
// (4) PART GEOMETRIES
// ======================================================================

module container() {
    difference() {
        
        // Solid outer shape of the container.
        union() {
            // Main container body, without threaded section.
            translate([0, 0, -37])
                cylinder(r=30, h=75, center=true);
            
            // Threaded section, with thread.
            english_thread(2, 4, 0.5, test=thread_testmode);
        }

        // Cutout that makes the container hollow.
        union() {
            // Slightly conical cutout for the opening. Could also be cylindrical.
            translate([0, 0, -20])
                cylinder(r1=27, r2=20, h=70, center=true);
            
            // Concical cutout for a 45° angle between narrower threaded and wider 
            // non-threaded section. Needed for printability without support.
            translate([0, 0, -7.7])
                cylinder(r1=27.1, r2=21.5, h=15, center=true);
            
            // Main cutout, for the bottom (=non-threaded) section.
            translate([0, 0, -45])
                cylinder(r=27, h=60, center=true);
        }
    }
}

module lid() {
    difference() {
        
        // Solid base shape of the lid.
        translate([0, 0, 7.5])
            cylinder(r=30, h=15, center=true);
        
        // Internal thread, incl. cutout into the lid.
        // Scaled to create a gap to the external thread on the container 
        // so that they move inside each other properly. Experience values:
        // - factor 1.02: fit is too tight
        // - factor 1.05: good for 50 mm thread inner diameter, too tight for 25 mm (2.5 mm gap)
        // - factor 1.1: good for 25 mm thread inner diameter, too loose for 50 mm (2.5 mm gap)
        scale([1.05, 1.05, 1])
            english_thread(2, 4, 0.5, internal=true, test=thread_testmode);
        
        // Grip surface around the lid.
        serrate(30, 15, 2, 2, 40);
    }
}


//
// (5) ASSEMBLY
// ======================================================================

module main () {
    if (part == "lid") {
        lid();
    }
    else if (part == "body") {
        container();
    }
    else if (part == "both") {
        translate([0,0,20]) lid();
        container();
    }
}

main();