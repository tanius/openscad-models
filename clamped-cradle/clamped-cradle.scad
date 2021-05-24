// ClampedDeviceHolder.scad
// 
// Holder for an electronic device that mounts to a round clamp.


// (1) CONVENTIONS
// ======================================================================

// - Directions: left/right, top/bottom and front/back are as used 
//   naturally when looking at the x/z plane into positive y direction.
// - Thing orientation: place part in natural orientation (means, so that 
//   the above directions apply to it.) It may have to be rotated for 
//   printing.
// - Thing position: The thing should be in the first octant ("only use 
//   positive coordinates"). Because that's the only practical universal 
//   convention for the origin, and it makes coordinates and part 
//   measurements idential.
// - Units: millimeters and 0-360 degrees only.
// - Abbreviations:
//   - w = width (local x coordinate)
//   - d = depth (local y coordinate)
//   - h = height (local z coordinate)
//   - r = radius
//   - t = wall thickness (can be any local coordinate; can be whole 
//     part thickness if part is a wall)
// - Variable names:
//   - Use one-word names for parts. This prevents complicated multi-part variable 
//     names that start with the same word and then branch out.
//   - Call the whole geometry "thing" (inspired by Thiniverse).
// - Code formatting: When chaining transformations, use {…} only when 
//   it applies to more than one commands. But always indent the commands 
//   that a chaining transformation applies to.
// - Part initial position: modules should create their parts in the first 
//   octant, with the bounding box starting at the origin. Means, use 
//   "center = false" when creating primitives. This leads to more 
//   intuitive translate() calls, avoiding the need to divide the whole 
//   calculation by two as in the case when objects start centered.
// - Part initial rotation: If the part is re-usable beyond the current 
//   thing, create it as if mounting it to the x/y plane. If the part 
//   is not re-usable, create it in the rotation needed for mounting it to 
//   the rest of the thing, because then that is the natural and only useful 
//   rotation of the part.
// - Part creation in x/y plane: Draw it so that as few rotations as 
//   possible bring it into its final alignment. For that, imagine the 
//   reverse: how to rotate the final object's part into the x/y plane.
// - Polygon points: Start with the one closes to the origin and then 
//   move CCW (mathematical spin direction, which is the shortest rotation 
//   transforming x to y axis).
// - Module content: create one part per module, without a color and 
//   without moving or rotating it for assembly.
// - Library choice: Try to use the MCAD library as much as possible. It is
//   the only library bundled by the OpenSCAD installer, so it can always 
//   be relied on without requiring the user to install anything first.
// - Avoid z-fighting for difference() by making the cutout larger, and 
//   avoid z-fighting for union() by making the parts overlap. Use the 
//   variable "nothing=0.01" for that (see below). Since union() 
//   z-fighting does not hide anything in preview mode and generates 
//   no errors when rendering, it is also ok to just hide these z-fighting 
//   artifacts visually by giving parts the same color.
// - Angles for printability: measure angles against vertical when discussing 
//   printability. Because the 45° rule for overhangs does so ("angles must be 
//   ≤45° to be printable on FDM printers").


// (2) INCLUDES
// ======================================================================

// Cubes with roundes corners.
use<MCAD/boxes.scad>

// Misc shape primitives. Needed to create the octagon prism.
use<MCAD/regular_shapes.scad>


// (3) PARAMETERS
// ======================================================================

// In the list below, the parameters containing a number are meant to be 
// user-configurable. Those containing a formula are derived values.
// 
// The initial parameter configuration is adapted for the device 
// Voltcraft PL-125-T4USB (a thermometer with four wired sensors and USB port)

// Instructions: due to current code limitations, there are interdependent 
// parameters. So you have to configure things in the following order:
// (1) Adjust outer and inner dimensions of the device holder.
// (2) Set holder_bottomwall_d.
// (3) Adjust holder_chamfer_delta visually so that the chamfers meet 
//     in the corners of the bottom wall cutout.
// (4) Adjust holder_bottom_t visually so that all parts of the bottom 
//     wall are thick enough and also not too thick.
// (5) Adjust all other parameters as needed.

/* [Global resolution] */
// ----------------------------------------------------------------------

// Smallest facet size to generate on rounded objects. (Use 2 for fast preview, 0.1 to export.) [mm]
$fs = 1;
// Largest angle to generate on rounded objects. [degrees]
$fa = 5;

/* [Device] */
// ----------------------------------------------------------------------

// Depth of electronic device to mount. [mm] (Exclude protruding keys, as there will be a cutout for them.)
device_d = 28;
// Width of electronic device to mount. Measure at the widest section that will be put into the holder. [mm]
device_w = 60.5;

/* [Device holder] */
// ----------------------------------------------------------------------

