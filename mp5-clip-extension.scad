/** @brief An extension for any of the six clips on a Polish MP-5 military gas mask / respirator. 
  *   Allows to wear the mask comfortably with larger heads by reducing the strap pressure.
  * 
  * @detail Each extension consists of an inner and an outer part (as seen when wearing the mask). 
  *   The inner part has a button hole shape to hook into the attachment point on the mask and a 
  *   straight block that reaches into the hole in the original part mounted to the strap. The outer 
  *   part covers the inner part. It reaches into the remainder of the button hole shape and 
  *   covers the attachment block at the other ends to prevent both mechanism from accidental 
  *   loosening. It is fixed to the lower part with a cable tie. The length of the extensions 
  *   is configurable.
  * 
  * @detail All dimensions are named as if the part connects a mask mountpoint in the front to a 
  *   strap mountpoint in the back, both attached to a flat table. The "natural orientation" in use 
  *   is not relevant, as we don't draw the part in use.
  */

// Up here to appear before any assert() and echo() in the parameters section.
// Narrow enough to fit into one line of output when the console is at minimum width.
echo("\n\n============ NEXT RUN ============");

// (1) INCLUDES
// ======================================================================

include<Round-Anything/polyround.scad>

// (2) PARAMETERS
// ======================================================================

// Degree of details in the output. Influences segments per degree, filleting quality etc..
quality = "fast preview"; // ["fast preview", "preview", "rendering", "final rendering"]

// What to render.
show = "both (apart)"; // ["upper", "lower", "both (apart)", "both (together)"]

create_cross_section = false;

// How much to offset the strap mount relative to the original clips.
extension_length = 30;

// (3) REUSABLES
// ======================================================================


// (4) MEASURES
// ======================================================================

// d for "dimension".
function d(id) = (
    id == "maskmount stem w"         ?  8.3 :
    id == "maskmount stem d"         ?  7.8 :
    id == "maskmount stem corner r"  ?  1.4 :
    id == "maskmount stem h"         ?  3.0 : // Same as the height of the original clips.
    id == "maskmount cap w"          ? 12.5 :
    id == "maskmount cap d"          ? 11.5 :
    id == "maskmount cap corner r"   ?  3.0 : // Difficult to measure, but also not relevant for the design.
    id == "maskmount cap h"          ?  3.0 :

    id == "strapmount w"             ? 20.5 :
    id == "strapmount d"             ?  9.5 :
    id == "strapmount offset d"      ? d("extension d") - d("strapmount d") :
    id == "strapmount hole w"        ? 10.0 :
    id == "strapmount hole d"        ?  4.3 :
    id == "strapmount hole corner r" ?  1.0 :
    id == "strapmount hole offset d" ?  3.0 : // Depth position, from start of strap mount part.
    id == "strapmount ramp d"        ?  4.5 :
    id == "strapmount ramp offset d" ?  3.0 : // Depth position, from start of strap mount part.
    id == "strapmount ramp h"        ? (d("strapmount max h") - d("strapmount min h")) / 2 :
    id == "strapmount min h"         ?  3.0 :
    id == "strapmount max h"         ?  5.5 :
    id == "strapmount triangle d"    ?  5.5 :
    id == "strapmount triangle w"    ?  3.0 :

    id == "extension w"              ? d("strapmount w") :
    id == "extension h"              ? d("maskmount stem h") :
    id == "extension d"              ? extension_length + 20 : // @todo
    // The slot is narrower than the mask mountpoint's cap, as it is mounted by hooking in one side 
    // and then pushing the other down.
    id == "extension slot w1"        ?  9.5 :
    // Stem width is 8.3 mm, and also the original clips have a 8.3 mm opening in mounted 
    // position. But the stem is rubber material and compressible, and we want a tight fit.
    id == "extension slot w2"        ?  8.0 :
    id == "extension edge r"         ?  0.7 : // Default edge radius.
    id == "extension min r"          ?  0.3 : // Minimum allowable edge radius.

    undef
);


// (6) PARTS
// ======================================================================

/** @brief Blocks that capture the outline of the strapmount part. One rectangular block that goes 
  *   through the strapmount hole, and two triangular blocks. Since this is a special-purpose part, 
  *   it is already positioned for mounting in *_extension_base().
  */
module strapmount_capture_blocks(extend_triangles = false) {
    sinkin_t = d("extension edge r"); // Measure to overcome the base shape edge radius.
    block_h = d("strapmount max h") / 2; // Block height above the extension base shape.
    r = d("extension min r"); // Default edge radius here.

    // @todo Subtract assembly tolerances from the hole block.
    hole_block = [
        [                     0,                      0,          r],
        [d("strapmount hole w"),                      0,          r],
        [d("strapmount hole w"), d("strapmount hole d"), d("strapmount hole corner r")],
        [                     0, d("strapmount hole d"), d("strapmount hole corner r")],
    ];

    // @todo Subtract assembly tolerances from the triangle blocks.
    left_triangle = [
        [d("strapmount triangle w"),                          0, r],
        [                         0, d("strapmount triangle d"), r],
        [                         0,                          0, r]
    ];
    left_extended_triangle = [
        [d("strapmount triangle w"), -sinkin_t, r],
        [d("strapmount triangle w"), 0, r],
        [                         0, d("strapmount triangle d"), r],
        [                         0, -sinkin_t, 0]
    ];
    right_triangle = [
        [d("strapmount triangle w"),                          0, r],
        [d("strapmount triangle w"), d("strapmount triangle d"), r],
        [                         0,                          0, r]
    ];
    right_extended_triangle = [
        [d("strapmount triangle w"), -sinkin_t, 0],
        [d("strapmount triangle w"), d("strapmount triangle d"), r],
        [                         0, 0, r],
        [                         0, -sinkin_t, r]
    ];

