/*
Knob Factory

Version 1.2

Published at https://www.thingiverse.com/thing:4708988

© 2012 Steve Cooley    ( http://sc-fa.com , http://beatseqr.com , http://hapticsynapses.com )
© 2021 Matthias Ansorg ( https://ma.juii.net )

Description
===========
A parametric OpenSCAD design that allows to generate all kinds of knobs. Examples: small knobs for potentiometer inputs; 
knobs for turning the extruder or an axis of the 3D printer manually; water spout knobs etc.. It's a good idea to print 
only the lower 5 mm at first and then abort the print, to test if the hole diamater fits well on the shaft or if the measures 
have to be tuned further.

Licence
=======
Knob Factory is licensed under a Creative Commons Attribution 3.0 Unported License according to 
the licence note found at https://www.thingiverse.com/thing:20513 . Based on a work at sc-fa.com. 
Permissions beyond the scope of this license may be available at http://sc-fa.com/blog/contact .
You can view the terms of the license here: http://creativecommons.org/licenses/by/3.0/

Version History
===============
1.2  2021-01-03  Option to generate knobs with stems. Major refactorings. Republished as remix on Thingiverse.
1.1  2012-04-12  Fixed the arrow indicator code to be more robust and easier to adjust parameters for.
1.0  2012-03-??  Initial release at https://www.thingiverse.com/thing:20513 .

Open Tasks
==========
* @todo Adjust $fn based on the quality parameter so that if ≥30 faces on the circumference are specified, the shape 
    will be made "round", using the current quality setting.
* @todo Change the assembly order so that the external indicator is not cut by the cone indents even if they cut to the very bottom.
* @todo Add a horizontal cylinder around the setscrew hole, providing sufficient thread length where thin stems walls don't.
* @todo Add support for melt-in nuts that can be used for the setscrew hole, as seen at https://www.thingiverse.com/thing:3475324
* @todo Provide an option to chamfer rather than round along the top, to allow printing without support when flipped over.
* @todo Refactor the top_rounding() module.
* @todo Make the top_rounding() operation faster. Everything else is already fast enough to navigate fluently in preview mode.
* @todo Add a printer_hole_scale parameter (or similar) to scale holes so that printing them offsets any printer calibration 
    error. This keeps local calibration issues separate form the shafthole_radius parameter, which is good for sharing configurations.
* @todo Add support for more shaft shapes (rectangular, gear shaped etc.).
* @todo Support knurling of the knob circumference.
* @todo Add support for cutouts that leave spokes between the hub and circumference.
* @todo Some more "@todo" items as available inside the source code.
* @todo Add a mode where the sphere and cone indents can be rendered, to get an idea how to adapt them if they do not cut anything.
*/


// (1) CUSTOMIZER PARAMETERS
// ======================================================================

/* [Basic Parameters] */
// ---------------------

// Degree of detail in the output to allow faster previews. Influences segments for a full circle. NOT IMPLEMENTED YET.
quality = "preview"; // ["fast preview", "preview", "rendering", "final rendering"]

// Top radius of the main (cylindrical or conical) shape. [mm]
knob_radius_top = 16;

// Bottom radius of the main (cylindrical or conical) shape. [mm]
knob_radius_bottom = 14;

// Height of the main (cylindrical or conical) knob shape, without the stem. [mm]
knob_height = 5;

// Number of faces on the circumference of the knob, as on a regular polygon. ≥30 means "round, using current quality setting".
knob_faces = 7;

// Radius (at the widest point) of the shaft to which the knob is mounted. [mm]
shafthole_radius = 2.65;

// Depth of the hole for the shaft. If the knob is stopped by something mounted to the shaft, you can be generous with this measure, allowing it to catch debris from mounting without stopping the knob before its final position. [mm]
shafthole_height = 12;

// Number of faces on the cylindrical edge of the shaft hole, allowing to create holes for square, hexagonal etc. shafts. ≥30 means "round, using current quality setting".
shafthole_faces = 20;

// How much to cut off to create a D-shaped shafthole cross-section. 0 to keep it round. [mm]
shafthole_cutoff_arc_height = 0.35;


