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

local function get_info(name)
    local output = split(vim.api.nvim_exec2(
        name == 'custom' and 'verbose set shell' or 'verbose function shell#'..name,
        { output = true }
    ).output, '\n')
    if #output < 2 then
        output = split(vim.api.nvim_exec2(
            'verbose function shell#'..name,
            { output = true }
        ).output, '\n')
    end
    local info = split(output[2], ' ')
    return {
        path = info[4],
        lnum = info[6],
    }
end

local function list_configurations()
    local result = {}
    local index = 1
    for key, _ in pairs(vim.g.shell_configurations) do
        local info = get_info(key)
        info.lnum = tonumber(info.lnum)
        result[index] = vim.tbl_extend(
            'keep', info,
            {
                value = vim.fn['shell#'..key],
                display = key,
                ordinal = key,
            }
        )
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

-- picker({}, list_configurations()):find()
return require 'telescope'.register_extension {
    exports = {
        configurations = function (options)
            picker(options or {}, list_configurations()):find()
        end
    },
}

