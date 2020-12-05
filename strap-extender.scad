/** @brief An extension for any of the six strap clips on a Polish MP-5 military respirator.
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
  *
  * @todo Add a README file, and fill in the content published on Thingiverse.
  * @todo Place the triangular pieces for the edges of the strap connector completely on the upper 
  *   part, as they are stabilized by the attached wall there. They would just break off at the 
  *   lower part.
  * @todo Change the format of point sets to define outlines so that the points are calculated from 
  *   the previous point plus a vector, as done once in this file already. This is more readable, and 
  *   also less redundanct as a measure is only added once and then affects all points following it.
  *   But, even better is to define the points offsets as a vector (also including the radius as third 
  *   component) and then to use the "var = [for …]" list comprehension to convert to a new vector of 
  *   polygon corner points by adding the first and second components only to the previous point.
  * @todo Add a cutout for the head of the cable tie.
  * @todo To better protect the extension against turning around on the maskmount, it is better 
  *   to give the upper extension a hook-shaped part to reach into the lower extension and below the 
  *   maskmount cap. To facilitate this, the upper part must either be able to slide back and forth 
  *   a bit, or it must end with the hook so that the hook can be turned into its position from above.
  * @todo Use three additional cutters to cut the large-radius overhangs for printability, preserving 
  *   the circle radius where it is less than 45° against vertical.
  * @todo Make the fn parameter to all polyRoundExtrude() calls depend on the chosen quality setting.
  *   Currently, fn = 8 is used in all calls, resulting in 8 segments each for the rounded edges 
  *   at the top and bottom. It does not affect the rendering of the rounded polygon supplied to it.
  */

// Up here to appear before any assert() and echo() in the parameters section.
// Narrow enough to fit into one line of output when the console is at minimum width.
echo("\n\n============ NEXT RUN ============");


// (1) INCLUDES
// ======================================================================

// Round Anything library from https://github.com/Irev-Dev/Round-Anything/
include<Round-Anything/polyround.scad>


// (2) CUSTOMIZER PARAMETERS
// ======================================================================

// Degree of details in the output. Influences segments per degree, filleting quality etc..
quality = "fast preview"; // ["fast preview", "preview", "rendering", "final rendering"]

show = "both (apart)"; // ["upper", "lower", "both (apart)", "both (together)"]

create_cross_section = false;

// How much to offset the strap mount relative to the original position. For comparison, the rubber band of the middle headstraps on the MP-5 respirator sizes 1-2 can be extended by about 90 mm per side at the most. 
extension_length = 35;


// (3) DERIVED PARAMETERS
// ======================================================================

// Prevent anything following from showing up as Customizer parameters.
/* [Hidden] */

// Small amount of overlap for unions and differences, to prevent z-fighting.
nothing = 0.01;

/** @brief Provide any measure (that we know of) about any part of this design. This acts as a 
  *   central registry for measures to not clutter the global namespace. "d" for "dimension".
  *   Most numbers can be adjusted, allowing customization beyond the rather simple parameters in 
  *   the OpenSCAD Customizer.
  * @param id  String identifier of the dimension to retrieve. Look into the source to see 
  *   which are available.
  */
