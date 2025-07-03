-- Protobuf language configuration

-- File type settings
setup_filetype({ "proto" }, {
  indent = 2,
  expandtab = true,
  colorcolumn = 120,
})

-- LSP server configuration
_G.LSP_SERVERS.buf_ls = {}

-- Formatters
_G.FORMATTERS.proto = { "buf" }

-- Linters
_G.LINTERS.proto = { "protolint" }

-- Mason tools needed
add_mason_tools({ "buf", "protolint" })