/* [Stem (optional)] */
// --------------------

// Whether to place the knob on a stem to form a mushroom shape.
enable_stem = false;

// Radius of the stem. [mm]
stem_radius = 5;

// Height of the stem. [mm]
stem_height = 10;

// Number of faces on the cylindrical part of the stem. ≥30 means "round, using current quality setting".
stem_faces = 30;

// Height of the section where the stem radius adapts, as part of the stem height. [mm]
stem_transition_height = 5;

// Radius to which the stem radius adapts at the top of the stem. [mm]
stem_transition_radius = 8.8;


/* [Setscrew Hole (optional)] */
// -------------------------

// Create a hole for a set screw, as required by some potentiometer or motor shafts to have their knobs affixed.
enable_setscrew_hole = false;

// Radius of the set screw hole. [mm]
setscrew_hole_radius = 1.01;

// Height of the set screw hole's center over the base of the knob. [mm]
setscrew_hole_height = 4;

// Number of faces on the cylindrical edge of the set screw hole. ≥30 means "round, using current quality setting".
setscrew_hole_faces = 20;


/* [Top Rounding (optional)] */
// ---------------------------------

// Enable rounding of the top edge. (Other "top rounding *" parameters are only relevant if checked.)
enable_top_rounding = false;

// Radius to use for rounding teh top edge. [mm]
top_rounding_radius = 8;

// Cylinder faces to use for the cylinder having the rounded top edge. ≥30 means "round, using current quality setting".
top_rounding_faces = 30;


/* [Engraved Indicator (optional)] */
// -------------------------------

// Whether to create an engraved indicator arrow on the top surface, or not.
enable_engraved_indicator = false;

// Scale factor for the overall arrow size.
engraved_indicator_scale = 1.01;

// Scale factor for the arrow's head size.
engraved_indicator_head_scale = 2.1;

// Scale factor for the arrow's shaft size.
engraved_indicator_shaft_scale = 1.5;

// How much to move the arrow into its pointing direction. Positive or negative. [mm]
engraved_indicator_move_forward = 3.1;

// Engraving depth. [mm]
engraved_indicator_depth = 4.2;


/* [External Indicator (optional)] */
// ------------------------------

// Whether to create a dial, protruding from the bottom of the knob's circumference.
enable_external_indicator = false;

// Height of the dialhand, from the bottom of the knob body. [mm]
external_indicator_height = 11;

// Length of the dialhand protruding over the bottom radius of the knob main shape. [mm]
external_indicator_length = 3;


/* [Sphere Indents (optional)] */
// --------------------------------------

// Whether to create cutouts around the top edge or circumference using spheres (or rather regular polyhedra) arranged in a circle.
enable_sphere_indents = false;

// Number of indenting spheres.
sphere_indents_count = 7;

// Radius of the indenting spheres. [mm]
sphere_indents_radius = 3;

// Number of faces around the outer circumference of the indenting spheres. ≥30 means "round, using current quality setting".
sphere_indents_faces = 16;

// Distance of the indenting spheres' centers from the centerline of the knob. [mm]
sphere_indents_center_distance = 12;

// Maximum depth cut by the indenting spheres, measured from the top surface of the knob. [mm]
sphere_indents_cutdepth = 3;

// Rotation offset of all spheres. Allows to align the indentations with the indicator, setscrew or outer faces. [degrees]
sphere_indents_offset_angle = 0;


/* [Cone Indents (optional)] */
// ------------------------------------

// Whether to create cutouts around the top edge or circumference using cones or cylinders arranged in a circle. When using many narrow cylinders you can create a serrating effect for better grip on the circumference surface.
enable_cone_indents = false;

// Number of indenting cones.
cone_indents_count = 7;

// Number of faces around the outer circumference of the indenting cones. ≥30 means "round, using current quality setting".
cone_indents_faces = 30;

// Height of the indenting cones. [mm]
cone_indents_height = 5.1;

// Top radius of the indenting cones. [mm]
cone_indents_top_radius = 3.1;

// Bottom radius of the indenting cones. [mm]
cone_indents_bottom_radius = 7.2;

