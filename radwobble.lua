local api, tasks = {}, {}

local function serialize(vec3)
	return table.concat({vec3:unpack()}, "_")
end

local function toRootSpace(vec3, chld)
	return matrices.translate4(vec3):rotate(chld:getRot() * -1):apply()
end

local function isInTable(value, tbl)
	for i = 1, #tbl do if value == tbl[i] then return true end end
end

local function groupMeshVertices(mesh)
	local tbl, vertices = {}, mesh:getAllVertices()[mesh:getTextures()[1]:getName()]
	for _, vert in pairs(vertices) do
		local id = serialize(vert:getPos())
		if not tbl[id] then tbl[id] = {} end
		table.insert(tbl[id], vert)
	end
	return tbl
end

local function createVertexNodes(mdl, _vertices, exclude)
	local vertices = _vertices or {}
	for _, chld in pairs(mdl:getChildren()) do
		local chldType = chld:getType()
		if chldType ~= "GROUP" then
			for _, vertex in pairs(groupMeshVertices(chld)) do
				table.insert(vertices, {
					vertex = vertex,
					anchor = vertex[1]:getPos(),
					parent = chld
				})
			end
		else
			if not isInTable(chld:getName(), exclude) then
				table.insert(vertices, {
					vertex = {chld},
					anchor = chld:getPivot(),
					parent = chld
				})
			end
			createVertexNodes(chld, vertices, exclude)
		end
	end
	return vertices
end

function api.new(model, k, m, d, exclude)
	local nodes = createVertexNodes(model, nil, exclude or {})
	for _, node in ipairs(nodes) do
		node.spring, node.queue = {
			vel = vec(0, 0, 0),
			v = vec(0, 0, 0),
			active = 0,
			old = vec(0, 0, 0),
			eq = vec(0, 0, 0),
			k = k,
			m = m,
			d = d
		}, {}
	end
	tasks[model:getName()] = nodes
end

function api.applyFunc(model, pos, t, func)
	for _, node in ipairs(tasks[model:getName()]) do
		local f = toRootSpace(func(pos, node.anchor), node.parent)
		if f:length() > 0 then
			table.insert(node.queue, {
				force = f,
				timer = (pos - node.anchor):length() * t
			})
		end
	end
end

function api.remove(model)
	for _, node in pairs(tasks[model:getName()]) do
		for i = 1, #node.vertex do node.vertex[i]:pos(node.anchor) end
	end
	tasks[model:getName()] = nil
end

function events.tick()
	for _, task in pairs(tasks) do
		for _, node in pairs(task) do
			local s = node.spring
			if s.active > 0 then
				local force = -s.k * s.v - s.eq
				local accel = force / s.m
				s.vel = (s.vel + accel) * (1 - s.d)
				s.old = s.v
				s.v = s.v + s.vel
				if s.v:length() < .1 then s.active = s.active - 1 end
			end
			for k, a in pairs(node.queue) do
				if a.timer < 1 then
					s.v = s.v - a.force
					s.active = 20
					node.queue[k] = nil
				else
					a.timer = a.timer - 1
				end
			end
		end
	end
end

function events.render(delta, context)
	if context ~= "PAPERDOLL" then
		for _, task in pairs(tasks) do
			for _, node in ipairs(task) do
				if node.spring.active > 0 then
					local anchor = #node.vertex > 1 and node.anchor or 0
					for j = 1, #node.vertex do
						node.vertex[j]:pos(math.lerp(node.spring.old + anchor, node.spring.v + anchor, delta))
					end
				end
			end
		end
	end
end

return api