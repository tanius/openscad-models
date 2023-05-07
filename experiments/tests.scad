include<Round-Anything/polyround.scad>

extended_triangle_points = [
    [0, -6, 1],
    [5, -6, 1]
];

triangle = [
    [5, 0, 1],
    [0, 7, 1],
    [0, 0, 1]
];

extended_triangle_1 = [
    [0, -6, 1],
    [5, -6, 1],
    [5, 0, 1],
    [0, 7, 1],
    [0, 0, 1]
];

extend = true;
extended_triangle_2 = concat(
    extend ? extended_triangle_points : [],
    triangle
);

echo("triangle = ", triangle);

// polyRoundExtrude(triangle, length = 5, r1 = 0.3, r2 = 0.3, fn = 8);
// polyRoundExtrude(extended_triangle_1, length = 5, r1 = 0.3, r2 = 0.3, fn = 8);
// polyRoundExtrude(extended_triangle_2, length = 5, r1 = 0.3, r2 = 0.3, fn = 8);

// --------------------------------

centerRadius = 7;
points = [[0,0,0],[2,8,0],[5,4,3],[15,10,0.5],[10, 0, 1]];
mirroredPoints2 = mirrorPoints(points,0,[1,1]);
// translate([0,0,0])
//     polygon(polyRound(mirroredPoints2,20));

// ---------------------------------

points = [[1], [points[0] + 1]];
echo ("points =", points);