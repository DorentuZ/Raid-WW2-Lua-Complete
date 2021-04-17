core:import("CoreMissionScriptElement")

ElementHint = ElementHint or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 5-7
function ElementHint:init(...)
	ElementHint.super.init(self, ...)
end

-- Lines 9-11
function ElementHint:client_on_executed(...)
	self:on_executed(...)
end

-- Lines 13-24
function ElementHint:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if self._values.hint_id ~= "none" then
		-- Nothing
	elseif Application:editor() then
		managers.editor:output_error("Cant show hint " .. self._values.hint_id .. " in element " .. self._editor_name .. ".")
	end

	ElementHint.super.on_executed(self, instigator)
end
