/** @file 
  * @brief A registry for part dimensions, used for all designs in this library.
  * @details Keeping everything in one file is the simplest way to ensure we'll not have 
  *   conflicting definitions of `m()` when using `include <>` to import a base design. It also 
  *   allows any measure to depend on any other measure, since they are all defined here.
  * 
  * @todo To prevent measure ids from becoming too long, introduce a special variable 
  *   `$measures_context` that is evaluated in addition and, if set, provides a prefix 
  *   for the measure ID.
  */

/** @brief Provide any measure (that we know of) about this design. This acts as a 
  *   central registry for measures to not clutter the global namespace. "m" for "measure".
  *   Most numbers can be adjusted, allowing customization beyond the rather simple parameters in 
  *   the OpenSCAD Customizer. All measures have been taken by measuring an original Milwaukee 
  *   battery connector on a powertool. Different from the original, we only model a connector 
  *   for inserting a battery from one side.
  * @param id  String identifier of the dimension to retrieve. Look into the source to see 
  *   which are available.
  * @todo Add the positions and dimensions of the battery terminal connectors.
  */
function m(id) = (
    // Measures on the battery.
    id == "battery play d" ? 2.7 : // When the battery is in the socket.
    id == "battery snapper wide part total d" ? 6.5 :
    id == "battery snapper d" ? 14.1 :

    // Main measures on the battery socket.
    id == "w" ? 46.6 :
    id == "d" ? 77 :
    id == "side h" ? 14.8 :
    id == "corner radius w" ? m("middle section offset w"): // @todo rename to "h edges radius w"
    id == "corner radius d" ? 7.0 : // @todo rename to "h edges radius d"
    id == "outer edges r" ? 0.7 :   // @todo rename to "d edges radius"
    id == "backwall d min" ? 2.0 :
    id == "backwall d max" ? 3.9 :
    id == "backwall d" ? (m("backwall d min") + m("backwall d max")) / 2 :
    
    // Middle section, which is a separate part of the original Milwaukee battery socket.
    id == "middle section h" ? 12.8 :
    id == "middle section w" ? m("w") - 2 * m("lock grooves offset w") - 2 * m("lock grooves w") :
    id == "middle section offset w" ? (m("w") - m("middle section w")) / 2 :
    id == "middle section undercut h" ? 3.3 :
    id == "middle section undercut d" ? 12.6 :
    id == "middle section edge r" ? 0.5 :
    
    // Raised block on top of the middle section part, forming the highest point of the battery socket.
    id == "ridge w" ? 3.9 :
    id == "ridge d" ? 33.3 :
    id == "ridge h" ? 3.7 :
    id == "ridge offset w" ? m("w") / 2 - m("ridge w") / 2 :
    id == "ridge offset d" ? 21.4 :
    id == "ridge arcs d" ? 1.6 : // Unused. We simplify to a semi-circle arc via a radius the height edges, see below.
    id == "ridge h edges r" ? m("ridge w") / 2 : // Maximum possible corner radius, yielding a semi-circle at the ends.
    
    // Grooves on the left and right to mount the battery pack mechanically. Closer to the device than all other grooves.
    id == "mount grooves w" ? 3.7 :
    id == "mount grooves h" ? 6.9 :
    id == "mount grooves wall t" ? m("terminal grooves 1+3 offset w") - m("mount grooves w") :
    
    // The two grooves with the locking mechanism.
    id == "lock grooves w" ? 8.8 : // Full width, including lock block w.
    id == "lock grooves h" ? 3.8 :
    id == "lock grooves min d" ? 
        m("lock block offset d") + m("lock block d") + m("battery play d") + m("battery snapper d") :
    id == "lock grooves offset w" ? 3.3 :
    id == "lock grooves offset h" ? m("side h") - m("lock grooves h") :
    
    // Snap mechanism inside the snapper grooves.
    id == "lock block w" ? 2.6 :
    id == "lock block d" ? 15.2 :
    id == "lock block ramp d" ? 4.2 : // As part of "lock block d".
    id == "lock block offset d" ? 9.0 :
    
    // The three grooves before, in between and after the terminal block. 1-3 from left to right.
    id == "terminal grooves w" ? 3.4 :
    id == "terminal grooves 1+3 offset w" ? 8.7 : // Measured from the side face closest to each groove.
    id == "terminal grooves 1+3 d" ? m("middle section undercut d") :
    id == "terminal grooves 2 offset w" ? 19.5 :
    id == "terminal grooves 2 d" ? 19.1 :
    
    // The holes for the electrical terminal connectors, and these connectors.
    // "Outer" measures refer to the chamfer outline, not to the actual hole.
    id == "terminal holes w" ? 1.3 :
    id == "terminal holes h" ? 7.0 :
    id == "terminal holes min d" ? 13.0 : // To accommodate the terminals, which protrude 13 mm out of the casing.
    id == "terminal holes chamfer t" ? 0.9 :
    id == "terminal holes chamfer d" ? 2.0 :
    id == "terminal holes outer w" ? m("terminal holes w") + 2 * m("terminal holes chamfer t") :
    id == "terminal holes outer h" ? m("terminal holes h") + 2 * m("terminal holes chamfer t") :
    id == "terminal holes 1 outer offset w" ? 14.4 + 0.5 : // Measured in leftmost position, +0.5 mm moves it to the center.
    id == "terminal holes 2 outer offset w" ? 23.8 + 0.5 :
    id == "terminal holes 3 outer offset w" ? 29.5 + 0.5 :
    id == "terminal holes outer offset h" ? 3.6 :

    undef
);

assert(
    equals(
        m("terminal grooves 1+3 offset w") + m("terminal grooves w"),
        m("lock grooves w") + m("lock grooves offset w")
    ), 
    "Groove widths and wall thicknesses do not match between upper and lower section."
);
