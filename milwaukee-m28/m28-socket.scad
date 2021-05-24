/** @file 
  * @brief Device-side connector for Milwaukee M28 and V28 powertool batteries.
  * @details This is exactly the geometry used for the connector on Milwaukee M28 powertools, with the only difference 
  *   that this has a socket only on one side and consists of one single part, not three.
  *
  * @todo Add a quarter-circle radius or other type of ramp to the front of the locking groove 
  *   fill blocks.
  * @todo Add a Customizer parameter to generate the battery socket without the block for the terminals. Allows to 
  *   create blind sockets, such as to secure battery packs for transportation, or to mount them in storage.
  * @todo Add a Customizer parameter to choose between creating a solid plastic piece (for a blind plate or similar) 
  *   and one with hollows for terminal clips and wires. In the latter case, the part probably 
  *   has to be split in two halves that are then connected with screws.
  * @todo Add a Customizer parameter that will result in a design that can be printed without 
  *   supports. That is possible when the part stands on its front surface and has 45° "roofs" at 
  *   the top of the terminal grooves and middle section undercut and terminal holes. And by 
  *   starting the center ridge, lock grooves filler blocks and back wall with a 45° angle. And 
  *   also by using 45° chamfers on the four main corners instead of radii.
  *     But for mechanical stability, the part should be printed laying on the bottom or top 
  *   surface. The best option so far is to print the part 45° rotated, standing on an overhanging 
  *   angled back wall.
  * @todo Add a Customizer parameter to use inner voids to save plastic when printing with 100% 
  *    infill. In contrast to infill settings of the slicer, this allows to make those parts 
  *    massive that have to take the largest loads. Also the infill pattern can be optimized 
  *    for printability, for example a beecomb pattern at 45° so that it will be upright when 
  *    printing the part 45° rotated.
  */

// Up here to appear before any assert() and echo() in the parameters section.
echo("\n\n============ NEXT RUN ============");


// (1) INCLUDES
// ======================================================================
// Local includes from the current directory are indicated by a "./…" path.

// Round Anything library from https://github.com/Irev-Dev/Round-Anything/
include <Round-Anything/polyround.scad>

// A utility library of more generally useful functions.
include <./openscad-reusables.scad>

// Central registry for all M28 system related part dimensions.
include <./measures.scad>


// (2) CUSTOMIZER PARAMETERS
// ======================================================================

// Degree of details in the output. Influences segments per degree, filleting quality etc..
quality = "preview"; // ["fast preview", "preview", "rendering", "final rendering"]


// (3) FIXED AND DERIVED MEASURES
// ======================================================================

// Prevent anything following from showing up as Customizer parameters.
/* [Hidden] */

// Degrees per fragment of a circle.
$fa = (quality == "final rendering") ? 1 :
      (quality == "rendering") ? 3 : 
      (quality == "preview") ? 6 :
      (quality == "fast preview") ? 12 : 12; // The OpenSCAD default.
      
// Minimum size of circle fragments.
$fs = (quality == "final rendering") ? 0.1 :
      (quality == "rendering") ? 0.25 : 
      (quality == "preview") ? 0.5 :
      (quality == "fast preview") ? 2 : 2; // The OpenSCAD default.
     
// Fragment count in a radius or fillet element. Simply assumes that an average radius or fillet is 90°.
$fr = 360 / $fa / 4;

// Fragment count in a small (≤2 mm) radius or fillet element. Simply assumes that an average radius or fillet is 90°.
$frs = $fr / 2;

// The default part context for m() calls. Can be overridden via m(part = "…", "…").
$part = "socket";

// Small amount of overlap for unions and differences, to prevent z-fighting.
nothing = 0.01;


// (4) PARTS
// ======================================================================

/** @brief Device-side connector for Milwaukee M28 batteries. The main object of this file. */
module m28_socket() {

