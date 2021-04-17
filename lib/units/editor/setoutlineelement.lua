SetOutlineElement = SetOutlineElement or class(MissionElement)

-- Lines 3-11
function SetOutlineElement:init(unit)
	SetOutlineElement.super.init(self, unit)

	self._hed.elements = {}
	self._hed.set_outline = true

	table.insert(self._save_values, "elements")
	table.insert(self._save_values, "set_outline")
end

-- Lines 15-28
function SetOutlineElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local names = {
		"ai_spawn_enemy",
		"ai_spawn_civilian"
	}

	self:_build_add_remove_unit_from_list(panel, panel_sizer, self._hed.elements, names)

	local set_outline = EWS:CheckBox(panel, "Enable outline", "")

	set_outline:set_value(self._hed.set_outline)
	set_outline:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "set_outline",
		ctrlr = set_outline
	})
	panel_sizer:add(set_outline, 0, 0, "EXPAND")
end

-- Lines 32-34
function SetOutlineElement:draw_links(t, dt, selected_unit, all_units)
	MissionElement.draw_links(self, t, dt, selected_unit, all_units)
end

-- Lines 36-37
function SetOutlineElement:update_editing()
end

-- Lines 40-48
function SetOutlineElement:update_selected(t, dt, selected_unit, all_units)
	for _, id in ipairs(self._hed.elements) do
		local unit = all_units[id]
		local draw = not selected_unit or unit == selected_unit or self._unit == selected_unit

		if draw then
			self:_draw_link({
				g = 0.5,
				b = 1,
				r = 0.9,
				from_unit = self._unit,
				to_unit = unit
			})
		end
	end
end

-- Lines 50-62
function SetOutlineElement:add_element()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "editor",
		mask = 10
	})

	if ray and ray.unit and (string.find(ray.unit:name():s(), "ai_spawn_enemy", 1, true) or string.find(ray.unit:name():s(), "ai_spawn_civilian", 1, true)) then
		local id = ray.unit:unit_data().unit_id

		if table.contains(self._hed.elements, id) then
			table.delete(self._hed.elements, id)
		else
			table.insert(self._hed.elements, id)
		end
	end
end

-- Lines 64-70
function SetOutlineElement:remove_links(unit)
	for _, id in ipairs(self._hed.elements) do
		if id == unit:unit_data().unit_id then
			table.delete(self._hed.elements, id)
		end
	end
end

-- Lines 73-75
function SetOutlineElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_element"))
end
