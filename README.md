# LDS Jam Development README

This readme lists the steps required to properly create/modify key freatures of the game.
I would love to make them all automated with single sources of truth, but I don't know
enough about Godot. Plus this is a game jam it is allowed to be a bit jank.

## Dream
A `Dream` is a special subclass of `Node3D` when you create a new scene you can specifically set the root nodes type to be a `Dream`. The logic is defined in `res://dreams/dream.gd`. DreamLinks have to refer to scenes with dreams as the root node due to specific signals defined for `Dream` nodes.

## Dream Link
DreamLinks are a custom resource defined in `res://dreams/dream_link.gd` you can create
a dreamlink in editor or if it will be used by multiple dream doors it can be saved to
disk and externally referenced.

### Link Location
Once you've created the DreamLink the most important step is to set the 'dream' property.
This is the path of the target dream's packed scene. The other key properties is the 'location',
'pitch', 'yaw', and 'scale' properties which all modify how/where the player should appear in the
linked dream. These are static values for now, but once we get more into how the weight system works
we might add the ability for these to dynamically change with the weights.

### Weight Modifiers
The link can also modify the player's `dream weights` which control what appears in dreams, and what dreams can be reached. The link uses a `WeightModifiers` object which has it's own section below. The

**Adding new weights is the most error prone process and is detailed in its own section.**

## Dream Door
DreamDoors are special subclasses of Area3D objects. Their logic is defined in `res://dreams/dream_door.gd`, and the copyable scene (prefab) is `res://dreams/dream_door.tscn`. To create a new dream door drag the scene file from the directory tree tab into the relevant scene tree. If you try create a `DreamDoor` node directly it will have missing configuration so don't.

Once the dream door is created there are three steps to correctly setup the door
1) Give the door a DreamLink. You can either create a new one or through the quickload you can select an existing DreamLink
2) Give the door a CollisionShape3D or CollisionPolygon3D. This is required for the player to actually interact with the door
3) Connect the DreamDoor's `navigate_dream` signal to the root `Dream` node. If this isn't done the door will detect the collision but the navigation system won't know to load the new dream.

You can also set the dream door to ignore players clicking on them and/or ignore players walking into them.

(Currently the dream door handles the modification of the dream weights. This means even a disconnected door will still modify them. I think this is a mistake, but I'm unsure of the best place as of yet.)

### Weight Modifiers
Just like DreamLink's each DreamDoor has it's own `WeightModifiers` resource.

**Adding new weights is the most error prone process and is detailed in its own section.**

## WeightModifiers
Each `WeightModifiers` object describes how much to modify each weight by and how to modify it. The actual weights are saved in a `SaveData` resource held by an autoloaded singleton called `DataManager`. `WeightModifiers` have a method `update_weights` that takes in a `SaveData` object. However the proper way to update the weights of the current dream is to use the `DataManager.update_weights` method as this also outputs a signal that objects can connect to. The logic for `WeightModifiers` can be found in `res://dreams/dream_weights.gd`

## Dream Fragments

I have not yet implemented them yet, but the logic will be in `res://dream_fragment.gd`.
They are the collectable in the game, and also a generic flag object. So if you want something to persist between save/loads, and between entering and exiting a dream you can use a dream fragment
stored in the player's save data to check.

## Adding new weightss

This is mostly for my sake, but the steps to adding a new weight modifier are:
1) Create a new \<weight\>_changed signal, and \<weight\> property with a custom setter method in `res://save_data.gd`
2) Add a new \<weight\>_changed signal to `res://singletons/autoload/data_manager.gd`
3) Add that signal to the `_connect_save_signals` and `_disconnect_save_signals` methods
4) Add the new weight and its modification method to `res://dream/dream_weights.gd`
5) Add the new weight to the `WeightModifiers.update_weights` method