    // Central hole capture block.
    translate([
        (d("strapmount w") - d("strapmount hole w")) / 2, 
        d("strapmount offset d") + d("strapmount hole offset d"), 
        d("extension h")
    ])
        polyRoundExtrude(hole_block, length = block_h, r1 = r, r2 = -r, fn = 8);

    // Left triangle.
    translate([0, d("strapmount offset d"), d("extension h") - sinkin_t])
        polyRoundExtrude(extend_triangles ? left_extended_triangle : left_triangle, 
            length = block_h + sinkin_t, r1 = r, r2 = 0, fn = 8);

    // Right triangle.
    translate([d("extension w") - d("strapmount triangle w"), d("strapmount offset d"), d("extension h") - sinkin_t])
        polyRoundExtrude(extend_triangles ? right_extended_triangle : right_triangle, 
            length = block_h + sinkin_t, r1 = r, r2 = 0, fn = 8);
}

module upper_extension_base() {
    r = d("extension edge r");
    ramp_offset_d = d("strapmount offset d") + d("strapmount ramp offset d"); // Now from origin.

    // Main outline in the yz plane. A rectangle with a ramped section. Format: [y, z, radius].
    outline_points = [
        [                                     0,                                         0, r],
        [                      d("extension d"),                                         0, r],
        [                      d("extension d"), d("extension h") + d("strapmount ramp h"), r],
        [ramp_offset_d + d("strapmount ramp d"), d("extension h") + d("strapmount ramp h"), 0],
        [ramp_offset_d                         , d("extension h")                         , 0],
        [d("strapmount offset d")              , d("extension h")                         , d("extension min r")],
        [d("strapmount offset d")              , d("extension h") + d("strapmount max h") , r],
        [                                     0, d("extension h") + d("strapmount max h") , r]
    ];
    // @todo: assert() that the above point sets contain no "undef".

    // Base shape.
    rotate([90, 0, 90])
        polyRoundExtrude(
            outline_points,
            length = d("extension w"),
            r1 = d("extension edge r"),
            r2 = d("extension edge r"),
            fn = 8
        );
}

module upper_extension() {
    color("Chocolate")
        union() {
            // Base shape.
            upper_extension_base();

            // Block to attach to the hole in the mask's strap mount part.    
            strapmount_capture_blocks(extend_triangles = true);
        }

    // @todo Design the part to block the slot for the mask mountpoint in the lower extension.
    // @todo Design the part to capture the cap of the mask mountpoint.

    // @todo Cut places to mount two cable ties.
}

module lower_extension_base() {
    r = d("extension edge r");
    head_protection_r = d("extension h") + d("strapmount ramp h");
    ramp_offset_d = d("strapmount offset d") + d("strapmount ramp offset d"); // Now from origin.

    // Main outline in the yz plane. A rectangle with a ramped section. Format: [y, z, radius].
    outline_points = [
        [                                     0,                                         0, r],
        [                      d("extension d"),                                         0, head_protection_r],
        [                      d("extension d"), d("extension h") + d("strapmount ramp h"), r],
        [ramp_offset_d + d("strapmount ramp d"), d("extension h") + d("strapmount ramp h"), 0],
        [ramp_offset_d                         , d("extension h")                         , 0],
        [                                     0, d("extension h")                         , r]
    ];
    // @todo: assert() that the above point sets contain no "undef".

    // Base shape.
    rotate([90, 0, 90])
        polyRoundExtrude(
            outline_points,
            length = d("extension w"),
            r1 = d("extension edge r"),
            r2 = d("extension edge r"),
            fn = 8
        );
}

module lower_extension() {
    color("SteelBlue")
        difference() {
            union() {
                // Base shape.
                lower_extension_base();
                
                // Block to attach to the hole in the mask's strap mount part.
                strapmount_capture_blocks();
            }

            // @todo Cut the slot for the mask mountpoint.

            // @todo Cut places to mount two cable ties.
        }
}


// (7) SCENE
// ======================================================================

module scene() {
    intersection() {
        if (show == "upper")
            upper_extension();

        else if (show == "lower")
            lower_extension();

        else if (show == "both (apart)") {
            union() {
                translate([0, 0, 25])
                    mirror([0, 0, 1])
                        upper_extension();

                lower_extension();
            }
        }

        else if (show == "both (together)") {
            union() {
                translate([0, 0, 2 * d("extension h") + d("strapmount max h")])
                    mirror([0, 0, 1])
                        upper_extension();

                lower_extension();
            }
        }

        if (create_cross_section)
            translate([-200 + d("extension w") / 2, -100, -100])
                cube([200, 200, 200], center = false); // @todo Make the cube size parametric.
    }
}

// Entry point of geometry generation.
//
// A final union() guarantees printable, non-intersecting geometries even when the lazy unions 
// feature is no longer experimental and also applied to user modules (not the case as of version 
// 2020.09.18). See: http://forum.openscad.org/-tp27991.html .
if (quality == "final rendering")
    union()
        scene();
else
    scene();
