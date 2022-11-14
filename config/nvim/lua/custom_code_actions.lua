local null_ls = require("null-ls")
local nclient = require("null-ls.client")
local u = require("null-ls.utils")
local ts_utils = require("nvim-treesitter.ts_utils")
local parsers = require("nvim-treesitter.parsers")

local extract_struct_name = function(line)
   return line:match('^type (.*) struct')
end

local prompt_tag_name = function()
   return vim.fn.input("Tag name: ")
end

local replace_buf = function(params, output)
   vim.lsp.util.apply_text_edits(
      { {
         range = u.range.to_lsp({
            row = 1,
            col = 1,
            end_row = vim.tbl_count(params.content) + 1,
            end_col = 1,
         }),
         newText = output:gsub("[\r\n]$", ""),
      } },
      params.bufnr,
      nclient.get_offset_encoding()
   )
end

local gomodifytags = {
   method = null_ls.methods.CODE_ACTION,
   filetypes = { "go" },
   generator = {
      fn = function(context)
         -- Find if there is struct to add tags to using treesitter
         local parser = parsers.get_parser(context.bufnr)
         local root = ts_utils.get_root_for_position(context.range.row, context.range.col, parser)
         if not root then
            return
         end
         local symbolpos = { context.range.row - 1, context.range.col } -- -1 from line number to get index
         local current_node = root:named_descendant_for_range(symbolpos[1], symbolpos[2], symbolpos[1], symbolpos[2])
         if not current_node then
            return
         end
         -- If not at struct, traverse up and try to find struct parent
         if current_node:type() ~= "struct_type" then
            -- Try until either reached root, or found a struct parent
            while (current_node:parent() ~= nil and current_node:type() ~= "struct_type") do
               current_node = current_node:parent()
            end
            if current_node:type() ~= "struct_type" then -- No struct parent found
               return
            end
         end
         local lineNo = current_node:range() + 1 -- +1 to go from index to line number
         local struct_name = extract_struct_name(context.content[lineNo])
         if not struct_name then
            return
         end

         return {
            {
               title = "[gomodifytags] Add struct tag",
               action = function()
                  local tag = prompt_tag_name()
                  if not tag then
                     return
                  end
                  local cmd = string.format('gomodifytags -skip-unexported -add-tags %s -file %s -struct %s', tag,
                     context.bufname, struct_name)
                  local output = vim.fn.system(cmd)
                  local err = vim.v.shell_error
                  if 0 ~= err then
                     print('error invoking gomodifytags', output)
                     return
                  end
                  replace_buf(context, output)
               end
            },
            {
               title = "[gomodifytags] Remove struct tag",
               action = function()
                  local tag = prompt_tag_name()
                  if not tag then
                     return
                  end
                  local cmd = string.format('gomodifytags -skip-unexported -remove-tags %s -file %s -struct %s', tag,
                     context.bufname, struct_name)
                  local output = vim.fn.system(cmd)
                  local err = vim.v.shell_error
                  if 0 ~= err then
                     print('error invoking gomodifytags', output)
                     return
                  end
                  replace_buf(context, output)
               end
            },
         }
      end
   }
}
null_ls.register(gomodifytags)
