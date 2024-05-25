local my_settings = {
  export_folder = "/Users/matthewscott/Documents/auto_exports/",
  template_path = "/Users/matthewscott/.config/export_obsidian/template.tex",
  supporting_docs_dir = "/Users/matthewscott/.config/export_obsidian/supporting_docs/",
  julia_main_file_path = "/Users/matthewscott/Prog/Paper_export_projects/Obsidian-Paper-Export/src/main.jl",
}
local Path = require('plenary.path')

local function findParentWithFolder(startPath, pattern)
    local currentPath = Path:new(startPath)

    -- Keep iterating until we reach the root directory
    while true do
        currentPath = currentPath:parent()

        -- Construct the path for the target folder
        local targetFolder = currentPath / pattern

        -- Check if the target folder exists
        if targetFolder:exists() then
            return tostring(currentPath)
        end

        -- If we've reached the filesystem root, stop searching
        if tostring(currentPath) == '/' then
            break
        end
    end

    return nil -- Return nil if not found
end

function Export_Longform()
  local file_name = string.match(vim.api.nvim_buf_get_name(0), ".-([^/]+)%.md$")
  local dir = findParentWithFolder(vim.api.nvim_buf_get_name(0), ".obsidian")
  assert(dir ~= nil and file_name ~= nil, "could not resolve file name.")
  local under_file_name = string.gsub(file_name, " ", "_")

  local new_dir = my_settings.export_folder .. under_file_name .. "/"

  if vim.fn.isdirectory(new_dir) ~= 1 then
    vim.cmd("!mkdir " .. new_dir)
  end

  if vim.fn.filereadable(new_dir .. "config.yaml") then
    local config_file = io.open(new_dir .. "config.yaml", "w+")
    assert(config_file ~= nil, "could not create config.yaml")
    config_file:write(string.format(
      [[
main_doc_template: "%stemplate.tex"
ignore_quotes: true
input_folder_path: "%s"
longform_file_name: "%s"
output_folder_path: "%soutput/"]],
      new_dir,
      dir,
      file_name,
      new_dir
    ))
    config_file:close()
  end

  if vim.fn.filereadable(new_dir .. "template.tex") ~= 1 then
    vim.cmd("!cp " .. my_settings.template_path .. " " .. new_dir)
    -- use the template check as proxy for the supporting docs
    vim.cmd("!cp " .. my_settings.supporting_docs_dir .. "* " .. new_dir .. "output/")
  end
  if vim.fn.isdirectory(new_dir .. "output") ~= 1 then
    vim.cmd("!mkdir " .. new_dir .. "output")
  end

  if vim.fn.filereadable(new_dir .. "export.zsh") ~= 1 then
    local export_executable = io.open(new_dir .. "export.zsh", "w+")
    assert(export_executable ~= nil, "could not create export.zsh")
    export_executable:write(string.format(
      [[julia %s %sconfig.yaml

if %[%[ $? -eq 1 %]%]; then
    exit 0
fi
  ]],
      my_settings.julia_main_file_path,
      new_dir
    ))

    export_executable:close()
    vim.cmd("!chmod +x " .. new_dir .. "export.zsh")
  end

  -- run the export
  local tmpfile = os.tmpname()
  vim.cmd("! " .. new_dir .. "export.zsh > " .. tmpfile)
  -- local output = os.execute(new_dir .. "export.zsh")
  -- print(output)
  local file = io.open(tmpfile, "r")
  assert(file ~= nil)
  print(file:read("*a"))
  file:close()

  if vim.fn.isdirectory(new_dir .. "manual") ~= 1 then
    print("manual is not dir")
    os.execute("cp -r " .. new_dir .. "output/ " .. new_dir .. "manual/")
  end

  vim.cmd([[vsplit]])

  -- open and compile the latex
  vim.cmd("e " .. new_dir .. "output/output.tex")
end

vim.keymap.set('n', '<Space>el', Export_Longform, {desc= "[E]xport [L]ongform"})
