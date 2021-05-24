# Milwaukee M28 Extras

# 1. Overview

This is an [OpenSCAD](https://www.openscad.org/) library of 3D printable parts and accessories for the Milwaukee M28 system of battery powertools. It is also compatible with the Milwaukee V28 system of battery powertools (which is an earlier generation but mechanically compatible) and the Würth 28 V system of battery powertools, which is a whitelabeled version of the Milwaukee M28 system.

I started this because I needed parts and modifications to use these powertools in a mobile 24 V DC based workshop in an expedition truck. And there was basically nothing available for this system [on Thingiverse](https://www.thingiverse.com/search?q=Milwaukee+M28&type=things&sort=relevant) or anywhere else online, unlike for most other powertool systems. For example, there are 99 designs available [on Thingiverse](https://www.thingiverse.com/search?q=Milwaukee+M18&type=things&sort=relevant&page=4) for the Milwaukee M18 powertool system.

I hope this repository will become the central, well integrated source for all free M28 accessories and mods – which means, you're welcome to contribute your parts here.


# 2. Installation and Usage

[@todo]

1. **Install the Round-Anything library.** 

    1. Go to the built-in library location of OpenSCAD. Depending on your operating system, it will be one of these commands [according to the manual](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Libraries#Library_Locations):

        ```
        For Windows:   cd My Documents\OpenSCAD\libraries
        For Linux:     cd $HOME/.local/share/OpenSCAD/libraries
        For macOS:     cd $HOME/Documents/OpenSCAD/libraries
        ```

    2. Clone the library repository:

        ```
        git clone https://github.com/Irev-Dev/Round-Anything.git
        ```

2. **Clone this repository.** In any location of your choice, execute:

    ```
    git clone https://github.com/tanius/milwaukee-m28-extras.git
    ```

3. **Use in OpenSCAD.** It's the normal OpenSCAD workflow from here. You open the `.scad` file of a design you want to adapt and / or print, configure it in OpenSCAD Customizer, adapt the source code, preview and render and, then export it to `.stl` format and 3D print it from there.


# 3. Remaining Work

To-do items for individual designs are listed at the top of their `.scad` file. Here are to-do items for the project in more general:

* Create a system that will automatically regenerate the STL files if needed, using the "final rendering" Customizer setting and OpenSCAD command line calls.
* Add an overview image into `README.md`, showing the parts contained in this repository. Ideally it should be possible to re-generate this automatically with a script that calls OpenSCAD on the command line.
* Generate the API documentation from the `.scad` files and include it here into `README.md`.
* Create a system to configure part colors globally. Either put the colors into `measures.scad` or create a file `constants.scad` for this and similar purposes.


# 4. License and Credits

**Licenses.** This repository exclusively contains material under free software licencses and open content licenses. All files are provided under the Unlicense, except where explicitly stated otherwise for a specific file in the header of that file. See [LICENSE.md](https://github.com/fairdirect/foodrescue-app/blob/master/LICENSE.md) for details about Unlicense.

**Credits, third-party licenses.** Within the rights granted by the applicable licenses, this repository contains works of the following open source projects, authors or groups, which are hereby credited for their contributions and for holding the copyright to their contributions.

* **[Round-Anything](https://github.com/Irev-Dev/Round-Anything/).** Provides a great framework for creating parts in OpenSCAD with radii and fillets, and can also be used as a general approach to create OpenSCAD parts. Of this, we use only `polyround.scad`. Round-Anything is provided under the [MIT license](https://github.com/Irev-Dev/Round-Anything/blob/master/LICENSE).

* **[IQAndreas/markdown-licenses](https://github.com/IQAndreas/markdown-licenses).** Provides original open source licenses in Markdown format. The LICENSE.md file uses one of them.