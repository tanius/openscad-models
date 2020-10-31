// (1) INCLUDES
// ======================================================================

use <revolve2.scad>


// (2) PARAMETERS
// ======================================================================

/* [Render control] */
// ----------------------------------------------------------------------

// Render quality. Influences segments per degree for circular shapes.
quality = "fast preview"; // ["very fast preview", "fast preview", "preview", "rendering"]

scene_content = "both (cap opened)"; // ["body only", "cap only", "both (cap opened)", "both (cap closed one turn)", "both (cap closed)"]

show_cross_section = false;


/* [Measures] */
// ----------------------------------------------------------------------

SECTION_1_HEIGHT_MEASURES = "▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀";

// Default wall thickness. [mm]
wall_t = 1.8;

// Height of the cylindrical section containing the clip mount mechanism. [mm]
clip_section_h = 10;

// Angle between the two circles forming the conical section. [degrees]
cone_section_truncate_angle = 20;

// Height of the threaded section of the filter holder. [mm]
thread_section_h = 9;

// Height of the grid pattern's "lines". [mm]
grid_h = 2.7;

SECTION_2_RADIUS_MEASURES = "▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀";

// Radius between clip elements of the clip-mounted section, compatible with the respirator's exhale port cover clip-on mechanism. [mm] (Use 24.35 mm for the Polish MP-5 respirator, which is the measure from its original exhale port cover.)
clip_section_clip_r = 24.35;

// Inner radius of the clip-mounted section for the respirator's exhale port cover. Can be sized to allow push-fit connection with the original exhale port cover, after grinding out the clip-on mechanism. [mm] (Use 25.75 mm for the Polish MP-5 respirator to get a good press-fit already at the top half of the exhale port cover. Radius at the bottom is 25.85 mm.)
clip_section_inner_r = 25.75;

// Inside radius in the threaded section. [mm]
thread_section_inner_r = 35;

// Outside radius of the cap. Must accommodate the thread to be subtracted and still provide sufficient strength. [mm]
cap_outer_r = 42;

SECTION_3_OTHER_MEASURES = "▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀";

// Turns to close resp. open the cap. (For comparison, soda bottles use "2".)
cap_turns = 1.7;

// Radial gap between inner and outer thread. Must allow to fit in the filter material. [mm]
thread_gap = 0.9;


/* [Hidden] */
// ----------------------------------------------------------------------
// (This is a special section that OpenSCAD will not show in the customizer. Used for derived parameters etc..)

// Total height of the cap part.
cap_h = grid_h + thread_section_h;

// Thread pitch.
thread_pitch = thread_section_h / cap_turns;

// Basic shape of the thread, conforming to an ISO thread but with 45° instead of 60° flank angles for printability.
// Defined as if bolt core diameter is zero and thread period is 1 mm.
//
// TODO: Modify to use the shape of inner ISO threads.
// TODO: Find a more elegant, scalable way to define a thread type profile.
base_thread_profile = [
    [0,        0      ],
    [0.19863,  0      ],
    [0.53425,  0.33562],
    [0.66438,  0.33562],
    [1,        0      ]
];

// Fragment number in a full circle.
$fn = (quality == "rendering") ? 360 :
      (quality == "preview") ? 120 : 
      (quality == "fast preview") ? 60 :
      (quality == "very fast preview") ? 30 : 30;

// Small amount of overlap for unions and differences, to prevent z-fighting.
nothing = 0.01;


// (3) UTILITY FUNCTIONS
// ======================================================================

/**
 * @brief An open 3D object created by two circles with one point in common and an angle between them.
 *
 * @param r1  Outer radius of the shape's upper circle.
 * @param r2  Outer radius of the shape's lower circle.
 * @param angle  The angle betwen the upper and lower cirdle.
 * @param  wall_t  Thickness of the object's side walls.
 *
 * @todo The hull shape connecting the two circles does not have the same wall thickness everywhere, because 
 *   the wall thickness is defined via the non-orthogonal cross-sections where this shape meets with the two circles.
 * @todo The positioning of the inside hull seems wrong, as when doing it right one would have to drill two 
 *   cylindrical holes, not one.
 * @todo Rename to "tangential_tube_bend".
 * @todo Support using multiple circles to make the bend, not just two like now. This allows to create a curved bend, 
 *   when needed.
 */
