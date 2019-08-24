// Parametric container with straight walls and a screw top
//
// Project URL:
//   https://www.thingiverse.com/thing:3826892
// 
// Author:
//   tanius (https://www.thingiverse.com/tanius)
//
// Licence:
//   Creative Commons Attribution 4.0 International
// 
// Based on:
// 1. "Tall threaded tube" by sej7278
//    http://www.thingiverse.com/thing:2175003
//    licenced under Creative Commons Attribution (CC-BY)
// 2. "Screw Top Containers" by pmoews
//    https://www.thingiverse.com/thing:455426
//    licenced under Creative Commons Attribution (CC-BY)
// 
// Installation:
//   Place all files into the same directory and open this file 
//   in OpenSCAD. This way, it will find the required library 
//   "threads.scad" that is supplied together with this main file.
//
// Todo:
// - Move comment content from the start of this file to a file 
//   README.md. That content would be copied to the Thingiverse 
//   form when publishing there, so should be aligned to its form 
//   fields.
// - Add a few pictures with example containers to the README, as the 
//   .stl export files will not be published in all cases (not on 
//   Github for example, as they are generated files).
// - Add a LICENCE.txt file with the right licence.
// - Publish the code on Github, and put the link here.
// - Make the Thingiverse Customizer app work for this design. For that, 
//   create a "compilation" script that will combine this file with 
//   threads.scad.
// - Fix that the continuous wall thickness at the neck is larger than 
//   wall_t, increasing the total outer diameter. This is because 
//   threads.scad does not make the radial extension of the thread 
//   accessible, and the current way of determining it in the code 
//   below is inaccurate. Either switch to a better thread library 
//   or fix the bug in threads.scad.
// - Decrease thread height of the external thread by a small amount 
//   (0.5 mm) to make sure the end stop is between lid opening and 
//   body neck, not leaving any gap there, and not resulting in 
//   any pressure that could damage the top wall. Note that thread_gap does 
//   not require decreasing thread height: with the gap centered around 
//   a thread turn, there will be some play upwards when the lid hits 
//   the body's neck. But that play is removed by screwing on some more.
// - Split the parameter wall_t for the minimum wall thickness into 
//   two: one for non-threaded walls, one for threaded walls. Because 
//   the latter are stabilized by the thread, they can be made thinner.
// - Output relevant measures (outer dimensions, thread pitch etc.) 
//   when they have been calculated.
// - Provide a parameter that allows a non-threaded part at the top of 
//   the neck section. This will allow to have sufficient lid height 
//   while avoiding too many turns to open and close the lid. It will 
//   also help with positioning to start screwing the lid on.
// - Other TODO items as found in the code.
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
//   them constants, safe to access from global scope without side effects. And 
//   in terms of software architecture, they are like the private variables of a 
//   an object, which are also used "globally" inside the class' code.
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

// What to render.
show = "both (opened)"; // ["body", "lid", "both (closed)", "both (opened)", "both (cross-section)"]

// Render quality. Fast preview does not render threads.
quality = "preview"; // ["fast preview", "preview", "final render"]
// Fragment number in a full circle. (Threads set their own number.)
$fn = (quality == "final rendering") ? 120 :
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
lid_h_percent = 30;

// Default wall thickness. Used for all walls, except the side walls when "inner dia widen" is unchecked. [mm]
wall_t = 1.8;

// Lid turns to close resp. open it. (Note: "2" is comfortable, as used on soda bottles.)
lid_turns = 4;

// Number of thread starts.
thread_starts = 1;

/* [Hidden] */
// ----------------------------------------------------------------------
// (This is a special section that OpenSCAD will not show in the 
// customizer. Used for derived parameters etc..)

outer_h = inner_h + 2*wall_t;

lid_h = outer_h * lid_h_percent/100;
echo("lid_h [mm] = ", lid_h);

body_h = outer_h - lid_h;

inner_min_r = inner_min_dia / 2;

// Angle between one thread-"V" flank and the orthogonal of the thread axis.
// Using 45° for printability.
thread_angle = 45;

thread_h = lid_h - wall_t;

thread_turns = lid_turns * thread_starts;

// Thread pitch, as expected by the threads.scad library.
// 
// Pitch as "axial travel per turn" is independent of the number of 
// thread starts: an additional thread start just generates another 
// parallel set of turns, "in the groove of an the existing turn", 
// so using the same pitch.
//   So normally we'd have to calculate it as "thread_h / lid_turns".
// However threads.scad has a bug and for multi-start threads 
// expects here only the portion of pitch that is in addition to the 
// pitch enforced by the other turns of the thread.
// 
// TODO Fix the threads.scad bug described above and then calculate 
// with "thread_h / lid_turns".
// TODO Generate a warning when the pitch is not small enough to 
// ensure proper fastening of the lid. For comparison, a commercial 
// soda bottle has 5 mm thread pitch.
thread_pitch = thread_h / thread_turns;
echo("real thread pitch [mm] = ", thread_h / lid_turns);

