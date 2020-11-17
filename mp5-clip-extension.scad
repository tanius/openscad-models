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

show_cross_section = false;

// How much to offset the strap mount relative to the original clips.
extension_length = 30;

// (3) REUSABLES
// ======================================================================


// (4) MEASURES
// ======================================================================

function maskmount_msr(id) = (
    id == "stem w"        ?  8.3 :
    id == "stem d"        ?  7.8 :
    id == "stem corner r" ?  1.4 :
    id == "stem h"        ?  3.0 : // Same as the height of the original clips.
    id == "cap w"         ? 12.5 :
    id == "cap d"         ? 11.5 :
    id == "cap corner r"  ?  3.0 : // Difficult to measure, but also not relevant for the design.
    id == "cap h"         ?  3.0 :
    undef
);

function strapmount_msr(id) = (
    id == "w"             ? 20.5 :
    id == "d"             ?  9.5 :
    id == "hole w"        ? 10.0 :
    id == "hole d"        ?  4.3 :
    id == "hole corner r" ?  1.0 :
    id == "hole offset d" ?  3.0 : // Depth position, from start of strap mount part.
    id == "ramp d"        ?  4.5 :
    id == "ramp offset d" ?  3.0 : // Depth position, from start of strap mount part.
    id == "h min"         ?  3.0 :
    id == "h max"         ?  5.5 :
    id == "triangle d"    ?  5.5 :
    id == "triangle w"    ?  3.0 :
    undef
);

function extension_msr(id) = (
    id == "d"              ? extension_length + 20: // @todo
    // The slot is narrower than the mask mountpoint's cap, as it is mounted by hooking in one side 
    // and then pushing the other down.
    id == "slot w1"        ?  9.5:
    // Stem width is 8.3 mm, and also the original clips have a 8.3 mm opening in mounted 
    // position. But the stem is rubber material and compressible, and we want a tight fit.
    id == "slot w2"        ?  8.0 :
    // Default corner radius.
    id == "corner r"       ?  1.5 :
    // Default edge radius.
    id == "edge r"         ?  1.0 :
    undef
);


// (6) PARTS
// ======================================================================

module lower_extension() {
    // Minimum corner radius.
    min_r = 0.3;

    // Format: [x, y, radius], each starting at the origin.
    outline_points = [
        [                  0,                  0, extension_msr("corner r")],
        [strapmount_msr("w"),                  0, extension_msr("corner r")],
        [strapmount_msr("w"), extension_msr("d"), extension_msr("corner r")],
        [                  0, extension_msr("d"), extension_msr("corner r")]
    ];
    block_points = [
        [                       0,                        0,                           min_r],
        [strapmount_msr("hole w"),                        0,                           min_r],
        [strapmount_msr("hole w"), strapmount_msr("hole d"), strapmount_msr("hole corner r")],
        [                       0, strapmount_msr("hole d"), strapmount_msr("hole corner r")],
    ];
    height_ramp_points = [
        [0, 0, 0],
        [strapmount_msr("w"), 0, 0],
        [strapmount_msr("w"), strapmount_msr("ramp d"), 0],
        [0, strapmount_msr("ramp d"), 0]
    ];

    difference() {
        union() {
            // Base shape.
            polyRoundExtrude(
                outline_points,
                length = maskmount_msr("stem h"),
                r1 = min_r,
                r2 = extension_msr("edge r"),
                fn = 8
            );

            // Block to attach to the hole in the mask's strap mount part.
            translate([
                (strapmount_msr("w") - strapmount_msr("hole w")) / 2, 
                extension_msr("d") - strapmount_msr("d") + strapmount_msr("hole offset d"), 
                maskmount_msr("stem h")
            ])
                polyRoundExtrude(
                    block_points,
                    length = strapmount_msr("h max"),
                    r1 = min_r,
                    r2 = -min_r,
                    fn = 8
                );

            // Part for the strap mount to rest on.
            // @todo
        }

        // @todo Cut the slot for attaching to the mask.
    }
}

module upper_extension() {
}


// (7) SCENE
// ======================================================================

module scene() {
    lower_extension();
    translate([0, 0, 25]) 
        upper_extension();
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
