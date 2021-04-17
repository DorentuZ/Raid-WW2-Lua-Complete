RaidGUIControlTableCell = RaidGUIControlTableCell or class(RaidGUIControlLabel)
RaidGUIControlTableCell.FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlTableCell.FONT_SIZE = tweak_data.gui.font_sizes.small

-- Lines 6-19
function RaidGUIControlTableCell:init(parent, params, row_data, table_params)
	params.font = params.font or RaidGUIControlTableCell.FONT
	params.font_size = params.font_size or RaidGUIControlTableCell.FONT_SIZE

	RaidGUIControlTableCell.super.init(self, parent, params)

	self._table_params = table_params
	self._data = {
		value = params.value
	}
end

-- Lines 21-34
function RaidGUIControlTableCell:highlight_on()
	if alive(self._object) and self._table_params and self._table_params.row_params and self._table_params.row_params.color and self._table_params.row_params.highlight_color then
		self._object:set_color(tweak_data.gui.colors.raid_table_cell_highlight_on)
	end
end

-- Lines 36-46
function RaidGUIControlTableCell:highlight_off()
	if alive(self._object) and self._table_params and self._table_params.row_params and self._table_params.row_params.color and self._table_params.row_params.highlight_color then
		self._object:set_color(tweak_data.gui.colors.raid_table_cell_highlight_off)
	end
end

-- Lines 48-55
function RaidGUIControlTableCell:select_on()
	if alive(self._object) and self._params.selected_color and self._params.color then
		self._object:set_color(tweak_data.gui.colors.raid_red)
	end
end

-- Lines 57-64
function RaidGUIControlTableCell:select_off()
	if alive(self._object) and self._params.selected_color and self._params.color then
		self._object:set_color(self._params.color)
	end
end

-- Lines 66-70
function RaidGUIControlTableCell:on_double_click(button)
	if self._params.on_double_click_callback then
		self._params.on_double_click_callback(button, self, self._data)
	end
end