// Distance of the indenting cones' centerlines from the centerline of the knob. [mm]
cone_indents_center_distance = 16.1;

// Maximum depth cut by the indenting cones, measured from the top surface of the knob. [mm]
cone_indents_cutdepth = 5.1;

// Rotation offset of all cones. Allows to align the indentations with the indicator, setscrew or outer faces. [degrees]
cone_indents_offset_angle = 0;


// (2) FIXED AND DERIVED MEASURES
// ======================================================================

// Prevent anything following from showing up as Customizer parameters.
/* [Hidden] */

// Small amount of overlap for unions and differences, to prevent z-fighting.
nothing = 0.01;

// Degrees per fragment of a circle. Used only where users want round outlines by specifying ≥30 faces.
$fa =   
    (quality == "final rendering") ? 1 :
    (quality == "rendering") ? 3 : 
    (quality == "preview") ? 6 :
    (quality == "fast preview") ? 12 : 12; // The OpenSCAD default.
      
// Minimum size of circle fragments in mm.
$fs = 
    (quality == "final rendering") ? 0.1 :
    (quality == "rendering") ? 0.25 : 
    (quality == "preview") ? 0.5 :
    (quality == "fast preview") ? 2 : 2; // The OpenSCAD default.


// (3) MAIN MODULE
// ======================================================================

knob(); // Entry point of the program.


module knob() {
	difference() {
		difference() { 
            difference() {
				difference() {
					union() {
						translate([0, 0, enable_stem ? stem_height : 0]) {
                            difference() {
                                knob_base();
                                if (enable_top_rounding) top_rounding();
                            }
                            if (enable_external_indicator) external_indicator();
                        }
                        if (enable_stem) stem();
					}
					shafthole();
				}
				if (enable_setscrew_hole) setscrew_hole();
			}
			if (enable_engraved_indicator) engraved_indicator();
			if (enable_sphere_indents) sphere_indents();
            if (enable_cone_indents) cone_indents();
		}
	}
}


// (4) SUBMODULES
// ======================================================================

module knob_base() {
    // Align a face with the setscrew hole for aesthetic reasons, providing an arc above the setscrew hole in case of a round 
    // stem base and polygonal widening part of the stem. In OpenSCAD, polygons ("cylinders") are created so that a corner 
    // is placed on the +x axis. For uneven corner numbers, naturally a face is then centered around the -x axis. By rotating +90°, 
    // we move that face to be centered around the -y axis, where the setscrew hole has to be placed because it is the "back".
    rotate([0, 0, 90])
        // Knob base shape without any modifications or additions.
        cylinder(r1 = knob_radius_bottom, r2 = knob_radius_top, h = knob_height, $fn = knob_faces);
}

// @todo Calculate the convexity values based on the number of sphere and cone indents. Because a higher-than-necessary value 
//   hurts preview mode performance.
module top_rounding() {
    // Thanks to http://www.iheartrobotics.com/ for the articles that helped implement this.
    
    ct = -0.1;                          // circle translate? not sure.
    circle_radius = knob_radius_top;  	// just match the top edge radius
    circle_height = 1; 					// actually.. I don't know what this does.
    pad = 0.2;							// Padding to maintain manifold
    
    render(convexity = 5)
        translate([0, 0, knob_height])
            rotate([180, 0, 0])
                difference() {
                    rotate_extrude(convexity = 5, $fn = top_rounding_faces)
                        translate([circle_radius - ct - top_rounding_radius + pad, ct - pad, 0])
                            square(top_rounding_radius + pad, top_rounding_radius + pad);

                    rotate_extrude(convexity = 5, $fn = top_rounding_faces)
                        translate([circle_radius - ct - top_rounding_radius, ct + top_rounding_radius, 0])
                            circle(r = top_rounding_radius, $fn = top_rounding_faces);
                }
}


module stem() {
    // Straight basic stem.
    cylinder(h = stem_height + nothing, r = stem_radius, $fn = stem_faces);
    