function d(id) = (
    // Gap around any inserted part, to account for manufacturing and measuring tolerances.
    // @todo Instead of defining them in absolute terms, define a percentage. Then fix the current 
    //   usage, as currently multiples of this measure are used where needed.
    id == "gap"                       ? 0.15 :

    id == "maskmount stem w"          ? 8.3 :
    id == "maskmount stem d"          ? 7.8 :
    // Width of the triangle so "stem w" remains after cutting off corners using the "stem corner r".
    // This has been visually determined. Adapt when changing stem w. Since it is used for a cutter, 
    // it's better when the size is minimally too large than too small.
    id == "maskmount stem triangle w" ? d("maskmount stem w") * 1.235 :
    // Width of the triangle so "stem d" remains after cutting off corners using the "stem corner r".
    // Determined visually, see above how to handle this.
    id == "maskmount stem triangle d" ? d("maskmount stem d") * 1.195 :
    id == "maskmount stem corner r"   ? 1.4 :
    id == "maskmount stem h"          ? 3.0 : // Same as the height of the original clips.

    id == "maskmount cap w"           ? 12.5 :
    id == "maskmount cap d"           ? 11.5 :
    // Width of the triangle so "cap w" remains after cutting off corners using the "stem corner r".
    // Determined visually, see above how to handle this.
    id == "maskmount cap triangle w"  ? d("maskmount cap w") * 1.358 :
    // Width of the triangle so "cap d" remains after cutting off corners using the "stem corner r".
    // Determined visually, see above how to handle this.
    id == "maskmount cap triangle d"  ? d("maskmount cap d") * 1.260 :
    id == "maskmount cap overhang d"  ? (d("maskmount cap d") - d("maskmount stem d")) / 2 :
    id == "maskmount cap corner r"    ? 3.0 : // Difficult to measure, but also not relevant for the design.
    id == "maskmount cap h"           ? 3.0 :
    id == "maskmount cap undercut h"  ? 0.7 : // Overhanging section of the cap. Unused.
    id == "maskmount cap edge r"      ? d("maskmount cap h") * 0.85 :

    id == "strapmount w"              ? 20.5 :
    id == "strapmount d"              ? 9.5 :
    id == "strapmount offset d"       ? d("extension d") - d("strapmount d") :
    id == "strapmount hole w"         ? 10.0 :
    id == "strapmount hole d"         ? 4.3 :
    id == "strapmount hole corner r"  ? 1.0 :
    id == "strapmount hole offset d"  ? 3.0 : // Depth position, from start of strap mount part.
    id == "strapmount ramp d"         ? 4.5 :
    id == "strapmount ramp offset d"  ? 3.0 : // Depth position, from start of strap mount part.
    id == "strapmount ramp h"         ? (d("strapmount max h") - d("strapmount min h")) / 2 :
    id == "strapmount min h"          ? 3.0 :
    id == "strapmount max h"          ? 5.5 :
    id == "strapmount triangle d"     ? 5.5 :
    id == "strapmount triangle w"     ? 3.0 :

    id == "extension w"               ? d("strapmount w") :
    id == "extension h"               ? d("maskmount stem h") :
    // Total y dimension of the extension parts.
    //   In the original condition, the strapmount part were measured to start 11 mm behind the mask 
    //   mount stem part. So the total depth is composed of the distance to the mask mount stem part 
    //   (going through the slot), these 11 mm original strapmount offset, the intended additional 
    //   strapmount offset ("extension length"), and the section covering the strapmount parts.
    id == "extension d"               ? d("extension slot offset d") + 11 + extension_length + d("strapmount d") :
    // The slot is narrower than the mask mountpoint's cap, as it is mounted by hooking in one side 
    // and then pushing the other down.
    id == "extension slot w1"         ? 9.5 :
    // Stem width is 8.3 mm, and also the original clips have a 8.3 mm opening in mounted 
    // position. But the stem is rubber material and compressible, and we want a tight fit.
    id == "extension slot w2"         ? 8.0 :
    // To keep enough material in front of the slot, the amount used on the maskmount is a good orientation.
    id == "extension slot offset d"   ? d("maskmount stem d") :
    id == "extension edge r"          ? 0.7 : // Default edge radius.
    id == "extension min r"           ? 0.3 : // Minimum allowable edge radius.

    // @todo Rename all cabletie parameters to omit "extension".
    id == "extension cabletie cut d"  ? 5.0 : // Because 4.8 mm is a widespread cable tie width.
    // Default cut depth of the cable tie channel.
    id == "extension cabletie cut t"  ? 1.5 :
    // Cabletie bend radius, measured on the inside. A practical parametric default is provided.
    id == "extension cabletie bend r" ? d("extension cabletie cut d") / 2 - d("extension cabletie cut t") :
    // @todo Calculate a better cable tie mountpoint, namely in the center between the end of the 
    //   slot in the lower extension and the beginning of the strapmount enclosure.
    id == "extension cabletie mount d" ? d("strapmount offset d") - 3 * d("extension cabletie cut d") :

    undef
);


// (4) REUSABLES
// ======================================================================

/** Calculates the length of the tip cut off by adding a radius to a corner. 
  * @todo Since this is currently unused, move it to a utility library. */