// TODO: This may not be totally exact as the thread grooves at the 
// start and end of the thread might miss the "flattened ridge" and 
// "flattened valley" parts of their thread profile. So for 5 nominal 
// thread turns, only 4.7 or something might be present.
thread_turn_h = thread_h / thread_turns;

// Depth of the thread grooves if the thread would have pointed ridges 
// and valleys.
// TODO: Document this calculation.
thread_t_sharp = (thread_turn_h / 2) / sin(thread_angle);

// Depth of the external and internal thread grooves in practice, as 
// they are not sharp. See h, h_fac1, h_fac2 in threads.scad.
thread_t_external = thread_t_sharp * 0.6625;
thread_t_internal = thread_t_sharp * 0.625;

delta_thread_t = thread_t_external - thread_t_internal;

// Radial air gap between inner and outer thread for printability.
// - Good fit on a 6 mm pitch, 30° flank angle thread: 1.25 mm
// - On a commercial soda bottle@ ~0.5 mm
// TODO Calculate a suitable value based on the amount of overlap 
// in the thread (see thread_t_*).
// TODO Create a warning when the required value will be hard to print 
// with standard settings (200-300 µm layer height) and recommend 
// better settings.
thread_gap = 0.7;

body_thread_inner_r = inner_min_r + wall_t;
// For metric ISO threads, the thread's outer diameter will be physically what can be measured on the bolt.
body_thread_outer_r = body_thread_inner_r + thread_t_external;

lid_thread_outer_r = body_thread_outer_r + thread_gap;

// Outer radius based on the components in the lid section, from inside out.
// 
// On delta_thread_t: It seems that the nominal diameter to be given to metric_thread() 
// for an internal thread is the outer diameter of an external thread 
// that can be screwed in with zero gap between thread turns. Now the 
// valley on an internal thread is a bit deeper than the ridge of an 
// external thread is high (and both are not pointed), leaving a small 
// gap. This gap is what we have to compensate for here with "+ delta_thread_t".
// Not sure if it's really simply this difference of thread depth to use, 
// but it is visually exact for the thread analyzed. Without this, the 
// wall would become thinner than wall_t.
// TODO: Once being sure that this explanation applies, rather make the 
// fix by converting from real to expected nominal thread diameter when 
// calling metric_thread() to generate the internal thread. And use the 
// real thread diameter elsewhere: lid_thread_outer_r = body_thread_outer_r + thread_gap + delta_thread_t;
outer_r = lid_thread_outer_r + delta_thread_t + wall_t;

// Radial width of chamfers around all non-threaded circular edges.
// (The threads generate their own chamfers via parameter "leadin".)
chamfer_t = wall_t * 0.6;

// Small amount of overlap for joins and extended cuts to prevent z-fighting.
nothing = 0.01;

//
// (3) UTILITY FUNCTIONS
// ======================================================================

// Cuboid cutters arranged in a circle.
//   radius: Circle radius on which to center the serration cutters.
//   cutters: Number of cutters to use.
//   cutter_w, cutter_d, cutter_h: Dimensions of one cuboid cutter, aligned 
//     with their x axis tangentially to the circle to cut into, and centered on the circle.
module serrate(radius, cutters, cutter_w, cutter_d, cutter_h) {
    for (i = [0 : cutters-1]) {
        translate ([radius*cos(i*(360/cutters)), radius*sin(i*(360/cutters)), 0])
            rotate([0, 0, i*(360/cutters)])
                cube([cutter_w, cutter_d, cutter_h], center=true);
    }
}
//
// (4) PART GEOMETRIES
// ======================================================================

// Solid shape of the cylindrical part of the body (without the threaded section)
module main_body_solid() {
    echo("container(): creating main container body: cylinder(r=", outer_r, "h=", body_h ,")");
    
    
    difference() {
        translate([0, 0, body_h/2])
            cylinder(r=outer_r, h=body_h, center=true);
            
        // Chamfer around the top (45°).
        translate([0, 0, -(chamfer_t/2) + body_h + nothing])
            difference() {
                cylinder(r=outer_r+nothing, h=chamfer_t, center=true);
                cylinder(r1=outer_r+nothing, r2=outer_r-chamfer_t, h=chamfer_t + 2*nothing, center=true);
            }
            
        // Chamfer around the bottom (45°).
        translate([0, 0, chamfer_t/2 - nothing])
            difference() {
                cylinder(r=outer_r+nothing, h=chamfer_t, center=true);
                cylinder(r1=outer_r-chamfer_t, r2=outer_r+nothing, h=chamfer_t + 2*nothing, center=true);
            }
    }
}


