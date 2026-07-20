--radwobble v0.2
local api, tasks = {}, {}

local function getVertexGroups(cube)
	local vertices = nil
	for i = 1, #cube:getTextures() do
		vertices = vertices or cube:getAllVertices()[cube:getTextures()[i]:getName()]
	end
	return {
		{
			vertices[1],
			vertices[10],
			vertices[22]
		},
		{
			vertices[2],
			vertices[13],
			vertices[21]
		},
		{
			vertices[3],
			vertices[16],
			vertices[20]
		},
		{
			vertices[4],
			vertices[19],
			vertices[11]
		},
		{
			vertices[5],
			vertices[14],
			vertices[24]
		},
		{
			vertices[6],
			vertices[9],
			vertices[23]
		},
		{
			vertices[7],
			vertices[12],
			vertices[18]
		},
		{
			vertices[8],
			vertices[17],
			vertices[15]
		}
	}
end

local function createVertexNodes(mdl, _tbl, exclude)
	local tbl = _tbl or {}
	for _, v in pairs(mdl:getChildren()) do
		if v:getType() ~= "GROUP" then
			for _, vertex in ipairs(getVertexGroups(v)) do
				table.insert(tbl, {
					vertex = vertex,
					anchor = vertex[1]:getPos()
				})
			end
		else
			if not exclude[v:getName()] then
				table.insert(tbl, {
					vertex = {v},
					anchor = v:getPivot(),
					isGroup = true
				})
			end
			createVertexNodes(v, tbl, exclude)
		end
	end
	return tbl
end

local function sign(x)
	return x > 0 and 1 or x < 0 and -1 or 0
end

function api.new(mdl, k, m, d, exclude)
	local _exclude, tbl = exclude or {}, {}
	for i = 1, #_exclude do tbl[_exclude[i]] = true end
	local vert = createVertexNodes(mdl, nil, tbl)
	local spring = {}
	for i = 1, #vert do 
		table.insert(spring, {
			vel = vec(0, 0, 0),
			v = vec(0, 0, 0),
			old = vec(0, 0, 0),
			active = false,
			timeInactive = 0
		})
	end
	tasks[mdl:getName()] = {
		vert = vert,
		spring = spring,
		eq = vec(0, 0, 0),
		k = k,
		m = m,
		d = d
	}
end

function api.apply(mdl, pos, f)
	if not tasks[mdl:getName()] then return end
	if f == 0 or f == vec(0, 0, 0) then return end
	local vert = tasks[mdl:getName()].vert
	for i, v in ipairs(tasks[mdl:getName()].spring) do
		local len =  vert[i].anchor - pos
		local amp = (1 - len:length() / vert[i].anchor:length())
		local dir = vec(sign(len.x), sign(len.y), sign(len.z))
		v.v = v.v - (f * (amp < 0 and 0 or amp) * dir)
		v.active, v.timeInactive = true, 0
	end
end

function api.applyLinear(mdl, f)
	if not tasks[mdl:getName()] then return end
	if f == 0 or f == vec(0, 0, 0) then return end
	local vert = tasks[mdl:getName()].vert
	for i, v in ipairs(tasks[mdl:getName()].spring) do 
		v.v = v.v + vert[i].anchor * f 
		v.active, v.timeInactive = true, 0
	end
end

function api.remove(mdl)
	for _, vertex in pairs(tasks[mdl:getName()].vert) do
		for i = 1, #vertex.vertex do vertex.vertex[i]:pos(vertex.anchor) end
	end
	tasks[mdl:getName()] = nil
end

function events.tick()
	for k, v in pairs(tasks) do
		for i, s in pairs(v.spring) do
			if s.active then
				local displacement = s.v - v.eq
				local force = (v.k * -1) * displacement
				local accel = (force / v.m)
				s.vel = (s.vel + accel) * (1 - v.d)
				s.old = s.v
				s.v = s.v + s.vel
				if math.floor(s.v:length()) == 0 then
					s.timeInactive = s.timeInactive + 1
					if s.timeInactive > 40 then
						s.active = false
					end
				end
			end
		end
	end
end

function events.render(delta, context)
	if context ~= "PAPERDOLL" then
		for _, v in pairs(tasks) do
			local spring = v.spring
			for i, vert in ipairs(v.vert) do
				if spring[i].active then
					for j = 1, #vert.vertex do 
						vert.vertex[j]:pos(math.lerp(v.spring[i].old, v.spring[i].v, delta) + (not vert.isGroup and vert.anchor or 0))
					end
				end
			end
		end
	end
end

return api