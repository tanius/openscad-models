// Example and demo code outsourced from the original revolve2.scad file.
// Not used in the respirator-outward-filter design.

use <revolve2.scad>

module revolve_demo_scene() {
  // A square profile vector defined manually
  sq_prof = [[0, 11], [0, 9], [2, 9], [2, 11], [4, 11]];
    
  translate([0,-5]) rotate([-81,0]) translate ([0,-11/sqrt(2)]) difference() {
    revolve( sq_prof, length=40, nthreads=-2, scale=2, preserve_thread_shape=true, $fn=30);
    translate([0,0,-1]) rotate([0,0,45]) cube(110);
  }
  
  // A dovetail profile vector defined manually
  dt_prof = [[0, 6], [2*2/5, 6], [2*1/5, 5], [2*4/5, 5], [2*3/5, 6], [2, 6]];
  
  translate([28,22,0]) intersection() {
    translate([0,0,5]) sphere(r=10.5);
    difference() {
      cylinder(r=10,h=10, $fn=6);
      translate([0,0,-1]) revolve( dt_prof, length=12, $fn=30);
      translate([2,5,4]) rotate([0,0,15]) cylinder( r=10, h=12, $fn=3 );      
    }
  }

  // Puzzle piece profile
  pz_prof = [[0, 50], [10, 50], [12.8, 50.7], [14.6, 51.7], [15.1, 53], [14.9, 54.5], [13.8, 56.3], [11.6, 58.4], [10.3, 60.6], [10.4, 62.7], [11.4, 64.7], [13, 66.5], [15.3, 68], [18, 69.1], [21.2, 69.8], [25, 70], [28.8, 69.8], [32, 69.1], [34.7, 68], [37, 66.5], [38.6, 64.7], [39.6, 62.7], [39.7, 60.6], [38.4, 58.4], [36.2, 56.3], [35.1, 54.5], [34.9, 53], [35.4, 51.7], [37.2, 50.7], [40, 50], [50, 50]];

  translate([20,0,-1.5]) rotate([0,-30]) translate([70*0.2,0]) rotate([0,0,60]) scale(0.2) difference() {
      revolve( pz_prof, length=250, nthreads=3, $fn=45);
      rotate([0,0,-30]) translate([10,10,150]) cube(500);
  }
}

module revolve_example_scene() {
    // A sinusoidal profile function...
    period = 3;
    function prof_sin(z) = [z, 10+sin(z*360/period)];
    // ...which becomes a profile vector with the help of linspace
    sin_prof = [for (z=linspace(start=0, stop=period, n=15)) prof_sin(z)];
    revolve( sin_prof, length=30, nthreads=2, $fn=30);

    // Scale demo
    // A square profile defined manually
    sqr_prof = [[0,11],[2,11],[2,9],[4,9],[4,11]];
    intersection() {
      translate([-20,10,-10]) cube([20,100,50]);
      union () {
        color("red") translate([0,30]) 
          revolve( sqr_prof, length=30, scale=0.2, nthreads=-1, $fn=30);
        color("blue") translate([0,60])
          revolve( sqr_prof, length=30, scale=0.2, preserve_thread_depth=true, nthreads=-1, $fn=30);
        color("green") translate([0,90])
          revolve( sqr_prof, length=30, scale=0.2, preserve_thread_shape=true, nthreads=-1, $fn=30);
      }
    }
}

// To reproduce the example:
revolve_example_scene();

// To reproduce the sample STL of Revolve2 provided on Thingiverse:
// rotate([0,0,180]) revolve_demo_scene();