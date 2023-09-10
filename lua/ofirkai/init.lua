---@mod ofirkai Introduction
---@brief [[
---Monokai theme
---@brief ]]
---@divider -
local M = {}

local design = require('ofirkai.design')

local function highlight(group, color)
	local style = color.style and 'gui=' .. color.style or 'gui=NONE'
	local fg = color.fg and 'guifg = ' .. color.fg or 'guifg = NONE'
	local bg = color.bg and 'guibg = ' .. color.bg or 'guibg = NONE'
	local sp = color.sp and 'guisp = ' .. color.sp or ''
	vim.cmd('highlight ' .. group .. ' ' .. style .. ' ' .. fg .. ' ' .. bg .. ' ' .. sp)
end

local function filter_hl_groups(config, hl_groups)
	for _, colors in pairs(hl_groups) do
		if config.remove_italics then
			if colors.italic then
				colors.italic = false
			end
		end
	end

	return hl_groups
end

local default_config = {
	scheme = design.scheme,
	custom_hlgroups = {},
	remove_italics = false,
	theme = nil,
}

---@param config table user config
---@usage [[
-----Leave empty for default values
---require('ofirkai').setup {
---}
---
----- Or setup with custom parameters
---require('ofirkai').setup {
---	scheme = require('ofirkai').scheme -- Option to override scheme
---	custom_hlgroups = {},              -- Option to add/override highlight groups
---	remove_italics = false,            -- Option to change all the italics style to none
---}
---@usage ]]
M.setup = function(config)
	vim.cmd('hi clear')
	if vim.fn.exists('syntax_on') then
		vim.cmd('syntax reset')
	end
	vim.o.background = 'dark'
	vim.o.termguicolors = true
	vim.g.colors_name = 'ofirkai'

	local theme = nil

	if config.theme then
		theme = require('ofirkai.themes.' .. config.theme)
	end

	config = config or {}
	config = vim.tbl_deep_extend('keep', config, default_config)
	M.scheme = config.scheme
	if theme then
		M.scheme = vim.tbl_deep_extend('keep', theme.scheme, M.scheme)
	end
	design.scheme = M.scheme

	local hl_groups = design.hl_groups(M.scheme)
	hl_groups = vim.tbl_deep_extend('keep', config.custom_hlgroups, hl_groups)
	if theme then
		hl_groups = vim.tbl_deep_extend('keep', theme.hl_groups(M.scheme), hl_groups)
	end

	hl_groups = filter_hl_groups(config, hl_groups)

	for group, colors in pairs(hl_groups) do
		if colors.ctermfg then
			highlight(group, colors)
		else
			vim.api.nvim_set_hl(0, group, colors)
		end
	end
end

---Alias for require('ofirkai.design').scheme
---@type table
M.scheme = design.scheme

return M
