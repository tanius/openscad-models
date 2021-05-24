// Straightwall Bottle
//
// A parametric bottle-like container with straight walls and a screw top.
//
// Description:
//   A fully parametric screw-lid container / bottle container 
//   that has straight walls on the outside (means, no overhanging lid).
//   The inner shape can be bottle-like (with a narrower neck section) 
//   or purely cylindrical (resulting in thick walls). The initial 
//   parameter settings (cylindrical interior of 66 mm × 19 mm Ø) make 
//   this a protective case for a flat-top 18650 lithium-ion cell.
//
// Installation:
//   Place all files into the same directory and open this file 
//   in OpenSCAD. This way, it will find the required library 
//   "threads.scad" that is supplied together with this main file.
// 
// Project URL:
//   https://www.thingiverse.com/thing:3826892
// 
// Author:
//   tanius
//   https://www.thingiverse.com/tanius
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
// Detailed documentation:
//    See file README.md.

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
quality = "preview"; // ["fast preview", "preview", "final rendering"]
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