module tangential_circle_hull(r1, r2, angle, wall_t) {
    // For positioning everything in the first octant, we need to know the largest measure.
    larger_r = max(r1, r2);
    
    difference() {
        // Hull requires real 3D shapes to work with. We use very flat cylinders.
        hull() { 
            // rotate-translate to rotate about an axis parallel to y, through (-r1,0,0) and (-r1,1,0).
            translate([-larger_r, 0, 0]) rotate([0, -angle, 0]) translate([r1, 0, 0])
                cylinder(h = 0.01, r = r1, center = false);
            
            cylinder(h = 0.01, r = r2, center = false);
        }
        
        // Inner cutout to make it hollow, keeping one wall thickness all around except at the bottom.
        hull() {
            // rotate-translate to rotate about an axis parallel to y, through (-r1-wall_t,0,0) and (-r1-wall_t,1,0).
            translate([-larger_r + wall_t, 0, nothing]) rotate([0, -angle, 0]) translate([r1 - wall_t, 0, 0])
                    cylinder(h = 0.01, r = r1 - wall_t, center = false);
            
            translate([0, 0, -nothing])
                cylinder(h = 0.01, r = r2 - wall_t, center = false);
        }
        
        // Cylindrical hole to connect to the clip section. Based on a circle centered inside the one at the outside of the hull.
        // rotate-translate to rotate about an axis parallel to y, through (-r1,0,0) and (-r1,1,0).
        translate([-larger_r - nothing, 0, 0]) rotate([0, -angle, 0]) translate([r1, 0, -wall_t - nothing])
            cylinder(h = wall_t + 2 * nothing, r = r1 - wall_t, center = false);
    }
}

/**
 * @brief Create a 2D chamfered rectangle in the first quadrant (positive x, positive y).
 *
 * @param w  Width of the rectangle in 2D (x dimension).
 * @param h  Height of the rectangle in 2D (y dimension).
 * @param chamfers  Width and height of a 45° chamfer. Either a number (applied to all corners), or a list of four numbers, applied 
 *   to the bottom left, bottom right, top right, top left corner, in that order.
 */
module chamfered_rectangle(w, h, chamfers) {
    chamfers_list = is_num(chamfers) ? [chamfers, chamfers, chamfers, chamfers] : chamfers;
    
    echo("Chamfer definitions: ", chamfers_list);
    
    // Points are defined CCW order as usual.
    points = [
        [chamfers_list[0],     0                   ],
        [w - chamfers_list[1], 0                   ],
        [w,                    chamfers_list[1]    ],
        [w,                    h - chamfers_list[2]],
        [w - chamfers_list[2], h                   ],
        [chamfers_list[3],     h                   ],
        [0,                    h - chamfers_list[3]],
        [0,                    chamfers_list[0]    ]
    ];
        
    polygon(points);
}


/**
 * @brief Chamfered cuboid elements between an inner and outer radius, arranged to cut that ring into same-sized segments.
 *
 * @param segments  The number of segments to create.
 * @param inner_r  Inner radius of the ring to cut into segments. Limits the depth of the cuboid elements.
 * @param outer_r  Outer radius of the ring to cut into segments. Limits the depth of the cuboid elements.
 * @param w  Width of the cuboid elements.
 * @param h  Height of the cuboid elements.
 */
module ring_segment_lines(segments, inner_r, outer_r, w, h) {    
    for (i = [0 : segments - 1]) {
        rotate([0, 0, i * (360 / segments)])
            translate([-w / 2, inner_r, h])
                rotate([-90, 0, 0]) 
                    linear_extrude(height = outer_r - inner_r, center = false)
                        chamfered_rectangle(w = w, h = h, chamfers = 0.25 * w);
    }
}

/**
 * @brief Grid pattern with circular lines and segment lines, all of which with small chamfers.
 *
 * @param segment_counts  Vector of segments per grid shell, counting from the innermost one. Also defines the number of shells to create.
 * @param h  Height of the resulting grid. All created elements share that height.
 * @param r  Outer radius of the resulting grid.
 * @param spacer_t  Measure of the "lines" separating the grid cells. Used both for the radial and circular lines.
 */
module circular_grid(segment_counts, h, r, spacer_t) {
    shell_count = len(segment_counts);
    all_shells_dr = r - shell_count * spacer_t; // Radial extent of all shells when excluding the spacers.
    shell_dr = all_shells_dr / shell_count; // Radial extent of one shell, excluding its spacer.

