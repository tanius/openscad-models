diameter=20.3; // to measure: bar diameter
distance=20.3 + 19.7 + 20.3 - 1.3; // to measure: distance between the bars (including bars)
  // Use 1-1.5 mm less than the measured distance to give the mounted hook some pre-tension.
  // This prevents wiggling around one end left and right, even for a narrow hook.

thickness=4.5; // wall thickness
space_h=15; // front hook distance
shift_h=0.5*diameter + thickness + 0.5*space_h; // front hook shift, 
   // calculated to make the front hook occupy the space between the tubes
height_h=10; // front hook height
alpha_t=210; // top hook angle
alpha_b=135; // bottom hook angle
radius_r=7.5; // rounding radius
$fn=100;
width=12.0; // width of the hook

radius_b=diameter/2;
distance_b=distance-2*radius_b;
radius_h=space_h/2;

module part_square(p_size,p_alpha) {
if (p_alpha < 0)
    mirror([0,1]) part_square(p_size,-p_alpha);
else if (p_alpha > 360)
    part_square(p_size,p_alpha-360);
else if (p_alpha > 180) {
        translate([-p_size,0]) square([2*p_size,p_size]);
        rotate(180) part_square(p_size,p_alpha-180);
    }
else if (p_alpha > 90) {
        square([p_size,p_size]);
        rotate(90) part_square(p_size,p_alpha-90);
    }
else if (p_alpha > 45)
    difference() {
        square([p_size,p_size]);
        mirror([1,-1]) part_square(p_size,90-p_alpha);
    }
else
    polygon([[0,0],[p_size,0],[p_size,tan(p_alpha)*p_size]]);
}

module part_ring(p_radius,p_thickness,p_alpha) {
    p_length=p_radius+p_thickness;
    intersection() {
        difference() {
            circle(p_length);
            circle(p_radius);
        }
        part_square(p_length,p_alpha);
    }
}

function vector(p_radius,p_alpha) = [p_radius*cos(p_alpha),p_radius*sin(p_alpha)];

function circle_intersection(c1,r1,c2,r2) = 
let( x1=c1[0], y1=c1[1], x2=c2[0], y2=c2[1],
x0=x2-x1,                                      // difference in x coordinates
y0=y2-y1,                                      // difference in y coordinates
r=sqrt(pow(x0,2)+pow(y0,2)),                   // distance between centers
m1=(pow(r,2)+pow(r1,2)-pow(r2,2))/2/r,         // distance from center 1 to line
m2=sqrt(pow(r1,2)-pow(m1,2)))
   [x1+x0*m1/r+y0*m2/r,y1+y0*m1/r-x0*m2/r];    // right point
// [x1+x0*m1/r-y0*m2/r,y1+y0*m1/r+x0*m2/r];    // left point

module circle_2(p1,p2,c1,r1,c2,r2) {
    difference() {
        polygon([p1,p2,c1,c2]);
        translate(c1) circle(r1);
        translate(c2) circle(r2);
    }
}

module circle_3(c1,r1,c2,r2,c3,r3) {
    difference() {
        polygon([c1,[c1[0]+r1,c1[1]],[c2[0]-r2,c2[1]],c2,c3]);
        translate(c1) circle(r1);
        translate(c2) circle(r2);
        translate(c3) circle(r3);
    }
}

r_thickness=thickness/2;
r_length_b=radius_b+r_thickness;
r_length_h=radius_h+r_thickness;
v_center=circle_intersection(
    [0,0],radius_b+thickness+radius_r,
    [radius_b+radius_h+thickness,shift_h],radius_h+thickness+radius_r
);
y1_center=sqrt(4*radius_h*radius_r+thickness*(2*radius_h+2*radius_r+thickness));
y2_center=sqrt(4*radius_b*radius_r+thickness*(2*radius_b+2*radius_r+thickness));

linear_extrude(width){
    // Upper radiator tube clamp.
    translate([0,distance_b]) {
        part_ring(radius_b,thickness,alpha_t);
        translate(vector(radius_b+r_thickness,alpha_t)) circle(r_thickness);
    }
    
    // Vertical, straight part of the clamp.
    translate([radius_b,0]) square([thickness,max(distance_b,shift_h)]);
    
    if (shift_h < 0)
        translate([radius_b,0]) mirror([0,1]) square([thickness,-shift_h]);
    
    // Lower radiator tube clamp.
    part_ring(radius_b,thickness,-alpha_b);
    
    // Tip rounding of the lower end.
    translate(vector(radius_b+r_thickness,-alpha_b)) circle(r_thickness);
    
    // Rounded part of the hook.
    translate([radius_b+radius_h+thickness,shift_h]) rotate(180)
        part_ring(radius_h,thickness,180);
    
    // Vertical part of the hook.
    translate([radius_b+2*radius_h+thickness,shift_h]) square([thickness,height_h-0.5*width]);
    
    // Original tip rounding of the hook. Here replaced by rounding in the yz-plane.
    //translate([radius_b+2*radius_h+3*r_thickness,shift_h+height_h]) circle(r_thickness);

    // Radius to support the hook at the bottom.
    if (shift_h > radius_h+thickness+radius_r)
        circle_2 (
            [radius_b+thickness,shift_h-y1_center],
            [radius_b+thickness,shift_h],
            [radius_b+radius_h+thickness,shift_h],radius_h+thickness,
            [radius_b+radius_r+thickness,shift_h-y1_center],radius_r
        );
    else if (-shift_h > radius_b+thickness+radius_r)
        circle_2 (
            [radius_b,-y2_center],
            [radius_b,0],
            [0,0],radius_b+thickness,
            [radius_b-radius_r,-y2_center],radius_r
        );
    else
        circle_3 (
            [0,0],radius_b+thickness,
            [radius_b+radius_h+thickness,shift_h],radius_h+thickness,
            v_center,radius_r
        );
}

translate([radius_b+2*radius_h+3*r_thickness, shift_h+height_h-0.5*width, 0.5*width])
    rotate([0, 90, 0])
        difference() {
            cylinder(h = thickness, r = 0.5*width, center = true);
            translate([0, -0.25*width, 0]) cube([width, 0.5*width, thickness + 0.01], center = true);
        }