    /** @brief Base shape of the battery socket, in its final position. */
    module base() {
        // Left half outline path, as a starting point and relative movements [delta_x, delta_y, corner_radius].
        // The left path is by "nothing" wider than half the complete shape. This leads to overlap when combining the two halves, 
        // which is necessary here to prevent an additional volume in the final rendering.
        left_path = [ // Start point is the right top corner. Path follows CCW.
            [m("w") / 2 + nothing, m("middle section h"), 0],
            [-m("middle section w") / 2 - nothing, 0, m("middle section edge r")],
            [0, -m("middle section h") + m("lock grooves offset h"), 0],
            [- m("lock grooves w"), 0, 0 ],
            [0, m("lock grooves h"), 0],
            [- m("lock grooves offset w"), 0, m("outer edges r")],
            [0, -(m("side h") - m("mount grooves h")), 0],
            [m("mount grooves w"), 0, 0],
            [0, -m("mount grooves h"), 0],
            [(m("w") - 2 * m("mount grooves w")) / 2 + nothing, 0, 0]
        ];
        
        translate([0, m("d"), 0])
            rotate([90, 0, 0]) {
                // Left half.
                linear_extrude(height = m("d"), convexity = 5)
                    rounded_polygon(left_path, fn = $frs);
                
                // Right half, as a mirrored left half.
                translate([m("w"), 0, 0])
                    mirror([1, 0, 0])
                        linear_extrude(height = m("d"), convexity = 5) 
                            rounded_polygon(left_path, fn = $frs);
            }
    }


    /** @brief Back wall of the battery socket, in its final position. */
    module backwall() {
        // Backwall outline path, as a starting point and relative movements [delta_x, delta_y, corner_radius].
        path = [
            [m("mount grooves w"), 0, 0],
            [m("w") - 2 * m("mount grooves w"), 0, 0],
            [0, m("mount grooves h"), 0],
            [m("mount grooves w"), 0, 0],
            [0, m("side h") - m("mount grooves h"), m("outer edges r")],
            [-m("w"), 0, m("outer edges r")],
            [0, -(m("side h") - m("mount grooves h")), 0],
            [m("mount grooves w"), 0, 0]
        ];
        
        translate([0, m("d"), 0])
            rotate([90, 0, 0])
                linear_extrude(height = m("backwall d")) 
                    rounded_polygon(path, fn = $frs);
    }


    /** @brief Ridge block at the top of the battery socket, in its final position.
      * @todo Maybe use the BOSL slot() shape for this, see
      *   https://github.com/revarbat/BOSL/wiki/shapes.scad#slot
      */
    module ridge() {
        // Ridge outline path from the top, as a starting point and relative movements [delta_x, delta_y, corner_radius].
        path = [
            [0, 0, m("ridge h edges r")],
            [m("ridge w"), 0, m("ridge h edges r")],
            [0, m("ridge d"), m("ridge h edges r")],
            [-m("ridge w"), 0, m("ridge h edges r")]
        ];
        
        translate([m("ridge offset w"), m("ridge offset d"), m("middle section h") - nothing])
            linear_extrude(height = m("ridge h"))
                rounded_polygon(path, fn = $frs);
    }


    /* @brief All the blocks inside the left lock groove. Those in the right one are symmetrical to these. */
    module lock_grooves_left_blocks() {
        // Paths from the top, given by a starting point and relative movements [delta_x, delta_y, corner_radius].
        left_fillerblock_path = [
            [0, 0, 0],
            [m("lock grooves w"), 0, 0],
            [0, m("d") - m("lock grooves min d") - m("backwall d"), 0],
            [-m("lock grooves w"), 0, 0]
        ];
        left_lockblock_path = [
            [0, 0, 0],
            [m("lock block w"), m("lock block ramp d"), 0],
            [0, m("lock block d") - m("lock block ramp d"), 0],
            [-m("lock block w"), 0, 0]
        ];
        
        linear_extrude(height = m("lock grooves h")) {
            translate([m("lock grooves offset w"), m("lock grooves min d")])
                rounded_polygon(left_fillerblock_path);
            translate([m("lock grooves offset w"), m("lock block offset d")])
                rounded_polygon(left_lockblock_path);
        }
    }


    /** @brief All blocks inside the lock grooves of the battery socket, in their final position. */
    module lock_grooves_blocks() {
        translate([0, 0, m("lock grooves offset h")]) {
            lock_grooves_left_blocks();
            translate([m("w"), 0, 0])  mirror([1, 0, 0])  lock_grooves_left_blocks();
        }
    }


