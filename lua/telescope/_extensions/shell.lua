local config  = require 'telescope.config'.values
local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local actions = require 'telescope.actions'
local state   = require 'telescope.actions.state'

local function split(str, pattern)
    local result = {}
    local index = 1
    for value in string.gmatch(str, '[^'..pattern..']+') do
        result[index] = value
        index = index + 1
    end
    return result
end

local function list_configurations()
    local result = {}
    local index = 1
    for key, _ in pairs(vim.g.shell_configurations) do
        local name = 'shell#'..key
        local output = vim.api.nvim_exec2(
            'verbose function '..name,
            { output = true }
        ).output
        local info = split(output, '\n')
        local path = split(info[2], ' ')
        result[index] = {
            value = vim.fn[name],
            display = key,
            ordinal = key,
            path = path[4],
            lnum = tonumber(path[6]),
        }
        index = index + 1
    end
    return result
end

local function picker(options, results)
    return pickers.new(options or {}, {
        propmpt_title = 'Shell configurations',
        finder = finders.new_table {
            results = results,
            entry_maker = function (entry)
                return entry
            end
        },
        previewer = config.grep_previewer(options),
        sorter = config.generic_sorter(options),
        attach_mappings = function (prompt_bufnr, _)
            actions.select_default:replace(function ()
                actions.close(prompt_bufnr)
                local selection = state.get_selected_entry()
                selection.value()
            end)
            return true
        end,
    })
end

return require 'telescope'.register_extension {
    exports = {
        configurations = function (options)
            picker(options, list_configurations()):find()
        end
    },
}

