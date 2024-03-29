# Straightwall Bottle


## 1. Basic Documentation

*(Also found at the top of file`straightwall_bottle.scad`.)*

* **Description.** A fully parametric screw-lid container / bottle container that has straight walls on the outside (means, no overhanging lid). The inner shape can be bottle-like (with a narrower neck section) or purely cylindrical (resulting in thick walls). The initial parameter settings (cylindrical interior of 66 mm × 19 mm Ø) make this a protective case for a flat-top 18650 lithium-ion cell.

* **Installation.** Place all files into the same directory and open this file in OpenSCAD. This way, it will find the required library "threads.scad" that is supplied together with this main file.

* **Project URL.** https://www.thingiverse.com/thing:3826892

* **Author.** tanius, https://www.thingiverse.com/tanius

* **Licence.** Creative Commons Attribution 4.0 International

* **Based on.**

    1. "[Tall threaded tube](http://www.thingiverse.com/thing:2175003)" by sej7278, licenced under Creative Commons Attribution (CC-BY).
    
    2. "[Screw Top Containers](https://www.thingiverse.com/thing:455426)" by pmoews, licenced under Creative Commons Attribution (CC-BY).


## 2. Extended Description

*(Also found in the [Thingiverse thing](https://www.thingiverse.com/thing:3826892) "Summary" field.)*

A fully parametric screw-lid container / bottle container that has straight walls on the outside (means, no overhanging lid). The inner shape can be bottle-like (with a narrower neck section) or purely cylindrical (resulting in thick walls). The initial parameter settings (cylindrical interior of 66 mm × 19 mm Ø) make this a protective case for a flat-top 18650 lithium-ion cell.

All OpenSCAD source files are supplied and properly documented, and the design is under a proper open source licence (**not** the CC-BY-NC-* stuff). Hope you find it useful.


**Customizing**

You need to use OpenSCAD itself for this. The Thingiverse customizer app does not work so far, because it expects a single `.scad` file but this project also uses `threads.scad`.


**Parameters**

* what to show (body / lid / both / both in cross-section mode)
* output quality (to improve preview speed)
* minimum wall thickness
* inner height
* inner diameter
* widen inner diameter yes / no (to enable internal "bottle shape")
* lid height
* lid turns to open or close it


## 3. Todo List

* Document which threads library is used, and where to find the latest version ("uses threads.scad, available at 
http://dkprojects.net/openscad-threads/ ).

* Move the todo items from here to Github issues.

* As the intersector for the lid grip profile, use one that leaves a ring at the bottom of the thread for added stability. As seen at [another battery case](https://www.thingiverse.com/thing:3850880).

* Add a few pictures with example containers to the README, as the .stl export files will not be published in all cases (not on Github for example, as they are generated files).

* Add a LICENCE.txt file with the right licence.

* Publish the code on Github, and put the link here.

* Find out proper thread gap values for different sizes of threads, and calculate them automatically. The current default produces a much too loose fit for a 18650 container, at least on a well calibrated printer. Ideally, there would be a parameter to enter the printer's calibration ("1% ±0.2 mm") an a suitable thread gap will be calculated accordingly.

* Make the grip surface finish on the lid sides configurable. At the least, make the number of serration cuts configurable. And support a flat finish (which is enough for grip still, and does not weaken the lid).

* Provide a way to secure the thread with friction when the lid is screwed on. For example a tapered thread for the last turn.

* Make the Thingiverse Customizer app work for this design. For that, create a "compilation" script that will combine this file with threads.scad.

* Fix that the continuous wall thickness at the neck is larger than wall_t, increasing the total outer diameter. This is because threads.scad does not make the radial extension of the thread accessible, and the current way of determining it in the code below is inaccurate. Either switch to a better thread library or fix the bug in threads.scad.

* Decrease thread height of the external thread by a small amount (0.5 mm) to make sure the end stop is between lid opening and body neck, not leaving any gap there, and not resulting in any pressure that could damage the top wall. Note that thread_gap does not require decreasing thread height: with the gap centered around a thread turn, there will be some play upwards when the lid hits the body's neck. But that play is removed by screwing on some more.

* Split the parameter wall_t for the minimum wall thickness into two: one for non-threaded walls, one for threaded walls. Because the latter are stabilized by the thread, they can be made thinner.

* Output relevant measures (outer dimensions, thread pitch etc.) when they have been calculated.

* Provide a parameter that allows a non-threaded part at the top of the neck section. This will allow to have sufficient lid height while avoiding too many turns to open and close the lid. It will also help with positioning to start screwing the lid on.

* Support several ways of adding a label to the bottle body. For example two chamfered edges that raise 0.5 mm over the outer surface and allow to place a paper label between them that reaches around the whole bottle and is taped fully around the bottle with clear tape. That allows removal without glue residue. The distance of these two edges should be configurable, to be adaptable to the width of clear tape that is used.

* Support a way to add a label to the top of the lid. Can be done by a round frame with slightly overhanging edges and an opening so that a round label with a short radial incision can be "spiraled in".

* Support to make the outer shape polygonal (so that the edges of lid and body align when the lid is closed). The number of plygon corners would be configurable. For example, a hexagonal bottle would be good to secure it against rolling away.

* Other TODO items as found in the code.
 