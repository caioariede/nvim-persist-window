-- Test initialization file
-- Adds the lua directory to package.path for require statements in tests

vim.opt.rtp:append(vim.fn.getcwd())

-- Add lua directory to package path for testing
package.path = package.path .. ";" .. vim.fn.getcwd() .. "/lua/?.lua"
package.path = package.path .. ";" .. vim.fn.getcwd() .. "/lua/?/init.lua"