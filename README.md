# Parametric Respirator Outward Filter

**[1. Overview](#1-overview)**<br/>
**[2. Parameters](#2-parameters)**<br/>
**[3. Todo List](#3-todo-list)**<br/>
**[4. Code Conventions](#4-code-conventions)**

<p align="center">
  <a href="README.DesignRendering.png?raw=true"><img src="README.DesignRendering.png?raw=true" width="40%"></a><br/>
  (Click to enlarge.)
</p>


## 1. Overview

* **Description.** A fully parametric, 3D printable filter holder for the exhale port of respirators. The intended use is outward protection of others from pathogens that may be exhaled by the respirator user. This makes the use of a valved respirator suitable in situations where masks with outward protection are required, such as in many public spaces during the COVID-19 pandemic.

    The initial parameter values create a version for the [Polish military respirator MP-5](https://gasmaskandrespirator.fandom.com/wiki/MP-5), using a clip-on mechanism. To adapt it to other respirators, you will have to design your own mounting mechanism, in addition to configuring the parameters. STL files for this version are [available on Thingiverse](https://www.thingiverse.com/thing:4639075), so you don't have to render them yourself with OpenSCAD.

    Special care was taken to create a design that results in a usable, fast preview mode in OpenSCAD, to allow an interactive development process. This was done by using a very fast thread generation library (`revolve2.scad`) and preferring extrusion to `difference()` operations, because it is much faster.

* **Usage.** To use this design, add filter material from a surgical mask or similar in between the two parts, with a good amount of overlap so that it covers also the thread section. Screw the parts together. The filter material is meant to be captured in between the inner and outer thread, which holds it in place and tightens it against the filter holder.

* **Installation.** Clone or download the repository, or download all the files. Open `respirator_outward_filter.scad` in OpenSCAD. It will find the required library `revolve2.scad` that is supplied together with the design in the same directory.

* **Customizing.** You need to use OpenSCAD for parametrizing this design. The Thingiverse customizer app does not work because it expects a single `.scad` file but this design also includes another file `revolve2.scad`.

* **3D printing.** The initial parameters for the MP-5 compatible outward filter result in a part that is 3D printable without supports. As long as your chosen parameters for part radii and for `cone_section_truncate_angle` do not result in an overhang of >45° of the central cone section wall, the part is printable without supports. All threads use 45° flank angles for printability, and the clip ring adjusts itself to the inclination so that no overhang exceeds 45°.

* **Project home.** [tanius/respirator-outward-filter on Github](https://github.com/tanius/respirator-outward-filter)

* **Author.** tanius ([Github](https://github.com/tanius), [Thingiverse](https://www.thingiverse.com/tanius))

* **Licence.** Dual-licensed under [Creative Commons Attribution 4.0 International](https://creativecommons.org/licenses/by/4.0/) (or any later version at your option) and [Unlicense](https://unlicense.org/). For any libraries bundled in this repository, the licenses mentioned in these library files apply.


## 2. Parameters

All measures are in mm, all angles in degrees.

* `quality`: Render quality. Influences segments per degree for circular shapes.
* `scene_content`: What to show. Options are: "body only", "cap only", "both (cap opened)", "both (cap closed one turn)", "both (cap closed)".
* `show_cross_section`: If to cut the model in half. Useful for debugging.
* `wall_t`: Default wall thickness.
* `clip_section_h`: Height of the cylindrical section containing the clip mount mechanism.
* `cone_section_truncate_angle`: Angle between the two circles forming the conical section.
* `thread_section_h`: Height of the threaded section of the filter holder.
* `grid_h`: Height of the grid pattern's "lines".
* `clip_section_clip_r`: Radius between clip elements of the clip-mounted section, compatible with the respirator's exhale port cover clip-on mechanism.
* `clip_section_inner_r`: Inner radius of the clip-mounted section for the respirator's exhale port cover.
* `thread_section_inner_r`: Inside radius in the threaded section.
* `cap_outer_r`: Outside radius of the cap.
* `cap_turns`: Turns to close resp. open the cap.
* `thread_gap`: Radial gap between inner and outer thread. Meant to accommodate the filter material.


## 3. Todo List

* Complete the in-code documentation using Doxygen syntax.
* Generate the documentation in HTML format using Doxygen. Since OpenSCAD is quite similar to C syntax, this should be possible relatively easily.
* See the todo items as found in the code, marked with `TODO:`.
 

## 4. Code Conventions

The following code conventions are used in the design's OpenSCAD code (so, not in the `revolve2.scad` library).

* **Directions.** Left/right, top/bottom and front/back are as used naturally when looking at the x/z plane into positive y direction.

* **Thing orientation.** Place part in natural orientation (means, so that the above directions apply). It may have to be rotated for printing.

* **Thing position.** The thing should be in the first octant ("only use positive coordinates"). Because that's the only practical universal convention for the origin, and it makes coordinates and part measurements idential. 

    Exception: rotation symmetric parts should be centered around the positive half of one axis. This makes coordinates and radius related part measurements identical. The axis to center around is chosen depending on the natural orientation of the part (see above).
    
* **Units.** Millimeters and 0-360 degrees only.

* **Abbreviations.** In variable names, the following abbreviations are used in suffixes and infixes:
    * `w` = width (local x coordinate)
    * `d` = depth (local y coordinate)
    * `h` = height (local z coordinate in 3D, local y coordinate in 2D)
    * `r` = radius
    * `t` = thickness (can be any local coordinate; can be thickness of anything, including a whole part)
    * `d…` = delta (when used as a prefix; for example `dr` means a difference between two radii, effectively any measure in radial direction that does not start at the center)
    
* **Variable names.** Use single-word names for parts. This prevents too complicated multi-part variable names that start with the same word and then branch out. Call the whole geometry "thing" (inspired by Thingiverse).

* **Variable scope.** Code meant to be re-usable must receive all input as module / function parameters. Other code may also access all global variables defined at the beginning of the `.scad` file (incl. those by OpenSCAD customizer). These are by convention never changed after initial assignment. This makes them constants, safe to access from global scope without side effects. And in terms of software architecture, they are like the private variables of a an object, which are also used "globally" inside the class' code.

* **Code formatting.** When chaining transformations, use `{…}` only when it applies to more than one commands. But always indent the commands that a chaining transformation applies to.

* **Part initial position.** Modules should create their parts in the first octant, with the bounding box starting at the origin. Means, use "center = false" when creating primitives. This leads to more intuitive translate() calls, avoiding the need to divide the whole calculation by two as in the case when objects start centered.

* **Part initial rotation.** If the part is re-usable beyond the current thing, create it as if mounting it to the x/y plane. If the part is not re-usable, create it in the rotation needed for mounting it to the rest of the thing, because then that is the natural and only useful rotation of the part.

* **Part creation in x/y plane.** Draw it so that as few rotations as possible bring it into its final alignment. For that, imagine the reverse: how to rotate the final object's part into the x/y plane.

* **Polygon points.** Start with the one closest to the origin and then move CCW (mathematical spin direction, which is the shortest rotation transforming x to y axis).

* **Module content.** Create one part per module, without a color and without moving or rotating it for assembly.

* **Library choice.** Try to use the MCAD library as much as possible. It is the only library bundled by the OpenSCAD installer, so it can always be relied on without requiring the user to install anything first.

* **Avoiding z-fighting.** For difference() by making the cutout larger, and avoid z-fighting for union() by making the parts overlap. Use the variable "nothing=0.01" for that (see below). Since union() z-fighting does not hide anything in preview mode and generates no errors when rendering, it is also ok to just hide these z-fighting artifacts visually by giving parts the same color.

* **Angles for printability.** Measure angles against vertical when discussing printability. Because the 45° rule for overhangs does so ("angles must be ≤45° to be printable on FDM printers").