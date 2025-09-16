// Császár_polyhedron
// http://en.wikipedia.org/wiki/Császár_polyhedron

// units in mm for printing about 5cmx5cmx10cm
// compatibility drawtext module (replaces TextGenerator.scad's drawtext)
use <maths.scad>

module drawtext(txt) {
    linear_extrude(height = 1, $fn = 24)
        text(
            txt,
            size   = 10,
            font   = "Liberation Sans",
            halign = "center",
            valign = "center"
        );
}

// previewer configuration
//$vpr = [62.7, 0, 96.4];
//$vpt = [-1.13, -0.727, -0.103];
//$vpf = 22.5;
//$vpd = 66.96;

module pyramid(a, b, c, apex) {
    polyhedron(
        points = [a, b, c, apex],
        faces  = [
            [0,1,2],
            [1,0,3],
            [2,1,3],
            [0,2,3]
        ]
    );
}

module tor() {
    polyhedron(
        points    = [v1, v2, v3, v4, v5, v6, v7],
        faces     = [
            [0,3,1],[3,6,1],[1,6,4],[1,4,2],
            [2,4,3],[2,3,0],[3,4,5],[3,5,6],
            [0,5,4],[0,1,5],[1,2,5],[2,6,5],
            [2,0,6],[0,4,6]
        ],
        convexity = 12
    );
}

module hole() {
    enter_door = (v3 + v4 + v6) / 3;
    exit_door  = (v2 + v5 + v6) / 3;

    polyhedron(
        points    = [v1, v2, v3, v4, v5, v6, v7],
        faces     = [
            [3,6,5],[2,5,6],[1,6,3],[0,1,3],
            [0,3,2],[6,0,2],[0,6,4],[0,5,1],
            [5,4,0],[1,4,6],[2,3,5],[1,5,4]
        ],
        convexity = 12
    );

    translate(enter_door)
        scale([.6,.6,.6])
        rotate($vpr)
        translate([0,3,10])
            drawtext("enter");

    translate(enter_door)
        scale([.6,.6,.6])
        rotate($vpr)
        translate([0,-7,10])
            drawtext("door");

    translate(exit_door)
        scale([.6,.6,.6])
        rotate($vpr)
        translate([0,3,10])
            drawtext("exit");

    translate(exit_door)
        scale([.6,.6,.6])
        rotate($vpr)
        translate([0,-7,10])
            drawtext("door");
}

space = [-80,0,0];
bl    = 50;

// vertex coordinates
v6 = [bl, bl, 0];
v3 = [0, 0, v6[2]];
v1 = [bl/2, bl/2, (v6[0] - v3[0]) * sqrt(3)/2];
v2 = [0, bl, (v1[2] + v3[2]) / 2];
v4 = [bl, 0, v2[2]];
v5 = [3*v1[0] - v6[0] - v2[0], bl/2, 3*v1[2] - v6[2] - v2[2]];
v7 = [
    (v2[0] + v1[0] + v3[0]) / 3,
    (v2[1] + v1[1] + v3[1]) / 3,
    (v2[2] + v4[2] + v3[2]) / 3
];

// annotate vertices
translate(v1 + space) rotate($vpr) drawtext("1");
translate(v2 + space) rotate($vpr) drawtext("2");
translate(v3 + space) rotate($vpr) drawtext("3");
translate(v4 + space) rotate($vpr) drawtext("4");
translate(v5 + space) rotate($vpr) drawtext("5");
translate(v6 + space) rotate($vpr) drawtext("6");
translate(v7 + space) rotate($vpr) drawtext("7");

// two halves
translate(space)
    polyhedron(
        points = [v1, v2, v3, v4, v6, v7],
        faces  = [
            [0,1,4],[1,2,4],[2,5,4],
            [3,4,5],[1,0,3],[5,1,3]
        ]
    );

translate(space)
%   polyhedron(
        points = [v1, v2, v3, v4, v5, v6, v7],
        faces  = [
            [0,2,3],[0,5,4],[3,4,5],[0,4,6],
            [1,6,4],[1,4,2],[2,4,3],[0,6,2]
        ]
    );

