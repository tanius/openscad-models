// @todo Add an option to generate the battery socket without the block for the terminals. Allows to 
//   create blind sockets, such as to secure battery packs for transportation, or to mount them in storage.

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


// (3) FIXED AND DERIVED MEASURES
// ======================================================================

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
    id == "battery snapper wide part total d" ? 6.5 : // On the battery.

    // Main measures on the battery socket.
    id == "w" ? 46.6 :
    id == "d" ? 77 :
    id == "side h" ? 14.8 :
    id == "corner radius w" ? 6.5 :
    id == "corner radius d" ? 9.2 :
    id == "outer edges r" ? 0.7 :
    
    // Middle section, which is a separate part of the original Milwaukee battery socket.
    id == "middle section h" ? 12.8 :
    id == "middle section w" ? m("w") - 2 * m("lock grooves offset w") - 2 * m("lock grooves w") :
    id == "middle section offset w" ? (m("w") - m("middle section w")) / 2 :
    id == "middle section undercut h" ? 3.3 :
    id == "middle section undercut d" ? 12.6 :
    id == "middle section backwall d min" ? 2.0 :
    id == "middle section backwall d max" ? 3.9 :
    id == "middle section edge r" ? 0.5 :
    
    // Raised block on top of the middle section part, forming the highest point of the battery socket.
    id == "ridge w" ? 3.9 :
    id == "ridge d" ? 33.3 :
    id == "ridge h" ? 3.7 :
    id == "ridge round sections d" ? 1.6 : 
    id == "ridge offset d" ? 21.4 :
    
    // Grooves on the left and right to mount the battery pack mechanically. Closer to the device than all other grooves.
    id == "mount grooves w" ? 3.7 :
    id == "mount grooves h" ? 6.9 :
    id == "mount grooves wall t" ? m("terminal grooves 1+3 offset w") - m("mount grooves w") :
    
    // The two grooves with the locking mechanism.
    id == "lock grooves w" ? 8.8 : // Full width, including lock block w.
    id == "lock grooves h" ? 3.8 :
    id == "lock grooves min d" ? 
        m("lock block back offset d") + m("battery play d") + m("battery snapper wide part total d") :
    id == "lock grooves offset w" ? 3.3 :
    
    // Snap mechanism inside the snapper grooves.
    id == "lock block w" ? 2.6 :
    id == "lock block total d" ? 15.2 :
    id == "lock block ramp d" ? 4.2 :
    id == "lock block back offset d" ? 24.2 :
    
    // The three grooves before, in between and after the terminal block. 1-3 from left to right.
    id == "terminal grooves w" ? 3.4 :
    id == "terminal grooves 1+3 offset w" ? 8.7 : // Measured from the closest side of each.
    id == "terminal grooves 1+3 d" ? m("middle section undercut d") :
    id == "terminal grooves 2 offset w" ? 19.5 :
    id == "terminal grooves 2 d" ? 19.1 :

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
  * @return true if the difference between the input numbers is less than 1×10¯¹⁰
  */
function equals(n1, n2) = (
    // echo("DEBUG: equals(): ", n1, " – ", n2, " = ", abs(n1 - n2)) // Enable for debugging
    abs(n1 - n2) < 1e-10
);


/** Convert a path of point deltas with radius into a list of points. For each point delta, the x resp. y component of the 
  * point is the sum of the delta_x resp. delta_y components of all preceding point deltas, and the radius component is unchanged.
  * @param deltas  Vector of point deltas, each delta having a format of [delta_x, delta_y, radius], where delta_x / delta_y is 
  *   the difference from the previous point in x resp. y direction and radius is the radius to create at that point in the path.
  * @param last_index  An index into deltas pointing to the last element to process. Optional, defaults to the maximum possible index.
  * @todo Contribute this function to the Round Anything library.
  */
function to_points(deltas, last_index) = let(
    i = last_index == undef ? len(deltas) - 1 : last_index
) (
    i == 0 ?
        [deltas[0]] :
        
        let(
            prev_points = to_points(deltas, i - 1),
            prev_point = prev_points[i - 1]
        )
        concat(
            prev_points,
            [[ // List of points with a single point inside.
                prev_point.x + deltas[i].x, 
                prev_point.y + deltas[i].y, 
                deltas[i][2]
            ]]
        )
);

assert(to_points([[1,1,1], [2,2,2], [3,3,3]], 0) == [[1, 1, 1]], "to_points() failed test 1");
assert(to_points([[1,1,1], [2,2,2], [3,3,3]], 1) == [[1, 1, 1], [3, 3, 2]], "to_points() failed test 2");
assert(to_points([[1,1,1], [2,2,2], [3,3,3]], 2) == [[1, 1, 1], [3, 3, 2], [6, 6, 3]], "to_points() failed test 3");
assert(to_points([[1,1,1], [2,2,2], [3,3,3]]   ) == [[1, 1, 1], [3, 3, 2], [6, 6, 3]], "to_points() failed test 4");


// (5) PARTS
// ======================================================================

/** @todo Modify the implementation to create the left half incl. half of the middle section, then use 
  *   mirrorPoints().
  */
module battery_socket_base() {
    // Points path, each point an offset from the preceding one. Format [x_offset, y_offset, corner_radius].
    left_deltas = [
        [m("mount grooves w"), 0, 0],
        [m("mount grooves wall t") + m("terminal grooves w"), 0, 0],
        [0, m("side h") - m("lock grooves h"), 0],
        [- m("lock grooves w"), 0, 0],
        [0, m("lock grooves h"), 0],
        [- m("lock grooves offset w"), 0, m("outer edges r")],
        [0, -(m("side h") - m("mount grooves h")), 0],
        [m("mount grooves w"), 0, 0]
    ];
    left_outline = to_points(left_deltas);
    
    middle_deltas = [
        [0, 0, 0],
        [m("middle section w"), 0, 0],
        [0, m("middle section h"), m("middle section edge r")],
        [-m("middle section w"), 0, m("middle section edge r")]
    ];
    middle_outline = to_points(middle_deltas);

    translate([0, m("d"), 0])
        rotate([90, 0, 0]) {
            // Left section.
            polyRoundExtrude(left_outline, length = m("d"), r1 = 0, r2 = 0, fn = 8);
            
            // Middle section.
            translate([m("middle section offset w"), 0, 0])
                polyRoundExtrude(middle_outline, length = m("d"), r1 = 0, r2 = 0, fn = 8);
            
            // Right section.
            translate([m("w"), 0, 0])
                mirror([1, 0, 0]) 
                    polyRoundExtrude(left_outline, length = m("d"), r1 = 0, r2 = 0, fn = 8);
        }
}


module battery_socket() {
    battery_socket_base();
    
    // @todo Add the back wall.
    // @todo Add blocks to fill the unused back part of the lock grooves.
    // @todo Add the lock mechanism blocks.
    // @todo Add the ridge block.
    // @todo Cut the terminal grooves.
    // @todo Cut the middle section undercut.
    // @todo Cut off the corner roundings at the front and back face.
    // @todo Cut the terminal holes.
}

// (6) SCENE
// ======================================================================

module scene() {
    battery_socket();
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
