# Respirator Accessory

**[1. Overview](#1-overview)**<br/>
**[2. Parts](#2-parts)**
**[3. Todo List](#3-todo-list)**<br/>
**[4. Code Conventions](#4-code-conventions)**<br/>


## 1. Overview

**Description.** A small collection of parametric accessory parts for respirator masks. The parts have been designed for the following respirators:

* [French Military CBRN mask type ARF-A](https://gasmaskandrespirator.fandom.com/wiki/ARF-A), also called
* [French Military CBRN mask type ANP VP F1](https://gasmaskandrespirator.fandom.com/wiki/ARF-A)
* [Polish military repirator MP-5](https://gasmaskandrespirator.fandom.com/wiki/MP-5), which is basically a whitelabel product of the French mask with compatible mechanical parts.
 
But, since they are fully parametric, can often be adapted to other models by just changing a few parameters. All parts have been designed with FDM 3D printing in mind.

In Europe, surplus stocks of the French ARF-A respirator are widely available on eBay etc. in like-new quality for about 20 EUR; often mislabeled as Polish MP-5 respirators, but that does not matter. It is a relatively recent (~2006) model that is not inferior to new masks that cost 200 EUR and up. So for people looking for affordable high-grade respiratory protection, this is a good base. For example, for protection against the SARS-CoV-2 coronavirus or also for protection against fine dust, you would use this mask together with a new P3 R filter with RD40 mount, which is commercially available easily. I can't comment on the safety of the original CBRN filters that come with the mask.

**Installation.** Clone or download the repository, or download all the files. Open any `.scad` file in OpenSCAD. It will find the required libraries in `lib/`, if any.


## 2. Parts

### 2.1. Outward Filter

<p align="center">
    <a href="outward-filter.1.jpg?raw=true"><img src="outward-filter.1.jpg?raw=true" width="40%"></a>
    <a href="outward-filter.2.png?raw=true"><img src="outward-filter.2.png?raw=true" width="40%"></a><br/>
    (Click to enlarge.)
</p>

**Description.** A fully parametric, 3D printable filter holder for the exhale port of respirators. The intended use is outward protection of others from pathogens that may be exhaled by the respirator user. This makes the use of a valved respirator suitable in situations where masks with outward protection are required, such as in many public spaces during the COVID-19 pandemic.

The initial parameter values (namely `clip_section_clip_r` = 24 mm) create a version for the [French military respirator ARF-A](https://gasmaskandrespirator.fandom.com/wiki/ARF-A), using a clip-on mechanism. The clips can be clipped into the circular recess where the original exhale port cover clips in, but it is better for an almost airtight connection to the mask to clip it at the very bottom instead. With `clip_section_clip_r` = 24 mm that will fit, but very tightly. You'll need quite some force to push the part into position, but nothing will break for a part printed in ABS with 100% infill. The advantage of the tight fit is that the outward filter will not rotate on its own during use.

To adapt the outward filter to other respirators, you will have to design your own mounting mechanism, in addition to configuring the parameters.

Special care was taken to create a design that results in a usable, fast preview mode in OpenSCAD, to allow an interactive development process. This was done by using a very fast thread generation library (`revolve2.scad`) and preferring extrusion to `difference()` operations, because it is much faster.

**Customizing.** You need to use OpenSCAD for parametrizing this design. The Thingiverse customizer app does not work because it expects a single `.scad` file but this design also includes another file `revolve2.scad`. Available parameters (all measures in mm, all angles in degrees):

* **`quality`:** Render quality. Influences segments per degree for circular shapes.
* **`scene_content`:** What to show. Options are: "body only", "cap only", "both (cap opened)", "both (cap closed one turn)", "both (cap closed)".
* **`show_cross_section`:** If to cut the model in half. Useful for debugging.
* **`wall_t`:** Default wall thickness.
* **`clip_section_h`:** Height of the cylindrical section containing the clip mount mechanism.
* **`cone_section_truncate_angle`:** Angle between the two circles forming the conical section.
* **`thread_section_h`:** Height of the threaded section of the filter holder.
* **`grid_h`:** Height of the grid pattern's "lines".
* **`clip_section_clip_r`:** Radius between clip elements of the clip-mounted section, compatible with the respirator's exhale port cover clip-on mechanism.
* **`clip_section_inner_r`:** Inner radius of the clip-mounted section for the respirator's exhale port cover.
* **`thread_section_inner_r`:** Inside radius in the threaded section.
* **`cap_outer_r`:** Outside radius of the cap.
* **`cap_turns`:** Turns to close resp. open the cap.
* **`thread_gap`:** Radial gap between inner and outer thread. Meant to accommodate the filter material.

**3D printing.** The initial parameters for the MP-5 compatible outward filter result in a part that is 3D printable without supports. As long as your chosen parameters for part radii and for `cone_section_truncate_angle` do not result in an overhang of >45° of the central cone section wall, the part is printable without supports. All threads use 45° flank angles for printability, and the clip ring adjusts itself to the inclination so that no overhang exceeds 45°.

**Building and assembly.** To use this design, add filter material from a surgical mask or similar in between the two parts, with a good amount of overlap so that it covers also the thread section. Screw the parts together. The filter material is meant to be captured in between the inner and outer thread, which holds it in place and tightens it against the filter holder.


### 2.2. Strap Extender

<p align="center">
    <a href="strap-extender.1.jpg?raw=true"><img src="strap-extender.1.jpg?raw=true" width="40%"></a>
    <a href="strap-extender.3.png?raw=true"><img src="strap-extender.3.png?raw=true" width="40%"></a><br/>
    (Click to enlarge.)
</p>

**Description.** A parametric, 3D printable OpenSCAD design for headstrap extension clips for the 
[French military respirator ARF-A](https://gasmaskandrespirator.fandom.com/wiki/ARF-A). In effect, it allows to move the middle and upper headstrap mounts to the back, which will remove pressure from the straps if your head is too large to wear the mask comfortably. Since it is not easily possible to extend the straps themselves or manufacture longer ones, this is the simplest option to adapt the mask to a larger heads, as you can move the strap mountpoints up to about 50-60 mm per side to the back.

**Customizing.** Available parameters (all measures in mm, all angles in degrees):

* **`quality`:** Render quality. Influences segments per degree for circular shapes.
* **`show`:** What to show in the preview or rendering. Options are: "upper", "lower", "both (apart)", "both (together)". Allows to render each part into an individual STL file.
* **`create_cross_section`:** If to cut the model in half. Useful for debugging.
* **`extension_length`:** How much to offset the strap mount relative to the original position. For comparison, the rubber band of the middle headstraps on the MP-5 respirator sizes 1-2 can be extended by about 90 mm per side at the most.

**Building and assembly.** 

1. To use this design in OpenSCAD, you also need to install the [Round Anything library](https://github.com/Irev-Dev/Round-Anything/).

2. Customize the part in the OpenSCAD customizer by choosing the extension length.

3. Print the upper part and lower part twice each. I used ABS with 100% infill.

4. Remove the original middle or upper headstraps. The design does not work for extending the lower headstraps.

5. Remove the triangular clip around the mask's attachment point for the headstrap. It will not break when bending it, as it's a strange, very tough plastic. But you have to use quite some force to pull and twist the clips off.

6. Hook the lower extension part with its slot around the mask's attachment point.

7. Insert the part that remains on the end of the headstrap into the other end of the extension part.

8. Push the upper part of the extension onto the lower one.

9. Seal both parts of the strap extender together with a commonplace 4.8 mm wide cable tie, using the groove prepared for that.


## 3. Todo List

Only about todo items for the repository as a whole. Todo items for individual parts are contained in their `.scad` files and marked `@todo`.

* Add STL files of the designs (using the default parameters and low quality) to the doc/ directory.

* Link the Github 3D view of the STL files from corresponding images embedded in `README.md`, and add a note "(Click to view in 3D.)".

* Create a clear separation between original and derived files in `doc/`. In this case, derived files have to be included into the Github repo to be visible in `README.md`, but it should be clear that they are redundant. For example, use two directories `doc/` and `doc-build/`.

* Create a way to re-generate the illustrations in `doc/` automatically using a build script. Should also include some image processing to create versions as needed for Thingiverse thumbnails (4:3, smaller size) and other purposes.

* Create versions that can be used with the Thingiverse customizer, by embedding the libraries (like `revolve2.scad`) into the main `.scad` files. This should probably be done by a build script. And there should be a build directory for its output.

* Generate the documentation in HTML format using Doxygen. Since OpenSCAD is quite similar to C syntax, this should be possible relatively easily.

* Add a GoPro mount accessory part that can be mounted to the flap over the eye section.

* Add a printable complete RD40 filter. It should allow to use FFP2 / FFP3 masks or surgical mask material as the filter material. Surgical mask material can be captured in the thread as done for the outward filter.

* Add an eyescreen protector. Useful when using the mask when doing angle grinding or other activities that generate sparks.

* Add a small container for vaseline, which can be used to achieve a better fit. It should have an option to be mounted to the drink port, as that will usually not be needed. Even better, a small chaulk gun type of device might be more comfortable to apply the vaseline to the mask evenly.

* Add adapters to various drinking bottles and straws, to be used with the integrated drinking port.

* Add a soft loop with cylindrical cross-section that can be glued into the inner mask to adapt it to ones own face outline. For that, it should have a hole inside to insert a copper wire.

* Add a spike ring that can be added to the bottom of any filter (if printed with the right measure for that filter). It allows to store the mask standing on its filter while still allowing air to reach the filter surface so that it can dry and so that any germs are inactivated by oxygen over the course of a few days.

* Add a glasses holder that can be mounted inside the mask.

* Add a sewing template for a black cover that can be pulled over the filter, to extend its lifetime by protecting it from being soiled during usage.

* Add a beard cutter template, to mark and shave the 30 mm wide stripe around the face that constitutes the sealing surface.

* Add fit testing equipment. However, when using the vaseline trick, quantitative fit testing is not really needed.

* Add printable spare parts (hooks, loops, port covers, valves). If larger parts break, one would instead simply buy another mask for 20 EUR.
