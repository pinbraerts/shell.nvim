local telescope = require 'telescope'
telescope.setup{}
telescope.load_extension('shell')

local function test(shell)
    print('===== Testing ":Telescope shell configurations" ->', shell)
    local step = 100
    vim.schedule(telescope.extensions.shell.configurations)
    coroutine.yield(step)
    vim.api.nvim_input(shell)
    coroutine.yield(step)
    vim.api.nvim_input('<cr>')
    coroutine.yield(step)
    vim.fn.Check('!', 'Shell', shell)
    print('===== Succeeded')
end

local function runner(co)
    local step = co()
    if step then
        vim.defer_fn(function () runner(co) end, step)
    end
end

runner(coroutine.wrap(function()
    test 'cmd'
    vim.cmd 'Test !echo \\%PATH\\%'

    test 'default'
    vim.cmd 'Test !echo \\%PATH\\%'

    test 'powershell'
    test 'pwsh'
    vim.cmd 'Test !echo $env:PATH'

    test 'sh'
    test 'bash'
    vim.cmd 'Test !echo $PATH'

    print('===== All test succeeded')
    os.exit(0, true)
end))

