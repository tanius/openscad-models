# OpenSCAD Models


## 1. Overview

**Description.** A collection of all my OpenSCAD designs. [OpenSCAD](https://openscad.org/) is an open source, code-based 3D CAD software ("code CAD"). You describe your 3D designs in code, instead of using a drawing application with a graphical user interface. This enables for example fully parametric 3D designs – and all my designs contained here are fully parametric. While OpenSCAD is still the most widely used code CAD application of 3D printing enthusiasts ([see on Thingiverse](https://www.thingiverse.com/search?q=openscad)), I now consider [CadQuery](https://cadquery.readthedocs.io/) to be the superior alternative, so all my new 3D CAD work is instead going into [tanius/cadquery-models](https://github.com/tanius/cadquery-models).

**Project home.** Github repository [tanius/openscad-models](https://github.com/tanius/openscad-models/tree/master/straightwall-bottle).

**Author.** tanius ([Github](https://github.com/tanius), [Thingiverse](https://www.thingiverse.com/tanius))

**Licence.** This repository is dual-licensed under [Unlicense](https://unlicense.org/) and [Creative Commons Attribution 4.0 International](https://creativecommons.org/licenses/by/4.0/) (or any later version at your option). Exceptions:

* Content of folder `knob-factory` is licenced under [Creative Commons Attribution 3.0 Unported](http://creativecommons.org/licenses/by/3.0/) because it is based on an existing design.
* Libraries bundled with this repository may use different licences, as mentioned in their library files.


## 2. Content

Each folder contains one design, or a collection of closely related designs. By folder:

* **clamped-cradle.** Parametric holder for any handheld electronic device that mounts to a round clamp.

* **knob-factory.** A parametric design that allows to generate all kinds of knobs.

* **milwaukee-m28.** A small collection of 3D printable OpenSCAD designs for the Milwaukee M28 system of battery powertools, containing a battery socket and a battery isolator / blind socket that can also be used as a wall mount. For details, see the [milwaukee-m28 README](milwaukee-m28/README.md).

* **openscad-experiments.** Various tests and experiments with OpenSCAD, plus some reusable code.

* **respirator-accessory.** Two parametric accessories for respirator masks: an outward filter holder to make a respirator suitable for outward protection in a repiratory disease epidemic or pandemic; and a strap extension to adjust the length of respirator head straps. Both designs are made for the French Military CBRN mask type ARF-A
or type ANP VP F1 and the Polish Military ABC mask type MP-5, but the first one can be easily adapted to other respirators with a cylindrical output port. For details, see the [respirator-accessory README](respirator-accessory/README.md).

* **straightwall-bottle.** A parametric, 3D printable screw-top bottle with straight outer walls. For details, see the [straightwall-bottle README](straightwall-bottle/README.md).

* **truncated-toroid.** A parametric module to generate a truncated toroid shape in OpenSCAD.


## 3. Code Conventions

The following code conventions are used in all my OpenSCAD code (so, not in libraries I include):

* **Directions.** Left/right, top/bottom and front/back are as used naturally when looking at the x/z plane into positive y direction.

* **Thing orientation.** Place part in natural orientation (means, so that the above directions apply). It may have to be rotated for printing.

* **Thing position.** The thing should be in the first octant ("only use positive coordinates"). Because that's the only practical universal convention for the origin, and it makes coordinates and part measurements idential. 

    Exception: rotation symmetric parts should be centered around the positive half of one axis. This makes coordinates and radius related part measurements identical. The axis to center around is chosen depending on the natural orientation of the part (see above).
    
* **Units.** Millimeters and 0-360 degrees only.

* **Abbreviations.** In variable names, the following abbreviations are used in suffixes and infixes:
    * w = width (local x coordinate)
    * d = depth (local y coordinate)
    * h = height (local z coordinate)
    * r = radius
    * t = wall thickness (can be any local coordinate; can be whole part thickness if part is a wall)
    
* **Variable names.** Use one-word names for parts. This prevents complicated multi-part variable names that start with the same word and then branch out. Call the whole geometry "thing" (inspired by Thiniverse).

* **Variable scope.** Code meant to be re-usable must receive all input as module / function parameters. Other code may also access all global variables defined at the beginning of the .scad file (incl. those by OpenSCAD customizer). These are by convention never changed after initial assignment. This makes them constants, safe to access from global scope without side effects. And in terms of software architecture, they are like the private variables of a an object, which are also used "globally" inside the class' code.

* **Code formatting.** When chaining transformations, use {…} only when it applies to more than one commands. But always indent the commands that a chaining transformation applies to.

* **Part initial position.** Modules should create their parts in the first octant, with the bounding box starting at the origin. Means, use "center = false" when creating primitives. This leads to more intuitive translate() calls, avoiding the need to divide the whole calculation by two as in the case when objects start centered.

* **Part initial rotation.** If the part is re-usable beyond the current thing, create it as if mounting it to the x/y plane. If the part is not re-usable, create it in the rotation needed for mounting it to the rest of the thing, because then that is the natural and only useful rotation of the part.

* **Part creation in x/y plane.** Draw it so that as few rotations as possible bring it into its final alignment. For that, imagine the reverse: how to rotate the final object's part into the x/y plane.

* **Polygon points.** Start with the one closes to the origin and then move CCW (mathematical spin direction, which is the shortest rotation transforming x to y axis).

* **Module content.** Create one part per module, without a color and without moving or rotating it for assembly.

* **Library choice.** Try to use the MCAD library as much as possible. It is the only library bundled by the OpenSCAD installer, so it can always be relied on without requiring the user to install anything first.

* **Avoiding z-fighting.** For difference() by making the cutout larger, and avoid z-fighting for union() by making the parts overlap. Use the variable "nothing=0.01" for that (see below). Since union() z-fighting does not hide anything in preview mode and generates no errors when rendering, it is also ok to just hide these z-fighting artifacts visually by giving parts the same color.

* **Angles for printability.** Measure angles against vertical when discussing printability. Because the 45° rule for overhangs does so ("angles must be ≤45° to be printable on FDM printers").