    // Widening part at the top.
    rotate([0, 0, 90]) // To align a face with the setscrew hole; see knob_base().
        translate([0, 0, stem_height - stem_transition_height])
            cylinder(h = stem_transition_height, r1 = stem_radius, r2 = stem_transition_radius, $fn = knob_faces);
}


module shafthole() {
    difference() {
        // Create a round shafthole base shape.
        translate([0, 0, -1])
            cylinder(r = shafthole_radius, h = shafthole_height, $fn = shafthole_faces);
        
        // Adapt to a D-shaped shafthole if desired.
        if(shafthole_cutoff_arc_height != 0) {
            cutoff_size = [
                2 * shafthole_radius + 2 * nothing,
                shafthole_cutoff_arc_height + 2 * nothing,
                shafthole_height + 2 * nothing
            ];
            translate([-nothing, shafthole_cutoff_arc_height/2 - shafthole_radius - nothing, shafthole_height / 2]) 
                cube(cutoff_size, center = true);
        }
    }
}


module setscrew_hole() {
    hole_depth = max(knob_radius_top, knob_radius_bottom, stem_radius) + nothing;
    
    translate([0, -hole_depth / 2, setscrew_hole_height])
        rotate([90, 0, 0])
            cylinder(r = setscrew_hole_radius, h = hole_depth, center = true, $fn = setscrew_hole_faces);
}


// @todo Refactor the scaling algorithm and parameters to be more understandable. Default scale should be 1.
// @todo Fix that engraved_indicator_depth has not yet the desired effect because it is scaled with the rest of the arrow.
module engraved_indicator() {
    translate([0, engraved_indicator_move_forward, knob_height + (enable_stem ? stem_height : 0)])
        rotate([90, 0, 45])
            scale([engraved_indicator_scale * 0.3, engraved_indicator_scale * 0.3, engraved_indicator_scale * 0.3])
    
                union() {
                    rotate([90, 45, 0])
                        scale([engraved_indicator_head_scale, engraved_indicator_head_scale, 1])
                            // Arrowhead triangle as a cylinder with 3 faces.
                            cylinder(r = 8, h = engraved_indicator_depth * 2, $fn = 3, center = true);
                    rotate([90, 45, 0])
                        translate([-10, 0, 0])
                            scale([engraved_indicator_shaft_scale, engraved_indicator_shaft_scale, 1])
                                cube(size = [15, 10, engraved_indicator_depth * 2], center = true);
                }
}


module external_indicator() {
    // The diagonal of the square used as indicator is sqrt(2*knob_radius_bottom²). First we move it back from that 
    // most outward position to point at the center, then to point at the circumference of the knob, then to point out as specified.
    translate([0, -sqrt(2 * knob_radius_bottom * knob_radius_bottom) + knob_radius_bottom + external_indicator_length, 0])
        rotate([0, 0, 45])
            cube([knob_radius_bottom, knob_radius_bottom, external_indicator_height], center = false);
}


module sphere_indents() {
    z_position = sphere_indents_radius + (enable_stem ? stem_height : 0) + knob_height - sphere_indents_cutdepth;
    
    for (z = [0 : sphere_indents_count]) {
        // 90° base rotation angle to align the spheres with corners of the base shape. See knob_base().
        rotate([0, 0, 90 + sphere_indents_offset_angle + ((360 / sphere_indents_count) * z)])
            translate([sphere_indents_center_distance, 0, z_position])
                sphere(r = sphere_indents_radius, $fn = sphere_indents_faces); 
    }
}


module cone_indents() {
    height = cone_indents_height + 2 * nothing;
    z_position = height / 2 + (enable_stem ? stem_height : 0) + knob_height - cone_indents_cutdepth;
    
    for (z = [0 : cone_indents_count]) {
        // 90° base rotation angle to align the cones with corners of the base shape. See knob_base().
        rotate([0, 0, 90 + cone_indents_offset_angle + ((360 / cone_indents_count) * z)])
            translate([cone_indents_center_distance, 0, z_position - nothing])
                cylinder(
                    r1 = cone_indents_bottom_radius,
                    r2 = cone_indents_top_radius,
                    h = height,
                    center = true,
                    $fn = cone_indents_faces
                );
    }
}
