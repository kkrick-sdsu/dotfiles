local required_neovim = { major = 0, minor = 11, patch = 0 }
local current_neovim = vim.version()

if not vim.version.ge(current_neovim, required_neovim) then
  vim.api.nvim_err_writeln(
    string.format(
      "This Neovim configuration requires Neovim >= %d.%d.%d (found %s)",
      required_neovim.major,
      required_neovim.minor,
      required_neovim.patch,
      tostring(current_neovim)
    )
  )
  return
end

-- Imports
require("config.lazy")
require("kkrick")