// breathing hole
translate(-space * (cos($t*360) + 1)/2) {
    #hole();
    translate(-space + [-50 - 40*cos($vpr[2]), -25, -10])
        rotate($vpr)
        drawtext("The hole of Tor");
}

// final tor and sphere
tor();
translate(space + [20.23197,22.443393,24.632890])
    sphere(r = 2.7, $fn = 32);

// object labels
translate([27.5 - 37.5*cos($vpr[2]), -15, -20])
    rotate($vpr)
    drawtext("7 Vertexes Tor");

translate(space + [7.5 - 57.5*cos($vpr[2]), -25, -10])
    rotate($vpr)
    drawtext("Half Tor transparent");

// tetrahedron separation
space2 = 20*(cos($t*360+180) + 1);
space1 = -2*space;

translate(space1) pyramid(v2, v3, v6, v7);

trans1 = VNORM(VCROSS(v2 - v7, v2 - v6));
translate(space1)
    translate(space2 * trans1)
    pyramid(v4, v2, v6, v7);

trans2 = VNORM(VCROSS(v2 - v4, v2 - v6));
translate(space1)
    translate(space2 * (trans1 + trans2))
    pyramid(v2, v4, v6, v1);

trans3 = VNORM(VCROSS(v1 - v4, v1 - v6));
translate(space1)
    translate(space2 * (trans1 + trans2 + trans3))
%   pyramid(v1, v4, v6, v5);

trans4 = VNORM(VCROSS(v1 - v4, v1 - v5));
translate(space1)
    translate(space2 * (trans1 + trans2 + trans3 + trans4))
%   pyramid(v1, v4, v5, v3);

trans5 = VNORM(VCROSS(v1 - v3, v1 - v5));
translate(space1)
    translate(space2 * (trans1 + trans2 + trans3 + trans4 + trans5))
%   pyramid(v1, v3, v5, v7);

trans6 = VNORM(VCROSS(v7 - v2, v7 - v3));
translate(space1)
    translate(space2 * trans6)
%   pyramid(v7, v3, v5, v2);

translate(-2*space + [27.5 - 37.5*cos($vpr[2]), -15, -20])
    rotate($vpr)
    drawtext("Animate seperation");

// FACES ON TORUS TOPOLOGY
module topology() {
    d13=[0,3]; d14=[1,3]; d15=[2,3]; d16=[3,3];
    d9 =[0,2]; d10=[1,2]; d11=[2,2]; d12=[3,2];
    d5 =[0,1]; d6 =[1,1]; d7 =[2,1]; d8 =[3,1];
    d1 =[0,0]; d2 =[1,0]; d3 =[2,0]; d4 =[3,0];

    scale([10,10])
        polygon(
            points = [d1,d2,d3,d4,d5,d6,d7,d8,d9,d12,d13,d14,d15,d16],
            paths  = [
                [0,4,5],[1,0,5],[1,2,5],[2,5,6],
                [2,3,6],[3,6,7],[4,5,8],[5,6,8],
                [6,8,11],[8,10,11],[6,7,11],[7,11,12],
                [7,9,12],[9,12,13]
            ]
        );

    scale([.5,.5]) drawtext("1");
    translate([10,0]) scale([.5,.5]) drawtext("2");
    translate([20,0]) scale([.5,.5]) drawtext("3");
    translate([30,0]) scale([.5,.5]) drawtext("1");

    translate([0,10]) scale([.5,.5]) drawtext("5");
    translate([10,10]) scale([.5,.5]) drawtext("6");
    translate([20,10]) scale([.5,.5]) drawtext("7");
    translate([30,10]) scale([.5,.5]) drawtext("5");

    translate([0,20]) scale([.5,.5]) drawtext("4");
    translate([30,20]) scale([.5,.5]) drawtext("4");

    translate([0,30]) scale([.5,.5]) drawtext("1");
    translate([10,30]) scale([.5,.5]) drawtext("2");
    translate([20,30]) scale([.5,.5]) drawtext("3");
    translate([30,30]) scale([.5,.5]) drawtext("1");
}

translate([-200,-100,0]) topology();