module body() {
    difference() {
        
        // Solid outer shape of the container.
        color("SteelBlue")
            union() {
                main_body_solid();
                
                // Threaded section, with thread.
                translate([0, 0, body_h - nothing])
                    metric_thread(diameter=2*body_thread_outer_r, pitch=thread_pitch, length=thread_h + nothing, n_starts=thread_starts, leadin=1, angle=thread_angle, test=thread_testmode);
            }

        // Cutout that makes the container hollow.
        color("Chocolate")
            union() {
                // Cylindrical cutout for the inside. This is everything if inner_dia_widen == false.
                translate([0, 0, inner_h/2 + wall_t + nothing])
                    cylinder(r=inner_min_r, h=inner_h, center=true);

                // Widen the cutout in the non-threaded section so that side walls are only wall_t thick.
                if (inner_dia_widen) {
                    inner_max_r = outer_r - wall_t;
                    delta_r = inner_max_r - inner_min_r;
                                    
                    // Main cutout, for the bottom (=non-threaded) section. 
                    max_r_cutout_h = body_h - 2*wall_t - delta_r;
                        // "- 2*wall_t" as this section has a bottom wall and its own top wall.
                        // "- delta_r" to make space for the inner 45° chamfer.
                    translate([0, 0, max_r_cutout_h / 2 + wall_t + nothing])
                        cylinder(r=inner_max_r, h=max_r_cutout_h, center=true);
                    
                    // Concical cutout for a ≤45° angle between narrower threaded and wider 
                    // non-threaded section. Needed for printability without support.
                    translate([0, 0, -delta_r/2 + body_h - wall_t])
                        cylinder(r1=inner_max_r, r2=inner_min_r, h=delta_r, center=true);

                }
            }
    }
}

// Solid base shape of the lid, incl. chamfers.
module lid_solid() {
    
    difference() {
        // Cylindrical base shape.
        translate([0, 0, lid_h/2])
            cylinder(r=outer_r, h=lid_h, center=true);
    
        // Chamfer around the top (45°).
        translate([0, 0, -(chamfer_t/2) + lid_h + nothing])
            difference() {
                cylinder(r=outer_r+nothing, h=chamfer_t, center=true);
                cylinder(r1=outer_r+nothing, r2=outer_r-chamfer_t, h=chamfer_t + 2*nothing, center=true);
            }
            
        // Chamfer around the bottom (45°).
        translate([0, 0, chamfer_t/2 - nothing])
            difference() {
                cylinder(r=outer_r+nothing, h=chamfer_t, center=true);
                cylinder(r1=outer_r-chamfer_t, r2=outer_r+nothing, h=chamfer_t + 2*nothing, center=true);
            }
    }
}

module lid() {
    difference() {
        
        color("SteelBlue")
            lid_solid();
        
        // Internal thread, drilled into the lid.
        leadin = (quality == "final rendering") ? 3 : 0; // Workaround for a bug in threads.scad that causes z-fighting in preview mode when applying this chamfer.
        // TODO The leadin setting seems to have no effect anymore.
        color("Chocolate")
            translate([0, 0, -nothing])
                metric_thread(diameter=2*lid_thread_outer_r, pitch=thread_pitch, length=thread_h + nothing, internal=true, n_starts=thread_starts, leadin=leadin, angle=thread_angle, test=thread_testmode);
        
        // Grip surface around the lid.
        color("Chocolate")
            translate([0, 0, lid_h/2])
                serrate(radius=outer_r, cutters=15, cutter_w=2, cutter_d=2, cutter_h=lid_h+2*nothing);
    }
}


//
// (5) ASSEMBLY
// ======================================================================

module main () {
    if (show == "body") {
        body();
    }
    else if (show == "lid") {
        translate([0, 0, lid_h])
            rotate([180, 0, 0])
                lid();
    }
    else if (show == "both (closed)") {
        body();
        translate([0, 0, body_h])
            lid();
    }
    else if (show == "both (opened)") {
        body();
        translate([0, 0, body_h + 2 * lid_h])
            lid();
    }
    else if (show == "both (cross-section)") {
        // Position the lid screwed in one turn. Useful to debug the thread gap.
        // TODO Make this work also for non-integer lid_turns values, by also 
        // rotating the lid by the fractional amount.
        raise_lid_h = thread_h - thread_turn_h;
        // raise_lid_h = thread_h + 2*nothing; // fully unscrewed
        // raise_lid_h = 0; // fully screwed on
        
        difference() {
            // Container with the lid unscrewed.
            union() {
                body();
                color("Tomato")
                    translate([0, 0, body_h + raise_lid_h])
                        lid();
            }
            
            // Big cuboid to remove half of the container for a cross-section view.
            translate([- (outer_r + nothing), 0, -nothing])
                cube([2 * (outer_r + nothing), outer_r + nothing, outer_h + raise_lid_h + 2*nothing], center=false);
        }
    }
}

main();
