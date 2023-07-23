local config  = require 'telescope.config'.values
local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local actions = require 'telescope.actions'
local state   = require 'telescope.actions.state'

local function list_configurations()
    local result = {}
    local index = 1
    for key, value in pairs(vim.g.shell.configurations) do
        value.value = vim.fn['shell#'..key]
        result[index] = vim.tbl_extend('force', value, {
            display = value.name,
            ordinal = key,
        })
        index = index + 1
    end
    return result
end

local function picker(options, results)
    return pickers.new(options, {
        propmpt_title = 'Shell configurations',
        finder = finders.new_table {
            results = results,
            entry_maker = function (entry)
                return entry
            end
        },
        previewer = config.grep_previewer(options),
        sorter = config.generic_sorter(options),
        attach_mappings = function (prompt_bufnr, map)
            map({ 'i', 'n' }, '<c-]>', actions.select_default)
            map({ 'i', 'n' }, '<cr>', function ()
                actions.close(prompt_bufnr)
                local selection = state.get_selected_entry()
                if selection.self then
                    selection.value(selection)
                else
                    selection.value()
                end
            end)
            return true
        end,
    })
end

return require 'telescope'.register_extension {
    exports = {
        configurations = function (options)
            picker(options or {}, list_configurations()):find()
        end
    },
}

