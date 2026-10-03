# radwobble v1.0
Figura script for achieving per-vertex slime physics!

# Installation
- 1: Download and Extract the .zip containing an example avatar or download the standalone script.
- 2: Take the script and move it to your desired avatars folder.
- 3: Go to `script.lua` or any script you may have set to run automatically and insert the following snippet. (Recommended to include at the beginning of your script.)
```lua
local radwobble = require("radwobble")
 ```
- 4: 🦠

# Documentation
## new(model, k, m, d, exclude)
- ``model``: Model to apply spring physics to. Will not apply forces to groups themselves, instead just the vertices of ModelParts.
- ``k``: How stiff the springs should be.
- ``m``: Mass of the model.
- ``d``: How much to dampen spring movement by over time.
- ``exclude``: Table containing the names of modelParts you wish to not apply physics to.

> [!WARNING]
> Higher complexity models will increase the overall instruction count while this script is active, so exercise caution on permissions lower than MAX.

## applyFunc(model, pos, t, func)
- ``model``: Model to apply force to.
- ``pos``: Centerpoint of the force.
- ``t``: Factor to multiply delay based on vertex distance from ``pos``.
- ``func``: Function that accepts two arguments: ``pos`` and ``anchor``.
  - ``pos``: Same as applyFunc's argument.
  - ``anchor``: The position of the vertex itself.

## remove(model)
- ``model``: Remove physics from this model.

# Example

```lua
vanilla_model.ALL:visible(false)
local radwobble = require("radwobble")

--create new effect
radwobble.new(models.model, .8, 1, .2, {"bone"})

--get player velocity and adjust to match player rotation, and apply-
--velocity * 16 (worldspace) and scaling based on crouch state
function events.tick()
	local vel = vectors.rotateAroundAxis((player:getRot().y + 180) % 360 - 180, player:getVelocity(), vec(0, 1, 0))
	radwobble.applyFunc(models.model, vec(0, -2, 0), .2, function(_, anchor) 
		return (vel * 16) + (player:isCrouching() and anchor * vec(-1, 1, -1) or 0)
	end)
end
```