    /** @brief Cutters for the terminal grooves of the battery socket, in their final position. */
    module terminal_grooves() {
        translate([m("terminal grooves 1+3 offset w") + nothing, -nothing, -nothing])
            cube([m("terminal grooves w"), m("terminal grooves 1+3 d"), m("side h")]);
        
        translate([m("terminal grooves 2 offset w"), -nothing, -nothing])
            cube([m("terminal grooves w"), m("terminal grooves 2 d"), m("side h")]);
        
        translate([m("w") - m("terminal grooves 1+3 offset w") - m("terminal grooves w") - nothing, -nothing, -nothing])
            cube([m("terminal grooves w"), m("terminal grooves 1+3 d"), m("side h")]);
    }


    /** @brief Cutter for the undercut under the terminals, in its final position. */
    module middle_section_undercut() {
        translate([m("middle section offset w"), -nothing, -nothing])
            cube([m("middle section w"), m("middle section undercut d"), m("middle section undercut h")]);
    }


    /** @brief Cutter to cut off the front left corner with an asymmetrical fillet.
      * @todo Refactor so this can be called with the corner to cut, such as "left back".
      */
    module corner_cutter() {
        render() 
            asymmetrical_fillet(w = m("corner radius w"), d = m("corner radius d"), h = m("side h") + 2 * nothing);
    }
        

    /** @brief A hole to cut into the terminal for a connector. Positioned as if cut into the xz plane with [0,0] offset. 
      * @todo Refactor so this can be called with the number of the hole to generate.
      */
    module terminal_hole() {
        // Actual terminal hole.
        translate([m("terminal holes chamfer t"), 0, m("terminal holes chamfer t")])
            cube([m("terminal holes w"), m("terminal holes min d"), m("terminal holes h")]);
        
        // Chamfer around the hole.
        chamfer_scale = [m("terminal holes w") / m("terminal holes outer w"), m("terminal holes h") / m("terminal holes outer h")];
        translate([m("terminal holes outer w") / 2, 0, m("terminal holes outer h") / 2]) rotate([-90, 0, 0]) {
            linear_extrude(height = m("terminal holes chamfer t"), scale = chamfer_scale)
                square([m("terminal holes outer w"), m("terminal holes outer h")], center = true);
        }
    }


    // m28_socket() implementation.
    difference() {
        union() {
            color("Chocolate") base();
            color("Chocolate") backwall();
            color("SteelBlue") ridge();
            color("SteelBlue") lock_grooves_blocks();
        }
        
        terminal_grooves();
        middle_section_undercut();
        
        translate([-nothing, -nothing, -nothing])                                                     corner_cutter();
        translate([m("w") + nothing, -nothing, -nothing])         mirror([1, 0, 0])                   corner_cutter();
        translate([-nothing, m("d") + nothing, -nothing])         mirror([0, 1, 0])                   corner_cutter();
        translate([m("w") + nothing, m("d") + nothing, -nothing]) mirror([1, 0, 0]) mirror([0, 1, 0]) corner_cutter();
        
        translate([m("terminal holes 1 outer offset w"), -nothing, m("terminal holes outer offset h")]) terminal_hole();
        translate([m("terminal holes 2 outer offset w"), -nothing, m("terminal holes outer offset h")]) terminal_hole();
        translate([m("terminal holes 3 outer offset w"), -nothing, m("terminal holes outer offset h")]) terminal_hole();
    }
}


// (5) SCENE
// ======================================================================

// Entry point of geometry generation.
//
// A final union() guarantees printable, non-intersecting geometries even when the lazy unions 
// feature is no longer experimental and also applied to user modules (not the case as of version 
// 2020.09.18). See: http://forum.openscad.org/-tp27991.html .
//
// @todo Outsource this incl. documentation to openscad-reusables. Can be done with a module 
//   that takes "quality" and a parameter and internally does union() {children()} if needed.
if (quality == "final rendering")
    union()
        m28_socket();
else
    m28_socket();
