/** @file 
  * @brief A utility library of more generally useful functions, from the current directory.
  * @details It might make sense to outsource this library into its own project once 
  *   it is mature enough. The filename is already prepared for that case.
  *
  * @todo Rename "path" to something else to be compatible with the BOSL library, where paths are 
  *   simply ordered sets of 2D or 3D points. Perhaps "deltapath" or "dpath". Or even split 
  *   between "dpath" for a simple delta path without radii and "dxpath" for one with radii or 
  *   other extensions. BOSL has "2dpath" and "3dpath", even though their naming is a bit 
  *   inconsistent. See: https://github.com/revarbat/BOSL/wiki/paths.scad . So maybe:
  *   "deltapath2d", "deltapath3d", "xdeltapath2d", "xdeltapath3d".
  * @todo Contribute the functions related to delta paths to the BOSL library. See:
  *   https://github.com/revarbat/BOSL/wiki/paths.scad
  */


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


/** @brief A countersunk hole for screws. Positioned at the origin, extending towards -z, head at top.
  * @param r1 Screw hole diameter.
  * @param h1 Screwhole depth including the space for the screw head.
  * @param r2 Screw head diameter.
  * @param h2 Screw head depth, that is, depth of the countersunk.
  * 
  * @credits caggius, at https://forum.openscad.org/Counter-sinking-screw-holes-tp32633p32637.html
  */
module countersunk_hole(dia1, h1, dia2, h2) {
      r1 = 0.5 * dia1;
      r2 = 0.5 * dia2;

       // Screw shaft.
      translate([0, 0, -h1])
          cylinder(r = r1, h = h1);

       // Screw head.
      translate([0, 0, -h2])
          cylinder(r1 = r1, r2 = r2, h = h2);
}
