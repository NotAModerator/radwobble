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

## new(model, mass, springiness, dampen)
- ``model``: Model to apply spring physics to. Will not apply forces to groups themselves, instead just the vertices of ModelParts.
- ``mass``: How dense the model is.
- ``springiness``: Amount that each vertex oscillates by.
- ``dampen``: How much to dampen the spring movement each oscillation.

> [!WARNING]
> Models with higher complexity will naturally lead to higher render and tick instruction counts, which makes this script not viable for permission levels below High/MAX.

## apply(model, pos, f, rad)
- ``model``: Model to apply force to.
- ``pos``: Centerpoint of the radial force.
- ``f``: Strength or amplitude of radial force. Can be either Vector3 or a number.

> [!NOTE]
> Forces using Vector3s as their value are not linear, but radial relative to ``pos``.

## applyLinear(model, f)
- ``model``: Model to apply force to.
- ``f``: Strength of the force to apply linearly. Will work similar to scaling the model, but will react to previous radial forces.

## remove(model)
- ``model``: Remove physics from this model.

# Example

```lua
vanilla_model.PLAYER:setVisible(false)
local radwobble = require("radwobble")
radwobble.new(models.model, .8, 1, .2)

--apply physics to models.model, with a centerpoint and force based on the player's velocity
function events.tick()
	radwobble.apply(models.model, vec(0, 4, 0) + player:getVelocity() * 16, player:getVelocity() * 256)
end
```