    for (shell = [1 : shell_count]) {
        shell_idx = shell - 1;
        ring_inner_r = shell * (shell_dr + spacer_t) - spacer_t;
        
        // The segment cutters for this shell.
        ring_segment_lines(
            segments = segment_counts[shell_idx],
            // The "0.4 * spacer_t" below is to provide a good amount of overlap with the circular lines, for proper union().
            inner_r = (shell - 1) * (shell_dr + spacer_t) - 0.4 * spacer_t,
            outer_r = (shell - 1) * (shell_dr + spacer_t) + shell_dr + 0.4 * spacer_t,
            w = spacer_t,
            h = h
        );
        
        // The ring around the segment cutters.
        rotate_extrude()
            translate([ring_inner_r, 0])
                chamfered_rectangle(w = spacer_t, h = h, chamfers = 0.25 * spacer_t);
    }
}


// (4) PART GEOMETRIES
// ======================================================================
// (Defined from top to bottom as shown in the initial view.)

/**
 * @brief A single clip of 45° angular width and 0.5 mm height. Specific for the MP-5 respirator.
 * 
 * @todo Make the clip height parametric. The current value applies to the Polish MP-5 respirator, resulting in 
 * 49.7 mm port cover inner diameter (after subtracting clip height), comparing well to the 49.5±0.1 mm for the 
 * original port cover.
 */
module clip() {
    // Points for rotate_extrude() are effectively defined in the (x,z) plane.
    // We define these points in CCW direction, starting with the point at the tip of the clipping ridge.
    clips_cross_section = [
        [clip_section_clip_r,                 0.5],
        [clip_section_clip_r + 0.5 + nothing, 0  ],
        [clip_section_clip_r + 0.5 + nothing, 1  ]
    ];
    
    rotate_extrude(angle = 45)
        polygon(points = clips_cross_section);
}

/** 
 * @brief Support ring on which the clips are mounted. Specific for the MP-5 respirator.
 * 
 * @todo Make the clip ring radius parametric, as that allows to create an almost airtight clip-on connection.
 */
module clip_ring() {
    // This clip ring height calculation guarantees a 45° angle of the clip ridge relative to the printer bed.
    // See separate drawing for details.
    clip_ring_h = 0.5 + (clip_section_inner_r - clip_section_clip_r) * tan(cone_section_truncate_angle + 45);
    
    // Points for rotate_extrude() are effectively defined in the (x,z) plane.
    // We define these points in CCW direction, starting with the point at the tip of the clipping ridge.
    clip_ring_cross_section = [
        [clip_section_clip_r + 0.5,      0          ],
        [clip_section_inner_r + nothing, 0          ],
        [clip_section_inner_r + nothing, clip_ring_h],
        [clip_section_clip_r + 0.5,      1          ]
    ];
    
    rotate_extrude(angle = 360)
        polygon(points = clip_ring_cross_section);
    
    rotate([0, 0, 22.5      ]) clip();
    rotate([0, 0, 22.5 + 90 ]) clip();
    rotate([0, 0, 22.5 + 180]) clip();
    rotate([0, 0, 22.5 + 270]) clip();
}

/** @brief Cylindrical section housing the clip-on elements. One of the three main sections of the body part. */
module clip_section() {
    // Hollow cylinder forming the outer shell of the clip section.
    rotate_extrude()
        translate([clip_section_inner_r, 0])
            chamfered_rectangle(w = wall_t, h = clip_section_h, chamfers = [0, 0, 0.5 * wall_t, 0]);
    translate([0, 0, clip_section_h])
        rotate([180, 0, 0])
            clip_ring();
}

/** @brief Conical section connecting the clip section and thread section. One of the three main sections of the body part. */
module cone_section() {
    tangential_circle_hull(
        r1 = clip_section_inner_r + wall_t,
        r2 = thread_section_inner_r + wall_t,
        angle = cone_section_truncate_angle,
        wall_t = wall_t
    );
}

/** @brief Threaded section at the bottom of the body part. One of the three main sections of the body part. */
module thread_section() {
    // TODO: Outsource the calculation of the thread profile (and the definition of the base profile) into a function.
    thread_core_r = thread_section_inner_r + wall_t;
    thread_profile = [ 
        for (i = base_thread_profile) [i[0] * thread_pitch, i[1] * thread_pitch + thread_core_r] 
    ];
            
