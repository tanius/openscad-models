/** @file 
 *  @brief A registry for part dimensions, used for all designs in this library. All measures 
 *    are in mm resp. degrees.
 *  @details Keeping everything in one file is the simplest way to ensure we'll not have 
 *    conflicting definitions of `m()` when using `include <>` to import a base design. It also 
 *    allows any measure to depend on any other measure, since they are all defined here.
 */

 // Default part context for the m(…) calls. Defined here to prevent "unknown variable $part".
$part = undef;

/** @brief Provide any measure (that we know of) about this design. This acts as a 
  *   central registry for measures to not clutter the global namespace. "m" for "measure".
  *   Most numbers can be adjusted, allowing customization beyond the rather simple parameters in 
  *   the OpenSCAD Customizer. All measures have been taken by measuring an original Milwaukee 
  *   battery connector on a powertool. Different from the original, we only model a connector 
  *   for inserting a battery from one side.
  * @param id  String identifier of the dimension to retrieve. Look into the source to see 
  *   which are available.
  * @param part  A string identifying the part for which the measure ID is specified. If not given, 
  *   the value will be taken from special variable `$part`. This allows you to set a default 
  *   part context as `$part = …;` for all subsequent `m()` calls in a file, or as `let($part = …)`
  *   for a few subsequent calls. For any of these calls, you can override the part context using 
  *   `m(part = "{partname}", "{id}").
  */
