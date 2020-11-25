/** @file 
  * @brief Blind plate for Milwaukee M28 batteries to protect the terminals against accidental 
  *   short-circuiting in transport.
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

// Battery socket, used as the base design for this design.
use <./m28-socket.scad>


// (2) CUSTOMIZER PARAMETERS
// ======================================================================

// Degree of details in the output. Influences segments per degree, filleting quality etc..
quality = "preview"; // ["fast preview", "preview", "rendering", "final rendering"]


// (3) FIXED AND DERIVED MEASURES
// ======================================================================

// Prevent anything following from showing up as Customizer parameters.
/* [Hidden] */

// Degrees per fragment of a circle.
$fa =   
    (quality == "final rendering") ? 1 :
    (quality == "rendering") ? 3 : 
    (quality == "preview") ? 6 :
    (quality == "fast preview") ? 12 : 12; // The OpenSCAD default.
      
// Minimum size of circle fragments.
$fs = 
    (quality == "final rendering") ? 0.1 :
    (quality == "rendering") ? 0.25 : 
    (quality == "preview") ? 0.5 :
    (quality == "fast preview") ? 2 : 2; // The OpenSCAD default.
     
// Fragment count in a radius or fillet element. Simply assumes that an average radius or fillet is 90°.
$fr = 360 / $fa / 4;

// Fragment count in a small (≤2 mm) radius or fillet element. Simply assumes that an average radius or fillet is 90°.
$frs = $fr / 2;

// The default part context for m() calls. Can be overridden via m(part = "…", "…").
$part = "isolator";

// Small amount of overlap for unions and differences, to prevent z-fighting.
nothing = 0.01;


// (4) PARTS
// ======================================================================

/** @brief Blind socket insert to protect the terminals of Milwaukee M28 batteries. 
  *    This is the main object of this file. */
module m28_isolator() {

    /** @brief A cover plate for the top of the battery. 
      * @todo Give it rounded corners and edges.
      * @todo Perhaps make the cover larger, to allow more secure stacking of batteries.
      * @todo Perhaps add stacking corners or stacking ridges to the cover, to enable more secure 
      *   battery stacking. This could also be another variant of the isolator, guided by a 
      *   Customizer parameter.
      */
    module cover() {
        // part == "device" && id == "back overhang d"
        // part == "device" && id == "front overhang d"
        // part == "device" && id == "side overhang w"
        let($part = "device")
            cube([m("base w"), m("base d"), m(part = "isolator", "cover h")]);
    }

    // m28_isolator() implementation.
    let($part = "device")
        translate([m("side overhang w"), m("front overhang d"), m(part = "isolator", "cover h") - nothing])
            // @todo Generate the socket in a more printer-friendly manner, once that is implemented.
            m28_socket();

    color("Chocolate") cover();

    // @todo Add a hole to remove the battery isolator with one finger.
}


// (5) SCENE
// ======================================================================

// Entry point of geometry generation.
//
// A final union() guarantees printable, non-intersecting geometries even when the lazy unions 
// feature is no longer experimental and also applied to user modules (not the case as of version 
// 2020.09.18). See: http://forum.openscad.org/-tp27991.html .
if (quality == "final rendering")
    union()
        m28_isolator();
else
    m28_isolator();
