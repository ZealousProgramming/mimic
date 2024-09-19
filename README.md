# mimic

A godot plugin for mimicking an embedded game view in the editor.

## Disclaimer

This is a scuffed implementation whose purpose is to provide a fairly minimal benefit in developer experience. This is currently a GDScript plugin, and could ported to C++ in the future.

## How does it work

Mimic, as the name may hint towards, doesn't actually embed the game view into the editor. It simply mimics the behavior by using the already existing debugger to send messages to and from the editor and game process. The thought was to initially setup this connection manually, but taking advantage of the built-in debugger is incredibly simple and allowed for this to be created in just a few hours with no prior experience with it.

## Usage

- Clone the repo
- Merge the `addons` folder with your project's `addons`
  - `root/`
    - `addons/`
    - `mimic/`
    - `mimic_plugin.gd`
    - `etc`
    - `other_plguins/`
- Enable the `mimic` plugin in the project settings
- Drop `Mimic.tscn` into your root scene, or create a `Node` and attach the `mimic.gd` script
- A checkbox will be beside the play scene/stop toolbar, this will control whether it should mimic an embedded game view or not.