function radius_cutoff(angle, r) = (
    let(
        // Source: Round-Anything API docs, at "See bellow for an even deeper dive", see 
        // https://kurthutten.com/blog/round-anything-api/
        tangent_length = r / tan(angle / 2),

        // Now we have a SAS triangle made from tangent_length an r, with a 90° angle 
        // between them. That lets us calculate the third side, which is the distance 
        // between the circle's center and the tip that is being cut off. Formula (with simplification for a 90° angle):
        // https://en.wikipedia.org/wiki/Solution_of_triangles#Two_sides_and_the_included_angle_given_(SAS)
        center_to_tip = sqrt(pow(r, 2) + pow(tangent_length, 2)),

        radius_cutoff = center_to_tip - r
    )
    radius_cutoff
);


// (5) PARTS
// ======================================================================

/** @brief Blocks that capture the outline of the strapmount part. One rectangular block that goes 
  *   through the strapmount hole, and two triangular blocks. Since this is a special-purpose part, 
  *   it is already positioned for mounting in *_extension_base().
  * @todo Make the implementation more compact by using delta lists for the points and only having 
  *   one list that is modified by mirroring and extending.
  */
module strapmount_capture_blocks(extend_triangles = false) {
    hole_w = d("strapmount hole w") - 2 * d("gap");
    hole_d = d("strapmount hole d") - 2 * d("gap");
    sinkin_t = d("extension edge r"); // Measure to overcome the base shape edge radius.
    block_h = d("strapmount max h") / 2; // Block height above the extension base shape.
    r = d("extension min r"); // Default edge radius here.

    hole_block = [
        [     0,      0,                             r],
        [hole_w,      0,                             r],
        [hole_w, hole_d, d("strapmount hole corner r")],
        [     0, hole_d, d("strapmount hole corner r")],
    ];

    // No d("gap") is removed from the inner edges of the triangle blocks, as an insert only needs 
    // one gap size as tolerance, here already provided around hole_block above.
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
        (d("strapmount w") - hole_w) / 2,
        d("strapmount offset d") + d("strapmount hole offset d") + d("gap"),
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

/** @brief Cutter element for the slot to go over the maskmount cap when attaching to the mask.
  *   Positioned ready for use.
  * @param h  Height of the slot shape.
  * @param shrink  Reduce all xy measures to keep this gap around the part, for easy inserting into a 
  *   slot created with shrink = 0.
  * @param edges  A vector defining how to shape the upper and lower edge. Available values for 
  *   each edge are "original", "radius" and "fillet". Example: ["radius", "fillet"].
  */
module slot(h, shrink = 0, edges) {
    corner_r = d("maskmount stem corner r"); // Default corner radius. Multiply as needed.
    r1_dir = edges[0] == "radius" ? 1 : -1;
    r2_dir = edges[1] == "radius" ? 1 : -1;
    r1 = edges[0] == "original" ? 0 : d("extension edge r");
    r2 = edges[1] == "original" ? 0 : d("extension edge r");
    min_d = d("maskmount stem d") + d("maskmount cap d");

    // Centered around the x axis and then mirrored, since the outline is symmetrical.
    // @todo Use d("maskmount stem triangle d") in this outline instead of d("maskmount stem d").
    half_outline = [
        [shrink, 0, corner_r],
        [d("maskmount stem d"), d("extension slot w2") / 2 - shrink, corner_r],
        [min_d - shrink, d("extension slot w1") / 2 - shrink, corner_r * 2],
        [min_d + d("extension slot w1") / 2 - shrink, 0, d("extension slot w1") / 2]
    ];
    outline = mirrorPoints(half_outline, rot = 0, endAttenuation = [1, 1]); // Mirror at x axis.

    translate([d("extension w") / 2, d("extension slot offset d"), 0])
        // y movement: "-d("maskmount stem corner r") * 1.19" to compensate for the depth lost by 
        // applying the radius. "shrink" to center the part within the available gap space.
        // @todo Calculate the depth loss properly. Factor 1.19 is determine visually for the MP-5 
        //   mask. The required function is available as radius_cutoff() above.
        translate([0, shrink - d("maskmount stem corner r") * 1.19, 0])
            rotate([0, 0, 90])
                polyRoundExtrude(outline, length = h, r1 = r1_dir * r1, r2 = r2_dir * r2, fn = 8);
}

/** @brief Top part of the MP-5 respirator clip mount on the mask itself.
  * @param h  Height of the part. Defaults to the natural height of the cap, but can be increased 
  *   to create a cutter.
  * @param orient  Where to point the top of the cap. "top" or "bottom".
  * @param grow  How much to grow the xy outline of the cap, from the center into all directions.
  */
module maskmount_cap(h = d("maskmount cap h"), orient = "top", grow = 0) {
    cap_corner_r = d("maskmount cap corner r");

