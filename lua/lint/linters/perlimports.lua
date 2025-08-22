-- perlimports requires both to read from stdin *and*
-- to have the filename appended.
return function()
    local filename = vim.api.nvim_buf_get_name(0)
    return {
        cmd = 'perlimports',
        stdin = true,
        ignore_exitcode = true,
        args = {'--lint', '--json', '--filename', filename},
        stream = 'stderr',
        parser = function(output)
            local result = vim.fn.split(output, '\n')
            local diagnostics = {}
            for _, message in ipairs(result) do
                local ok, decoded = pcall(vim.json.decode, message)
                if ok then
                    table.insert(diagnostics, {
                        source = 'perlimports',
                        lnum = decoded.location.start.line - 1,
                        col = decoded.location.start.column - 1,
                        end_lnum = decoded.location['end'].line - 1,
                        end_col = decoded.location['end'].column - 1,
                        severity = vim.diagnostic.severity.INFO,
                        message = decoded.reason,
                    })
                end
            end
            return diagnostics
        end,
    }
end
