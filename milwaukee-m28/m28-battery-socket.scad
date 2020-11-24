/** @brief Device-side connector for Milwaukee M28 and V28 powertool batteries.
  * @details This is exactly the geometry used for the connector on Milwaukee M28 powertools, with the only difference 
  *   that this has a socket only on one side and consists of one single part, not three.
  *
    * @todo Add a customizer parameter to generate the battery socket without the block for the terminals. Allows to 
  *   create blind sockets, such as to secure battery packs for transportation, or to mount them in storage.
  * @todo Add a customizer parameter to choose between creating a solid plastic piece (for a blind plate or similar) 
  *   and one with hollows for terminal clips and wires.
  */

// Up here to appear before any assert() and echo() in the parameters section.
echo("\n\n============ NEXT RUN ============");


// (1) INCLUDES
// ======================================================================

// Round Anything library from https://github.com/Irev-Dev/Round-Anything/
include<Round-Anything/polyround.scad>


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

// Small amount of overlap for unions and differences, to prevent z-fighting.
nothing = 0.01;


/** @brief Provide any measure (that we know of) about this design. This acts as a 
  *   central registry for measures to not clutter the global namespace. "m" for "measure".
  *   Most numbers can be adjusted, allowing customization beyond the rather simple parameters in 
  *   the OpenSCAD Customizer. All measures have been taken by measuring an original Milwaukee 
  *   battery connector on a powertool. Different from the original, we only model a connector 
  *   for inserting a battery from one side.
  * @param id  String identifier of the dimension to retrieve. Look into the source to see 
  *   which are available.
  * @todo Add the positions and dimensions of the battery terminal connectors.
  */
function m(id) = (
    // Measures on the battery.
    id == "battery play d" ? 2.7 : // When the battery is in the socket.
    id == "battery snapper wide part total d" ? 6.5 :
    id == "battery snapper d" ? 14.1 :

    // Main measures on the battery socket.
    id == "w" ? 46.6 :
    id == "d" ? 77 :
    id == "side h" ? 14.8 :
    id == "corner radius w" ? m("middle section offset w"): // @todo rename to "h edges radius w"
    id == "corner radius d" ? 7.0 : // @todo rename to "h edges radius d"
    id == "outer edges r" ? 0.7 :   // @todo rename to "d edges radius"
    id == "backwall d min" ? 2.0 :
    id == "backwall d max" ? 3.9 :
    id == "backwall d" ? (m("backwall d min") + m("backwall d max")) / 2 :
    
    // Middle section, which is a separate part of the original Milwaukee battery socket.
    id == "middle section h" ? 12.8 :
    id == "middle section w" ? m("w") - 2 * m("lock grooves offset w") - 2 * m("lock grooves w") :
    id == "middle section offset w" ? (m("w") - m("middle section w")) / 2 :
    id == "middle section undercut h" ? 3.3 :
    id == "middle section undercut d" ? 12.6 :
    id == "middle section edge r" ? 0.5 :
    
    // Raised block on top of the middle section part, forming the highest point of the battery socket.
    id == "ridge w" ? 3.9 :
    id == "ridge d" ? 33.3 :
    id == "ridge h" ? 3.7 :
    id == "ridge offset w" ? m("w") / 2 - m("ridge w") / 2 :
    id == "ridge offset d" ? 21.4 :
    id == "ridge arcs d" ? 1.6 : // Unused. We simplify to a semi-circle arc via a radius the height edges, see below.
    id == "ridge h edges r" ? m("ridge w") / 2 : // Maximum possible corner radius, yielding a semi-circle at the ends.
    
    // Grooves on the left and right to mount the battery pack mechanically. Closer to the device than all other grooves.
    id == "mount grooves w" ? 3.7 :
    id == "mount grooves h" ? 6.9 :
    id == "mount grooves wall t" ? m("terminal grooves 1+3 offset w") - m("mount grooves w") :
    
    // The two grooves with the locking mechanism.
    id == "lock grooves w" ? 8.8 : // Full width, including lock block w.
    id == "lock grooves h" ? 3.8 :
    id == "lock grooves min d" ? 
        m("lock block offset d") + m("lock block d") + m("battery play d") + m("battery snapper d") :
    id == "lock grooves offset w" ? 3.3 :
    id == "lock grooves offset h" ? m("side h") - m("lock grooves h") :
    
    // Snap mechanism inside the snapper grooves.
    id == "lock block w" ? 2.6 :
    id == "lock block d" ? 15.2 :
    id == "lock block ramp d" ? 4.2 : // As part of "lock block d".
    id == "lock block offset d" ? 9.0 :
    
    // The three grooves before, in between and after the terminal block. 1-3 from left to right.
    id == "terminal grooves w" ? 3.4 :
    id == "terminal grooves 1+3 offset w" ? 8.7 : // Measured from the side face closest to each groove.
    id == "terminal grooves 1+3 d" ? m("middle section undercut d") :
    id == "terminal grooves 2 offset w" ? 19.5 :
    id == "terminal grooves 2 d" ? 19.1 :
    
    // The holes for the electrical terminal connectors, and these connectors.
    // "Outer" measures refer to the chamfer outline, not to the actual hole.
    id == "terminal holes w" ? 1.3 :
    id == "terminal holes h" ? 7.0 :
    id == "terminal holes min d" ? 13.0 : // To accommodate the terminals, which protrude 13 mm out of the casing.
    id == "terminal holes chamfer t" ? 0.9 :
    id == "terminal holes chamfer d" ? 2.0 :
    id == "terminal holes outer w" ? m("terminal holes w") + 2 * m("terminal holes chamfer t") :
    id == "terminal holes outer h" ? m("terminal holes h") + 2 * m("terminal holes chamfer t") :
    id == "terminal holes 1 outer offset w" ? 14.4 + 0.5 : // Measured in leftmost position, +0.5 mm moves it to the center.
    id == "terminal holes 2 outer offset w" ? 23.8 + 0.5 :
    id == "terminal holes 3 outer offset w" ? 29.5 + 0.5 :
    id == "terminal holes outer offset h" ? 3.6 :

    undef
);
assert(
    equals(
        m("terminal grooves 1+3 offset w") + m("terminal grooves w"),
        m("lock grooves w") + m("lock grooves offset w")
    ), 
    "Groove widths and wall thicknesses do not match between upper and lower section."
);


