use <threads.scad>
$fn = 200;

// top half with thread
difference() 
{
    union()
    {
        english_thread(2, 4, 0.5); // thread
        translate([0,0,-37]) cylinder(r=30,h=75,center=true); // tube
    }

    union()
    {
        translate([0,0,-20]) cylinder(r1=27,r2=20,h=70,center=true); // top cone
        translate([0,0,-7.7]) cylinder(r1=27.1,r2=21.5,h=15,center=true); // middle cone
        translate([0,0,-45]) cylinder(r=27,h=60,center=true); // bottom cylinder
    }
}

// bottom half with base
translate([0,0,-130])
difference()
{
    union()
    {
        translate([0,0,0]) cylinder(r=30,h=78,center=true); // outside of tube
        translate([0,0,43]) cylinder(r=26,h=10,center=true); // top tube extension
    }
    translate([0,0,6]) cylinder(r1=27,r2=25,h=85,center=true); // hole
}

// top for vial and small container
translate([0,0,20])
difference()
{
    // 1.02,1.02,1 - too tight
    // 1.1,1.1,1 - too loose ok for half size
    // 1.05,1.05,1 - not bad for full scale too tight for half scale
    translate([0,0,7.5]) cylinder(r=30,h=15,center=true);
    scale([1.05,1.05,1]) english_thread(2, 4, 0.5,internal=true);
    serrate(30,15,2,2,40);
}

module serrate(tr,tnum,cx,cy,cz)
{
    tx = tnum + 1;
    for (i = [0 : tnum])
    {
        translate ([tr*cos(i*(360/tx)),tr*sin(i*(360/tx)),0])
            rotate([0,0,i*(360/tx)])
                cube([cx,cy,cz],center=true);
    }
}
