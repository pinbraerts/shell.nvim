local config  = require 'telescope.config'.values
local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local actions = require 'telescope.actions'
local state   = require 'telescope.actions.state'
local display = require 'telescope.pickers.entry_display'

local displayer = display.create {
    separator = ' ',
    items = {
        { width = 1 },
        { remainig = true },
    },
}

local function make_displayer(entry)
    return displayer {
        { entry.selected and '*' or ' ' },
        { entry.name, 'TelescopeResultsIdentifier', },
    }
end

local function list()
    local result = {}
    local index = 1
    for key, value in pairs(vim.g.shell.configurations) do
        value.value = vim.fn['shell#'..key]
        result[index] = vim.tbl_extend('force', value, {
            display = make_displayer,
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
                entry.selected = vim.g.shell.selected == entry.ordinal
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
                local res = selection.self == 1 and selection.value(selection) or selection.value()
                if res ~= false then
                    local shell = vim.g.shell
                    shell.selected = selection.ordinal
                    vim.g.shell = shell
                end
            end)
            return true
        end,
    })
end

return require 'telescope'.register_extension {
    exports = {
        configurations = function (options)
            picker(options or {}, list()):find()
        end
    },
}