// Additional width / depth for loose fit. [mm]
holder_play = 2;
// Wall thickness of holder. [mm]
holder_t = 3.5;
// Wall thickness of holder bottom incl. chamfers. Adjust with visual feedback. [mm]
holder_bottom_t = 14;
// Width of holder (x dimension). [mm]
holder_w = device_w + holder_play + 2 * holder_t;
// Depth of holder (y dimension). [mm]
holder_d = device_d + holder_play + 2 * holder_t;
// Height of holder (z dimension). [mm]
holder_h = 80;
// Corner radius of the inner shell corners. [mm]
holder_corner_r_inner = 5; // Note: limit is 6 for the thermometer.
// Corner radius of the outer shell corners. [mm]
holder_corner_r_outer = holder_corner_r_inner + holder_t;
// Width of the open section centered on the front and bottom faces. [mm]
holder_cutout_w = 43;
// Depth of the bottom wall to keep standing. The cable has to be able to pass it into the device's port. [mm]
holder_bottomwall_d = 7;
// Depth of the cutout to remove a part of the bottom wall. [mm]
holder_cutout_d = holder_d - holder_bottomwall_d - holder_t;
// Adjustment (pos. or neg.) to increase or decrease the angle of the back edge chamfer against vertical. Adjust visually. [no unit] (When the back edge chamfer angle increases, the front one decreases, due to current design limitations.)
holder_chamfer_delta = 18.5;

// Wall thickness of the connectors between holer and mount cylinder. [mm]
support_t = 6;

/* [Clamp] */
// ----------------------------------------------------------------------
//   Refers to the properties of the clamp mount that will attach to the printed device holder.

// Optimum radius of clamped parts. [mm] (Rather larger than smaller, as the octagon shape we need for printability may deform in the clamp slightly.)
mount_r = 13.5;
// Width of the clamp. [mm]
mount_w = 20;

/* [Clamped part] */
// ----------------------------------------------------------------------
//  Refers to properties of the cylinder (rather: octagon) to which the clamp attaches.

// Circumradius of the clamped octagon. [mm]
mountee_r_outer = mount_r;
// Inradius of the clamped octagon. [mm]
mountee_r_inner = sin(67.5) * mountee_r_outer;
    // How this is calculated:
    // (1) Split the octagon into 16 idential triangles. One side of each 
    //     is the inradius ri, one side is the circumradius ro.
    // (2) Law of sines says: ri / ro = sin(67.5°) / sin(90°)
    // (3) It follows ri = sin(67.5°) / sin(90°) * ro = sin(67.5°) * ro

// Additional width of the clamped cylinder for an easy fit. [mm]
mountee_play = 2;
// Additional width of the clamped cylinder beyond the support connectors. [mm] (Must be positive to prevent z-fighting in the OpenSCAD preview.)
mountee_overhang = 0;
// Total width of the cylinder. [mm]
mountee_w = mount_w + mountee_play + 2 * support_t + 2 * mountee_overhang;
// Air gap between octagon and device holder. [mm]
mountee_gap = 8.5; // TODO: Better define as outer radius to device holder.
// Octagon edge length. [mm]
mountee_edge = 2 * mountee_r_inner * (sqrt(2) - 1);
    // As per https://de.wikipedia.org/wiki/Achteck#Formeln
// Unsupported portion of the octagon, up to start of bottom edge. [mm]
mountee_support_offset = (2 * mountee_r_inner - mountee_edge) / 2;

/* [Support connectors between device holder and clamped cylinder] */
// ----------------------------------------------------------------------

// Depth (y) of the support connectors. [mm]
support_d = mountee_r_inner + mountee_edge / 2 + mountee_gap;
// Height (z) of the support connectors. [mm]
support_h = 2 * mountee_r_inner + support_d;
    // (…) is to create a 45° angle at the support, which is that far from the case.

/* [Thing total dimensions] */
// ----------------------------------------------------------------------

// Bounding box width (x). [mm]
thing_w = holder_w;
// Bounding box depth (y). [mm]
thing_d = holder_d + mountee_gap + 2 * mountee_r_inner;
// Bounding box height (z). [mm]
thing_h = holder_h;

/* [Hidden] */
// ----------------------------------------------------------------------

// Idiom to finish the parameters section.
// Prevents non-user-configurable parameters to show up on the form.
module unused() {}

// Fix for z-fighting (see https://en.wikipedia.org/wiki/Z-fighting ).
// "nothing" is the chosen amount of overlap to "extend our cuts and 
// embed our joins" (see http://forum.openscad.org/id-tp20439p20460.html ).
// The naming is typical in OpenSCAD. 
//   To keep the formulas simple, this is applied to either positioning 
// or object sizing, depending on the case. But not to both, so that one 
// would cancel each other out exactly with respect to the rest of the 
// geometry. This introduces an acceptable inaccuracy. It may generate 
// additional faces for difference() but these are too small to be 
// visible in print.
//   To get a fully accurate version, set this to 0 for exporting / final 
// rendering, and hope that it will cause no errors.
nothing = 0.02;