    // Simplified compared to reality, as we do not model the arc at the back of the cap, 
    // instead creating a triangle with rounded corners that is large enough for the cap to fit in.
    cap_outline = [
        [                                        0,                                        0, cap_corner_r],
        [ d("maskmount cap triangle w") / 2 + grow, d("maskmount cap triangle d") + 2 * grow, cap_corner_r],
        [-d("maskmount cap triangle w") / 2 - grow, d("maskmount cap triangle d") + 2 * grow, cap_corner_r]
    ];

    // Cap size control shape, to determine the maskmount stem triangle w / d parameters visually.
    * translate([-d("maskmount cap w") / 2, 0, 0])
        color("Blue")
            square([d("maskmount cap w"), d("maskmount cap d")]);

    // Cap.
    r1 = orient == "top" ? d("maskmount cap edge r") : 0;
    r2 = orient == "top" ? 0 : d("maskmount cap edge r");
    translate([
        d("extension w") / 2, 
        -(d("maskmount cap triangle d") - d("maskmount cap d")) 
            + d("extension slot offset d") - d("maskmount cap overhang d") - grow, 
        0
    ])
        polyRoundExtrude(cap_outline, length = h, r1 = r1, r2 = r2, fn = 8);
}

/** @brief Stem part of the MP-5 respirator clip mount on the mask itself. Currently unused.
  */
module maskmount_stem(h = d("maskmount stem h")) {
    stem_corner_r = d("maskmount stem corner r");
    // Centered around the y axis since the outline is symmetrical. This simplifies moving it.
    stem_outline = [
        [                                  0,                              0, stem_corner_r],
        [ d("maskmount stem triangle w") / 2, d("maskmount stem triangle d"), stem_corner_r],
        [-d("maskmount stem triangle w") / 2, d("maskmount stem triangle d"), stem_corner_r]
    ];

    // Stem size control shape, to determine the "maskmount stem triangle w / d" parameters visually.
    * translate([-d("maskmount stem w") / 2, 0, 0])
        color("Red")
            square([d("maskmount stem w"), d("maskmount stem d")]);

    // Stem object.
    translate([
        0, 
        -(d("maskmount stem triangle d") - d("maskmount stem d")) + (d("maskmount cap d") - d("maskmount stem d")) / 2, 
        0
    ])
        polyRoundExtrude(stem_outline, length = h, r1 = 0, r2 = 0, fn = 8);
}

/** @brief U-shaped cutter for a cable tie channel.
  * @param d_offset  y axis position of the start of the cable tie channel. Defaults to 0.
  * @param cut_dw  Channel cut depth in the x direction.
  * @param cut_dh  Channel cut depth in the z direction.
  */
module cabletie_cutter(d_offset = 0, cut_dw = d("extension cabletie cut t"), cut_dh = d("extension cabletie cut t")) {
    edge_r = d("extension min r");
    bend_r = d("extension cabletie bend r");
    cut_w = d("extension w") + 2 * nothing;
    cut_d = d("extension cabletie cut d");
    cutter_h = d("extension w"); // Larger than needed, just to be generous.

    // Point, as offset from the previous.   // Point with added radius component.
    // @todo Convert to the new scheme of defining a single vectorof delta points.
    p1 =      [-nothing, -nothing];          p1r = concat(p1, 0);
    p2 = p1 + [cut_w, 0];                    p2r = concat(p2, 0);
    p3 = p2 + [0, cutter_h + nothing];       p3r = concat(p3, 0);
    p4 = p3 + [-cut_dw, 0, 0];               p4r = concat(p4, 0);
    p5 = p4 + [0, -cutter_h + cut_dh];       p5r = concat(p5, bend_r);
    p6 = p5 + [-(cut_w - 2 * cut_dw), 0];    p6r = concat(p6, bend_r);
    p7 = p6 + [0, -cut_dh + cutter_h];       p7r = concat(p7, 0);
    p8 = p7 + [-cut_dw, 0];                  p8r = concat(p8, 0);

