# radwobble (radial wobble) v0.1
Figura spring library that applies to individual model vertices.

# Installation

- 1: Download and Extract the .zip containing an example avatar or download the standalone script.
- 2: Take the script and move it to your desired avatars folder.
- 3: Go to `script.lua` or any script you may have set to run automatically and insert the following snippet. (Recommended to include at the beginning of your script.)
```lua
local radwobble = require("radwobble")
 ```
- 4: 🦠

# Documentation

## new(model, kinetic, mass, dampen)
- ``model``: Model to apply spring physics to. Will not apply forces to groups themselves, instead just the vertices of ModelParts.
- ``kinetic, mass, dampen``: Range from 0 - 1. Try experimenting with these values to get the spring you desire.

> [!WARNING]
> Models with higher complexity will naturally lead to higher render and tick instruction counts, which makes this script not viable for permission levels below High/MAX.

## apply(model, pos, f, rad)
- ``model``: Model to apply force to.
- ``pos``: Centerpoint of the radial force.
- ``f``: Strength or amplitude of radial force. Can be either Vector3 or a number.
- ``rad``: Artificially tweak the force applied. Ranges from 0 - 1; 0: Normal force, 1: Maxed out. If nil, will default to 0.

> [!NOTE]
> Forces using Vector3s as their value are not linear, but radial relative to ``pos``. This can be mediated by setting ``rad`` to 1, which will treat the force as a scale vector with ``pos`` as its pivot.

## remove(model)
- ``model``: Remove physics from this model.

# Example

```lua
vanilla_model.PLAYER:setVisible(false)
local radwobble = require("radwobble")
radwobble.new(models.model, .8, 1, .2)

function events.tick()
	radwobble.apply(models.model, vec(0, 8, 0), player:getVelocity() * -16)
end
```