// (4) REUSABLES
// ======================================================================

/** @brief Replacement for the "==" operator that ignores the imprecision of calculation with numbers in OpenSCAD, because all 
  *   numbers including literals like "10.1" are internally double precision reals. Useful in assert(), because otherwise 
  *   even something simple like assert(8.8 + 2.3 == 11.1) will not be asserted.
  * @param n1  First number to test for equality.
  * @param n2  Second number to test for equality.
  * @return true if the difference between the input numbers is less than 1×10¯¹⁰
  */
function equals(n1, n2) = (
    // echo("DEBUG: equals(): ", n1, " – ", n2, " = ", abs(n1 - n2)) // Enable for debugging
    abs(n1 - n2) < 1e-10
);


/** @brief Convert a relative path into an absolute path.
  * @detail A relative path is a vector starting with a corner [x, y, corner_radius] as the first element and having a series 
  *   of movements as the following elements. Each movement is an element [dx, dy, radius] of two deltas relative to the 
  *   previous path element and a corner radius at the target point of the movement. Paths can be interpreted as open paths or 
  *   (by assuming a last implicit movement back to the starting point) as closed paths / polygons. When interpreted as open 
  *   paths, the corner radius of the starting point has no meaning.
  *   When converting a relative path into an absolute path, the relative movements are resolved into absolute coordinates, but 
  *   the corner_radius spec is unchanged. So it is not a simple set of points afterwards, but still a path, as there can be 
  *   the corner_radius elements that specify curved sections.
  * @param path  A path. This is a vector starting with a point as first elements and having series of movements as the 
  *   following elements. Each movement is an element [dx, dy, radius] of two deltas relative to the previous path element 
  *   and a corner radius at the target point of the movement. Paths can be interpreted as open paths or (by assuming a 
  *   last implicit movement back to the starting point) as closed paths / polygons. When interpreted as open paths, the 
  *   corner radius of the starting point has no meaning.
  * @param last_index  An index into the path, pointing to the last element to process. Usually left out, in which case it 
  *   defaults to the highest possible index.
  * @todo Contribute this function to the Round Anything library.
  */
function abs_path(path, last_index) = (
    let(i = last_index == undef ? len(path) - 1 : last_index)
    
    // Recursion end case.
    i == 0 ? [path[0]] :
        
    // Recursion case.
    let(
        prev_points = abs_path(path, i - 1),
        prev_point = prev_points[i - 1]
    )
    concat(
        prev_points,
        [[ // A list of points with a single point inside.
            prev_point.x + path[i].x, 
            prev_point.y + path[i].y, 
            path[i][2]
        ]]
    )
);
assert(abs_path([[1,1,1], [2,2,2], [3,3,3]], 0) == [[1, 1, 1]],                       "abs_path() failed test 1");
assert(abs_path([[1,1,1], [2,2,2], [3,3,3]], 1) == [[1, 1, 1], [3, 3, 2]],            "abs_path() failed test 2");
assert(abs_path([[1,1,1], [2,2,2], [3,3,3]], 2) == [[1, 1, 1], [3, 3, 2], [6, 6, 3]], "abs_path() failed test 3");
assert(abs_path([[1,1,1], [2,2,2], [3,3,3]]   ) == [[1, 1, 1], [3, 3, 2], [6, 6, 3]], "abs_path() failed test 4");