    outline = [p1r, p2r, p3r, p4r, p5r, p6r, p7r, p8r];

    translate([0, cut_d + d_offset, 0])
        rotate([90, 0, 0])
            // @todo To improve the cut-out shape, add radii (r1 = edge_r, r2 = edge_r). However, 
            //   as that also sets the outer radii, the cutter thickness has to be increased beyond 
            //   what is sunk in for cutting, to not cut a shape that is widening at the bottom of 
            //   the cut.
            polyRoundExtrude(outline, length = cut_d, r1 = 0, r2 = 0, fn = 8);
}

module upper_extension_base() {
    min_h = d("extension h");
    ramp_h = min_h + d("strapmount ramp h");
    max_h = d("extension h") + d("strapmount max h");
    r = d("extension edge r");
    ramp_offset_d = d("strapmount offset d") + d("strapmount ramp offset d"); // Now from origin.

    // Main outline in the yz plane. Format: [y, z, radius].
    // @todo Convert this to the new scheme of delta points.
    // @todo (max_h - min_h) * 0.8 is a visually determined value to keep enough material above 
    //   the maskmount cap cutout. Calculate this more precisely as a minimum thickness of material 
    //   depending on the cap cutout depth. And use the d("…") for this parameter.
    outline_points = [
        [                                     0, (max_h - min_h) * 0.8,                min_h],
        [d("strapmount offset d") - min_h      ,             0,                    r],
        [                      d("extension d"),             0,               ramp_h],
        [                      d("extension d"),        ramp_h,                    r],
        [ramp_offset_d + d("strapmount ramp d"),        ramp_h,                    0],
        [ramp_offset_d                         ,         min_h,                    0],
        [d("strapmount offset d")              ,         min_h, d("extension min r")],
        [d("strapmount offset d")              ,         max_h,                    r],
        [                                     0,         max_h,                    r]
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
        difference() {
            union() {
                // Base shape.
                upper_extension_base();

                // Block to attach to the hole in the mask's strap mount part.    
                strapmount_capture_blocks(extend_triangles = true);

                // Add a solid block shaped to block the slot in the lower part.
                // It will be cut to size later, so that not everything is being blocked.
                // @todo  It would be nice to use a fillet at the lower edge. slot() can provide 
                //  that, but a tiny part of this at the front tip of the slot would not be removed 
                //  with the maskmount_cap() cutter later. So for now, no fillet.
                translate([0, 0, d("extension h") + d("strapmount max h") - nothing])
                    slot(h = d("extension h") + nothing, shrink = d("gap"), edges = ["radius", "original"]);
            }

            // Subtract a part to capture the cap of the mask mountpoint and to shape the slot blocker.
            cap_gap_d = d("gap") * 2; // z direction gap to account for tolerances.
            maskmount_cap_h = d("maskmount cap h") + d("extension h") + cap_gap_d + nothing;
            maskmount_cap_offset_h = d("extension h") + d("strapmount max h") + d("extension h") - maskmount_cap_h + 2 * nothing;
            translate([0, 0, maskmount_cap_offset_h])
                maskmount_cap(h = maskmount_cap_h, orient = "bottom", grow = d("gap") * 3);

            // Cut the cable tie mount.
            // @todo The current cut_dh calculation is wrong and only visually correct for the 
            //   current measures. It always cuts from the maximum part height, not from the 
            //   actual z height of the part's sloped surface at the position of the cabletie 
            //   cutter.
            cabletie_cutter(d_offset = d("extension cabletie mount d"), cut_dh = d("extension cabletie cut t") * 1.5);
        }
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

            // Cut the slot for the mask mountpoint.
            translate([0, 0, -nothing])
                slot(h = d("extension h") + 2 * nothing, edges = ["fillet", "fillet"]);

            // Cut the cable tie mount. Since the lower extension is thin, we only remove material 
            // from the sides to not weaken the material.
            cabletie_cutter(d_offset = d("extension cabletie mount d"), cut_dh = 0);
        }
}


// (6) SCENE
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
