/* 

# Additional documentation for "Parametric container with straight walls and a screw top"


## 1. Basic Description

*(Also found at the top of the source file`straightwall_screwtop_container.scad`.)*

* **Description.** A fully parametric screw-lid container / bottle container that has straight walls on the outside (means, no overhanging lid). The inner shape can be bottle-like (with a narrower neck section) or purely cylindrical (resulting in thick walls). The initial parameter settings (cylindrical interior of 66 mm × 19 mm Ø) make this a protective case for a flat-top 18650 lithium-ion cell.

* **Installation.** Place all files into the same directory and open this file in OpenSCAD. This way, it will find the required library "threads.scad" that is supplied together with this main file.

* **Project URL.** https://www.thingiverse.com/thing:3826892

* **Author.** tanius, https://www.thingiverse.com/tanius

* **Licence.** Creative Commons Attribution 4.0 International

* **Based on.**

    1. "[Tall threaded tube](http://www.thingiverse.com/thing:2175003)" by sej7278, licenced under Creative Commons Attribution (CC-BY).
    
    2. "[Screw Top Containers](https://www.thingiverse.com/thing:455426)" by pmoews, licenced under Creative Commons Attribution (CC-BY).


## 2. Extended Description

*(Supplied in the Thingiverse "Summary" field.)*

A fully parametric screw-lid container / bottle container that has straight walls on the outside (means, no overhanging lid).The inner shape can be bottle-like (with a narrower neck section) or purely cylindrical (resulting in thick walls). The initial parameter settings (cylindrical interior of 66 mm × 19 mm Ø) make this a protective case for a flat-top 18650 lithium-ion cell.

All OpenSCAD source files are supplied and properly documented, and the design is under a proper open source licence (**not** the CC-BY-NC-* stuff). Hope you find it useful.


**Customizing**

You need to use OpenSCAD itself for this. The Thingiverse customizer app does not work so far, because it expects a single `.scad` file but this project also uses `threads.scad`.


**Parameters**

* what to show (body / lid / both / both in cross-section mode)
* output quality (to improve preview speed)
* inner height
* inner diameter
* widen inner diameter yes / no (to enable internal "bottle shape")
* lid height
* minimum wall thickness
* lid turns to open or close it


## 3. Todo Items

* Move comment content from the start of this file to a file README.md. That content would be copied to the Thingiverse form when publishing there, so should be aligned to its form fields.

* Document which threads library is used, and where to find the latest version ("uses threads.scad, available at 
http://dkprojects.net/openscad-threads/ ).

* Add a few pictures with example containers to the README, as the .stl export files will not be published in all cases (not on Github for example, as they are generated files).

* Add a LICENCE.txt file with the right licence.

* Publish the code on Github, and put the link here.

* Make the grip surface finish on the lid sides configurable. At the least, make the number of serration cuts configurable.

* Make the Thingiverse Customizer app work for this design. For that, create a "compilation" script that will combine this file with threads.scad.

* Fix that the continuous wall thickness at the neck is larger than wall_t, increasing the total outer diameter. This is because threads.scad does not make the radial extension of the thread accessible, and the current way of determining it in the code below is inaccurate. Either switch to a better thread library or fix the bug in threads.scad.

* Decrease thread height of the external thread by a small amount (0.5 mm) to make sure the end stop is between lid opening and body neck, not leaving any gap there, and not resulting in any pressure that could damage the top wall. Note that thread_gap does not require decreasing thread height: with the gap centered around a thread turn, there will be some play upwards when the lid hits the body's neck. But that play is removed by screwing on some more.

* Split the parameter wall_t for the minimum wall thickness into two: one for non-threaded walls, one for threaded walls. Because the latter are stabilized by the thread, they can be made thinner.

* Output relevant measures (outer dimensions, thread pitch etc.) when they have been calculated.

* Provide a parameter that allows a non-threaded part at the top of the neck section. This will allow to have sufficient lid height while avoiding too many turns to open and close the lid. It will also help with positioning to start screwing the lid on.

* Other TODO items as found in the code.
 

## 4. Code Conventions

The following code conventions are used in the OpenSCAD code that I wrote (so, not in the library).

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

*/