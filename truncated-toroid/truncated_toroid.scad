/** @brief A parametric module to generate a truncated toroid shape in OpenSCAD.
  * 
  * @detail The shape is basically that of a cheese wheel, utilizing two different radii: that of the 
  *   cheese wheel circumference and that of the arcs forming the side edges in a vertical cross-section.
  *   This shape can be used to cut parts from it that need different bending radii in vertical and horizontal 
  *   direction.
  */ 


// (1) PARAMETERS
// ======================================================================

// Render quality. Influences segments per degree for circular shapes.
quality = "fast preview"; // ["very fast preview", "fast preview", "preview", "rendering"]

// If to cut the shape in half to get a better look.
show_cross_section = false;

// Height of a cheese wheel like "truncated toroid" shape. [mm]
height = 100;

// Radius of the top and bottom flat surfaces of the cheese wheel shape. [mm]
top_radius = 120;

// Arc height of the circle arc used to create the side surface of the cheese wheel shape. [mm]
arc_height = 30;

// If you want a hollow cheese wheel shape. [mm]
make_hollow = true;

// Wall thickness of the cheese wheel shape. Only relevant when "make hollow" is checked. [mm]
wall_thickness = 10;


/* [Hidden] */

// Degrees per fragment of a circle.
$fa = (quality == "rendering") ? 1 :
      (quality == "preview") ? 3 : 
      (quality == "fast preview") ? 6 :
      (quality == "very fast preview") ? 12 : 12; // The OpenSCAD default.
      
// Minimum size of circle fragments, applied selectively where finer detail is desired. 
// (Default $fs is 2 in OpenSCAD.)
small_fs= (quality == "rendering") ? 0.25 :
      (quality == "preview") ? 1 : 
      (quality == "fast preview") ? 2 :
      (quality == "very fast preview") ? 2 : 2; // The OpenSCAD default.

// Small amount of overlap for unions and differences, to prevent z-fighting.
nothing = 0.01;


// (2) REUSABLES
// ======================================================================

/** @brief A 2D arc shape in the first quadrant, with the secant along the y axis.
  * @param secant  Length of the arc secant.
  * @param arc_h  Height of the arc. For arc_h = secant/2, the arc is a semi-circle. For 
  *   arc_h > secant_h, it is more than a semi-circle.
  * @return Single geometry.
  */
module arc(secant, arc_h) {
    // To calculate the radius for the specified arc, we need the formula for circle radius from arc 
    // width and height: r = h/2 + w²/(8*h). See: https://www.mathopenref.com/arcradius.html
    r = arc_h / 2 + ((secant * secant) / (8 * arc_h));
    
    // Move the arc left and down so that its secant secant starts at the origin.
    translate([-2 * r + arc_h, -r + secant / 2])
        difference() {
            translate([r, r]) // Circle in the first quadrant.
                // @todo For a large radius, the absolute segment width of the arc becomes much 
                //   larger than the segment width of the rotational extrusion, which uses a much 
                //   smaller radius. The angular error is the same though, so not very important to fix.
                circle(r = r);
            translate([-arc_h, 0]) 
                square(size = 2 * r, center = false);
        }
}


/** @brief Vertical 2D cross-section of a solid cheese wheel geometry.
  * @param h  Height of the disk. Also the length of the secant of the arc attached to the outside 
  *   of the disk.
  * @param flat_section_dr  The part of the object's radius conforming to the radius of the bottom 
  *   and top flat sections. May be 0.
  * @param arced_section_dr  The part of the object's radius that is the arc height of the arc 
  *   around its outside. May be 0.
  * @return Single geometry.
  */
module cheese_wheel_solid_crosssection(h, flat_section_dr, arced_section_dr) {
    // Central rectangle, if non-zero width.
    if (flat_section_dr != 0)
        translate([-flat_section_dr, 0])
            square(size = [2 * flat_section_dr, h], center = false); // No "+ nothing" z fighting fix needed here as we're in 2D.
    
    // Right arc, if non-zero width.
    if (arced_section_dr != 0)
        translate([flat_section_dr, 0, 0])
            arc(secant = h, arc_h = arced_section_dr);
    
    // Left arc, if non-zero width.
    if (arced_section_dr != 0)
        translate([-flat_section_dr, 0, 0])
            mirror([1, 0, 0]) // Mirror on yz plane.
                arc(secant = h, arc_h = arced_section_dr);
}


/** @brief Vertical 2D cross-section of an optionally hollow cheese wheel geometry.
  * @detail It results in much faster preview performance when you generate toroid shapes by 
  *   rotate_extrude()'ing what this module returns, rather than using difference() on an outer 
  *   and inner 3D object to create the same shape.
  * @param h  Height of the disk. Also the length of the secant of the arc attached to the outside 
  *   of the disk.
  * @param flat_section_dr  The part of the object's radius conforming to the radius of the bottom 
  *   and top flat sections. May be 0.
  * @param arced_section_dr  The part of the object's radius that is the arc height of the arc 
  *   around its outside. May be 0.
  * @param wall_t  Wall thickness of the hollow object's shell. Optional. If not given, a solid 
  *   object is generated.
  * @return Single geometry.
  */