    // Hollow cylinder with outer thread.
    difference() {
        // Solid cylinder with an outside thread.
        revolve(thread_profile, length = thread_section_h);
        
        // Cutout for the inner hole.
        translate([0, 0, -nothing])
            cylinder(h = thread_section_h + 2 * nothing, r = thread_section_inner_r, center = false);
        
        // 45° chamfer cut-off at the end of the thread, simulating a thread lead-in.
        chamfer_cutter_dr = cap_outer_r - thread_core_r; // Any cutter size exceeding the thread outer radius will do.
        rotate_extrude()
            translate([thread_core_r, -nothing])
                polygon([[0, 0], [chamfer_cutter_dr, 0], [chamfer_cutter_dr, chamfer_cutter_dr]]);
    }
    
    // End surface using a circular grid hole pattern.
    circular_grid(
        h = grid_h,
        r = thread_section_inner_r + wall_t - 2 * nothing,
        segment_counts = [4, 8, 12],
        spacer_t = wall_t
    );
}

/** @brief Main body of the filter holder. */
module body() {
    thread_section();
    
    translate([0, 0, thread_section_h - nothing])
        cone_section();
    
    translate([-thread_section_inner_r - wall_t, 0, thread_section_h - nothing]) 
        rotate([0, -cone_section_truncate_angle, 0]) 
            translate([clip_section_inner_r + wall_t, 0, -nothing])
                clip_section();
}

/** @brief Cap of the filter holder, with a thread fitting the body part. */
module cap() {
    thread_core_r = thread_section_inner_r + wall_t + thread_gap;
    thread_profile = [ for (i = base_thread_profile) [i[0] * thread_pitch, i[1] * thread_pitch + thread_core_r] ];
    cap_wall_t = cap_outer_r - wall_t - thread_section_inner_r;
    chamfers = [0.25 * wall_t, 0.25 * cap_wall_t, 0.25 * cap_wall_t, 0.25 * cap_wall_t]; // Chamfers for bottom inner, bottom outer, top outer, top inner edges.
            
    // Threaded hollow cylinder as shell of the thread section.
    difference() {
        // Hollow cylinder as base shape.
        rotate_extrude()
            translate([thread_section_inner_r + wall_t, 0])
                chamfered_rectangle(w = cap_wall_t, h = thread_section_h + grid_h, chamfers = chamfers);
        
        // Cut a thread into the upper part of the cylinder wall.
        translate([0, 0, grid_h + nothing])
            revolve(thread_profile, length = thread_section_h + 2 * nothing);
    }
    
    // End surface using a circular grid hole pattern.
    translate([0, 0, -nothing])
        circular_grid(
            h = grid_h,
            r = thread_section_inner_r + wall_t - 2 * nothing,
            segment_counts = [4, 8, 12],
            spacer_t = wall_t
        );
}


// (5) ASSEMBLY
// ======================================================================

/** @brief Arrange all objects according to the render control parameters. Exclused geometry postprocessing such as cross-sectioning. */
module scene() {
    // TODO: Center the part around the origin, as that is most useful for rotating when viewing. It is centered around the z axis already.
    
    if (scene_content == "body only")
        body();
    else if (scene_content == "cap only")
        cap();
    else {
        // Determine the height of the body relative to the lid.
        unscrew_body_h = 
            (scene_content == "both (cap opened)") ? cap_h + 20 : // Lid fully removed, with a 20 mm gap to the body.
            // TODO: Complete and enable the following line.
            // (scene_content == "both (cap closed one turn)") ? thread_h - thread_turn_h; // Useful to debug the thread gap.
            (scene_content == "both (cap closed)") ? nothing : nothing; // Cap fully screwed on.
    
        color("SteelBlue")
            translate([0, 0, grid_h + unscrew_body_h])
                body();
        color("Chocolate") cap();
    }
}

/** @brief Create and show the whole design. */
module main () {
    if (show_cross_section) {
        // TODO: Fix the rendering errors of doing intersection() or difference() here.
        intersection() {
            scene();
            
            // Big cuboid to remove half of the container for a cross-section view.
            // TODO: Calculate this based on actual object measures.
            color("Gold")
                translate([-250, 0, -250])
                    cube([500, 500, 500], center = false);
        }
    }
    else 
        scene();
}

// Entry point of the program.
main();