function m(id, part = $part) = (
    // Measures on the battery.
    part == "battery" && id == "play d" ? 2.7 : // When the battery is in the socket.
    part == "battery" && id == "snapper wide part total d" ? 6.5 :
    part == "battery" && id == "snapper d" ? 14.1 :

    // Main measures on the battery socket.
    part == "socket" && id == "w" ? 46.6 :
    part == "socket" && id == "d" ? 77 :
    part == "socket" && id == "side h" ? 14.8 :
    part == "socket" && id == "corner radius w" ? m(part = "socket", "middle section offset w"): // @todo rename to "h edges radius w"
    part == "socket" && id == "corner radius d" ? 7.0 : // @todo rename to "h edges radius d"
    part == "socket" && id == "outer edges r" ? 0.7 :   // @todo rename to "d edges radius"
    part == "socket" && id == "backwall d min" ? 2.0 :
    part == "socket" && id == "backwall d max" ? 3.9 :
    part == "socket" && id == "backwall d" ? (m(part = "socket", "backwall d min") + m(part = "socket", "backwall d max")) / 2 :
    
    // Middle section, which is a separate part of the original Milwaukee battery socket.
    part == "socket" && id == "middle section h" ? 12.8 :
    part == "socket" && id == "middle section w" ? m(part = "socket", "w") - 2 * m(part = "socket", "lock grooves offset w") - 2 * m(part = "socket", "lock grooves w") :
    part == "socket" && id == "middle section offset w" ? (m(part = "socket", "w") - m(part = "socket", "middle section w")) / 2 :
    part == "socket" && id == "middle section undercut h" ? 3.3 :
    part == "socket" && id == "middle section undercut d" ? 12.6 :
    part == "socket" && id == "middle section edge r" ? 0.5 :
    
    // Raised block on top of the middle section part, forming the highest point of the battery socket.
    part == "socket" && id == "ridge w" ? 3.9 :
    part == "socket" && id == "ridge d" ? 33.3 :
    part == "socket" && id == "ridge h" ? 3.7 :
    part == "socket" && id == "ridge offset w" ? m(part = "socket", "w") / 2 - m(part = "socket", "ridge w") / 2 :
    part == "socket" && id == "ridge offset d" ? 21.4 :
    part == "socket" && id == "ridge arcs d" ? 1.6 : // Unused. We simplify to a semi-circle arc via a radius the height edges, see below.
    part == "socket" && id == "ridge h edges r" ? m(part = "socket", "ridge w") / 2 : // Maximum possible corner radius, yielding a semi-circle at the ends.
    
    // Grooves on the left and right to mount the battery pack mechanically. Closer to the device than all other grooves.
    part == "socket" && id == "mount grooves w" ? 3.7 :
    part == "socket" && id == "mount grooves h" ? 6.9 :
    part == "socket" && id == "mount grooves wall t" ? m(part = "socket", "terminal grooves 1+3 offset w") - m(part = "socket", "mount grooves w") :
    
    // The two grooves with the locking mechanism.
    part == "socket" && id == "lock grooves w" ? 8.8 : // Full width, including lock block w.
    part == "socket" && id == "lock grooves h" ? 3.8 :
    part == "socket" && id == "lock grooves min d" ? 
        m("lock block offset d") + m("lock block d") + m(part = "battery", "play d") + m(part = "battery", "snapper d") :
    part == "socket" && id == "lock grooves offset w" ? 3.3 :
    part == "socket" && id == "lock grooves offset h" ? m(part = "socket", "side h") - m(part = "socket", "lock grooves h") :
    
    // Snap mechanism inside the snapper grooves.
    part == "socket" && id == "lock block w" ? 2.6 :
    part == "socket" && id == "lock block d" ? 15.2 :
    part == "socket" && id == "lock block ramp d" ? 4.2 : // As part of "lock block d".
    part == "socket" && id == "lock block offset d" ? 9.0 :
    
    // The three grooves before, in between and after the terminal block. 1-3 from left to right.
    part == "socket" && id == "terminal grooves w" ? 3.4 :
    part == "socket" && id == "terminal grooves 1+3 offset w" ? 8.7 : // Measured from the side face closest to each groove.
    part == "socket" && id == "terminal grooves 1+3 d" ? m(part = "socket", "middle section undercut d") :
    part == "socket" && id == "terminal grooves 2 offset w" ? 19.5 :
    part == "socket" && id == "terminal grooves 2 d" ? 19.1 :
    
    // The holes for the electrical terminal connectors, and these connectors.
    // "Outer" measures refer to the chamfer outline, not to the actual hole.
    part == "socket" && id == "terminal holes w" ? 1.3 :
    part == "socket" && id == "terminal holes h" ? 7.0 :
    part == "socket" && id == "terminal holes min d" ? 13.0 : // To accommodate the terminals, which protrude 13 mm out of the casing.
    part == "socket" && id == "terminal holes chamfer t" ? 0.9 :
    part == "socket" && id == "terminal holes chamfer d" ? 2.0 :
    part == "socket" && id == "terminal holes outer w" ? m(part = "socket", "terminal holes w") + 2 * m(part = "socket", "terminal holes chamfer t") :
    part == "socket" && id == "terminal holes outer h" ? m(part = "socket", "terminal holes h") + 2 * m(part = "socket", "terminal holes chamfer t") :
    part == "socket" && id == "terminal holes 1 outer offset w" ? 14.4 + 0.5 : // Measured in leftmost position, +0.5 mm moves it to the center.
    part == "socket" && id == "terminal holes 2 outer offset w" ? 23.8 + 0.5 :
    part == "socket" && id == "terminal holes 3 outer offset w" ? 29.5 + 0.5 :
    part == "socket" && id == "terminal holes outer offset h" ? 3.6 :

    // Overhang of a powertool over its battery socket outline.
    // Measured at the jigsaw. Might be different for other powertools.
    part == "device" && id == "base w" ? 52 :
    part == "device" && id == "base d" ? 89.5 :
    part == "device" && id == "front overhang d" ? m(part = "device", "base d") - m(part = "device", "back overhang d") - m(part = "socket", "d") :
    part == "device" && id == "back overhang d" ? 1.5 :
    part == "device" && id == "side overhang w" ? (m(part = "device", "base w") - m(part = "socket", "w")) / 2 :

    // Measures on the battery isolator, a blind socket to protect battery terminals.
    part == "isolator" && id == "cover h" ? 4 :

    undef
);

assert(
    let($part = "socket") equals(
        m("terminal grooves 1+3 offset w") + m("terminal grooves w"),
        m("lock grooves w") + m("lock grooves offset w")
    ),
    "Groove widths and wall thicknesses do not match between upper and lower section."
);