/** @brief Shorthand function to create the points of a rounded polygon from a path. This enables to call 
  *   "polygon(polygon_points(left_lockblock_path))".
  * @param path  A path. This is a vector starting with a point as first elements and having series of movements as the 
  *   following elements. Each movement is an element [dx, dy, radius] of two deltas relative to the previous path element 
  *   and a corner radius at the target point of the movement.
  * @param fn  The number of curve fragments to generate for each radius. Optional; the default value is $fr of the current 
  *   context.
  * @return A vector of points [x, y] that can, for example, be handed to polygon().
  * @todo Remove the fn parameter. Instead use $fr or (if all radii are ≤2 mm) $frs. This is more in line with the usage 
  *   of $fa, which is for a similar purpose. Even better, calculate an approximate $fr equivalent here locally from the 
  *   $fa and $fs special variables, which gets rid of the need for the $fr and $frs special variables.
  */
function polygon_points(path, fn = $fr) = (
    polyRound(abs_path(path), fn)
);


/** @brief Shorthand module to create a rounded polygon from a path.
  * @param path  A path. This is a vector starting with a point as first elements and having series of movements as the 
  *   following elements. Each movement is an element [dx, dy, radius] of two deltas relative to the previous path element 
  *   and a corner radius at the target point of the movement.
  * @param fn  The number of curve fragments to generate for each radius. Optional; the default value is $fr of the current 
  *   context.
  */
module rounded_polygon(path, fn = $fr) {
    polygon(polygon_points(path, fn));
}


/** @brief A fillet in the first octant, with the 90° angle along the axis.
  * @param w  Width (x axis extension) of the fillet. This is the first radius to define the asymmetrical fillet.
  * @param d  Depth (y axis extension) of the fillet. This is the second radius to define the asymmetrical fillet.
  * @param d  Height (z axis extension) of the fillet.
  */
module asymmetrical_fillet(w, d, h) {
    difference() {
        cube([w, d, h]);
        
        translate([w, d, 0])
            scale([1, d / w, 1])
                cylinder(h = h, r = w);
    }
}


// (5) PARTS
// ======================================================================

/** Base shape of the battery socket, in its final position. */
module battery_socket_base() {
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


/** Back wall of the battery socket, in its final position. */
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


/** Ridge block at the top of the battery socket, in its final position. */
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


/** All blocks inside the lock grooves of the battery socket, in their final position. */
module lock_grooves_blocks() {
    
    /* All the blocks inside the left lock groove. Those in the right one are symmetrical to these. */
    module left_blocks() {
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
    
    translate([0, 0, m("lock grooves offset h")]) {
        left_blocks();
        translate([m("w"), 0, 0])  mirror([1, 0, 0])  left_blocks();
    }
}


/** Cutters for the terminal grooves of the battery socket, in their final position. */
module terminal_grooves() {
    translate([m("terminal grooves 1+3 offset w") + nothing, -nothing, -nothing])
        cube([m("terminal grooves w"), m("terminal grooves 1+3 d"), m("side h")]);
    
    translate([m("terminal grooves 2 offset w"), -nothing, -nothing])
        cube([m("terminal grooves w"), m("terminal grooves 2 d"), m("side h")]);
    
    translate([m("w") - m("terminal grooves 1+3 offset w") - m("terminal grooves w") - nothing, -nothing, -nothing])
        cube([m("terminal grooves w"), m("terminal grooves 1+3 d"), m("side h")]);
}


/** Cutter for the undercut under the terminals, in its final position. */
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


/** Device-side connector for Milwaukee M28 and V28 batteries. The main object of this file. */
module battery_socket() {
    difference() {
        union() {
            color("Chocolate") battery_socket_base();
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


// (6) SCENE
// ======================================================================

// Entry point of geometry generation.
//
// A final union() guarantees printable, non-intersecting geometries even when the lazy unions 
// feature is no longer experimental and also applied to user modules (not the case as of version 
// 2020.09.18). See: http://forum.openscad.org/-tp27991.html .
if (quality == "final rendering")
    union()
        battery_socket();
else
    battery_socket();