module cheese_wheel_crosssection(h, flat_section_dr, arced_section_dr, wall_t) {    
    difference() {
        // Outer cross-section.
        cheese_wheel_solid_crosssection(
            h = h, flat_section_dr = flat_section_dr, arced_section_dr = arced_section_dr
        );
        
        // Inner cross-section to generate a hollow shape, if needed.
        if (!is_undef(wall_t))
            offset(delta = -wall_t)
                cheese_wheel_solid_crosssection(
                    h = h, flat_section_dr = flat_section_dr, arced_section_dr = arced_section_dr
                );
    }
}
    

/** @brief The shell of a cheese wheel shaped object, obtained by rotating an arc in 3D and centered 
  *   around the origin. Using different parameters to define the object but functionally 
  *   equivalent to cheese_wheel_2().
  * @param h  Height of the disk. Also the length of the secant of the arc attached to the outside 
  *   of the disk.
  * @param flat_section_dr  The part of the object's radius conforming to the radius of the bottom 
  *   and top flat sections. May be 0, which is the default.
  * @param arced_section_dr  The part of the object's radius that is the arc height of the arc 
  *   around its outside. May be 0, which is the default.
  * @param wall_t  Wall thickness of the hollow object's shell. Optional. If not given, a solid 
  *   object is generated.
  * @return Single geometry.
  */
module cheese_wheel_1(h, flat_section_dr = 0, arced_section_dr = 0, wall_t) {
    r = flat_section_dr + arced_section_dr;
    
    translate([0, 0, -h/2])
        difference() {
            rotate_extrude(convexity = 2)
                // rotate_extrude() can only extrude shapes limited to one quadrant. So we use a 
                // square to cut off half of the cheese wheel cross-section along its symmetry axis.
                intersection() {
                    cheese_wheel_crosssection(
                        h = h, flat_section_dr = flat_section_dr, 
                        arced_section_dr = arced_section_dr, wall_t = wall_t
                    );
                    square(size = [r + nothing, h + nothing], center = false);
                }
            }
}


/** @brief The shell of cheese wheel shaped object, obtained by rotating an arc in 3D and centered 
  *   around the origin. Using different parameters to define the object but functionally 
  *   equivalent to cheese_wheel_1().
  * @param r  Radius as used for the rotational extrusion: the distance of the arc's furthermost 
  *   point from the rotational axis.
  * @param flat_section_dr  Radius part used by the bottom and top flat sections. Equivalent to the 
  *   offset of the extruded arc from the rotational axis. May be 0, which is the default.
  * @param arc_r  Radius of the circle that generates the arc used for the rotational extrusion.
  * @param wall_t  Wall thickness of the hollow object's shell. Optional. If not given, a solid 
  *   object is generated.
  * @return Single geometry.
  */
module cheese_wheel_2(r, flat_section_dr = 0, arc_r, wall_t) {
    // By leaving flat_section_dr = 0, we have no central cylinder shape in the cheese wheel, so 
    // its total radius is the arc height.
    arced_section_dr = r - flat_section_dr;
    
    // We have to choose the cheese wheel height so that its arc radius becomes arc_r as specified.
    // We start from the forumula for circle radius from arc width and height as per 
    // https://www.mathopenref.com/arcradius.html:
    //        arc_r = arc_h / 2 + ((arc_w * arc_w) / (8 * arc_h))
    // In our case, arc_w = h, arc_h = arced_section_dr. It follows:
    //   <=>  arc_r = arced_section_dr / 2 + ((h * h) / (8 * arced_section_dr))
    // Now solve for h:
    //   <=>  arc_r - arced_section_dr / 2 = (h * h) / (8 * arced_section_dr)
    //   <=>  (arc_r - arced_section_dr / 2) * (8 * arced_section_dr) = h * h
    //   <=>  h = sqrt( (arc_r - arced_section_dr / 2) * (8 * arced_section_dr) )
    h = sqrt( (arc_r - arced_section_dr / 2) * (8 * arced_section_dr) );
    
    cheese_wheel_1(
        h = h, flat_section_dr = flat_section_dr, arced_section_dr = arced_section_dr, wall_t = wall_t
    );
}


// (3) SCENE
// ======================================================================

/** @brief Helper module to create a truncated toroid shape using the parameters provided to this script. */
module configured_cheese_wheel() {
    cheese_wheel_1(
        h = height, 
        flat_section_dr = top_radius, 
        arced_section_dr = arc_height, 
        wall_t = (make_hollow ? wall_thickness : undef)
    );
}


/** @brief Create and show the whole design. */
module scene() {
    if (show_cross_section) {
        intersection() {
            configured_cheese_wheel();
            
            // Big cuboid to remove half of the cheese wheel shape for a cross-section view.
            color("Gold") translate([-500, 0, -500]) cube([1000, 1000, 1000], center = false);
        }
    }
    else
        configured_cheese_wheel();
}


// Entry point of geometry generation.
scene();