// (5) PART GEOMETRIES
// ======================================================================

// Clamped octagon.
module mountee() {
    rotate([0, 90, 0]) {
        edge_to_face_angle = 360 / 8 / 2; // To rotate a face to the top.
        rotate([0, 0, edge_to_face_angle])
            translate([0, 0, -mountee_w/2]) {
                // Re-implementing MCAD's octagon_prism() as it uses deprecated reg_polygon().
                linear_extrude(height = mountee_w)
                    regular_polygon(8, mountee_r_outer);
            }
    }
}

// Outer holder shape for the electronic device.
module holder_shell() {
    // Re-center the holder after cutting the top, as that's assumed in the calling code for positioning.
    translate([0, 0, holder_corner_r_outer/2]) {
        difference() {
            // Outer holder geometry, with a rounded top as that's the library primitive.
            roundedBox([holder_w, holder_d, holder_h + holder_corner_r_outer], holder_corner_r_outer, false);
            
            // Intersector to remove the rounded top section of the holder.
            translate([0, 0, holder_h/2])
                cube([holder_w + nothing, holder_d + nothing, holder_corner_r_outer + nothing], center = true);
        }
    }
}

module holder_intersector(w, d, h_straight, h_sloped) {
    intersection() {
        h = h_straight + h_sloped;
        
        // Basic shape.
        // depth is added to height as that's what the intersector needs for 
        roundedBox([w + nothing, d + nothing, h + nothing], holder_corner_r_inner, true);
        
        // Intersector for the chamfers at the bottom.
        rotate([0, 180, 0]) {
            // Center the intersector.
            translate([-w/2, -d/2, -h/2]) {
                // Orientations below refer to a "hip roof on pillar" geometry.
                chamfer_points = [
                    // pillar bottom rectangle
                    [0, 0, 0], // 0. front left
                    [w, 0, 0], // 1. front right
                    [w, d, 0], // 2. back right
                    [0, d, 0], // 3. back left
                    // pillar top rectangle
                    [0, 0, h_straight], // 4. front left
                    [w, 0, h_straight], // 5. front right
                    [w, d, h_straight], // 6. back right
                    [0, d, h_straight], // 7. back left        
                    // roof ridge line
                    [w/2, d/2 - holder_chamfer_delta, h], // 8. left
                    [w/2, d/2 - holder_chamfer_delta, h], // 9. right
                ];
                chamfer_faces = [
                    // bottom face
                    [0,1,2,3], 
                    // pillar sides
                    [0,4,5,1], [1,5,6,2], [2,6,7,3], [0,3,7,4], 
                    // hip roof
                    [4,8,9,5], [5,9,6], [6,9,8,7], [4,7,8]];
                polyhedron(points = chamfer_points, faces = chamfer_faces);
            }
        }
    }
}

module holder() {
    difference() {
        holder_shell();
        
        // Inner holder geometry.
        intersector_w = holder_w - 2 * holder_t;
        intersector_d = holder_d - 2 * holder_t;
        intersector_h_straight = holder_h - holder_bottom_t;
        intersector_h_sloped = intersector_w/2; // Must be ≥ intersector_w/2 for printability (≥ 45° against printer bed).
        intersector_h = intersector_h_straight + intersector_h_sloped;
        
        translate([0, 0, (holder_h - intersector_h)/2 + nothing]) // align tops
            holder_intersector(intersector_w, intersector_d, intersector_h_straight, intersector_h_sloped);
        
        // Cutout for front and (part of) bottom wall.
        translate([0, -holder_t/2 - holder_bottomwall_d, 0])
            cube([holder_cutout_w, holder_cutout_d + nothing, holder_h + nothing], center = true);
    }
}

// One of two identical support connectors between device holder and clamped cylinder.
module support_wall() {
    rotate([0, -90, 0])
        linear_extrude(height = support_t, center = true)
            translate([-support_h/2, -support_d/2, 0]) // center to origin
                polygon([
                    [0, 0], 
                    [support_h, 0], 
                    [support_h, support_d], 
                    [support_d, support_d]
                ]);
}


// (6) PART ASSEMBLY
// ======================================================================

module main() {
    union() {
        
        // Clamped octagon.
        color("blue")
            translate([thing_w/2, thing_d - mountee_r_inner, thing_h - mountee_r_inner])
                mountee();

        // Support connectors: left, right.
        offset_x = mountee_w/2 - mountee_overhang - support_t/2;
        offset_y = support_d/2 + mountee_support_offset;
        color("blue") {
            translate([thing_w/2 - offset_x, thing_d - offset_y, thing_h - support_h/2])
                support_wall();
            translate([thing_w/2 + offset_x, thing_d - offset_y, thing_h - support_h/2])
                support_wall();
        }

        // Device holder.
        color("yellow")
            translate([thing_w/2, holder_d/2, thing_h/2])
                holder();
    }
}


// (7) MAIN PROGRAM
// ======================================================================

main();