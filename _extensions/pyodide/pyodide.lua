----
--- Setup variables for default initialization

-- Define a variable to only include the initialization once
local hasDonePyodideSetup = false

--- Setup default initialization values
-- Default values taken from:
-- https://pyodide.org/en/stable/usage/api/js-api.html#globalThis.loadPyodide

-- Define a base compatibile version
local baseVersionPyodide = "0.24.1"

-- Define where Pyodide can be found. Default:
-- https://cdn.jsdelivr.net/pyodide/v0.24.1/full/
-- https://cdn.jsdelivr.net/pyodide/v0.24.1/debug/
local baseUrl = "https://cdn.jsdelivr.net/pyodide/v".. baseVersionPyodide .."/"
local buildVariant = "full/"
local cdnURL = baseUrl .. buildVariant

-- Define user directory
local homeDir = "/home/pyodide"

-- Define whether a startup status message should be displayed
local showStartUpStatus = "true"

-- Define an empty string if no packages need to be installed.
local installPythonPackagesList = "''"
----

--- Setup variables for tracking number of code cells

-- Define a counter variable
local counter = 0

----
--- Process initialization

-- Check if variable is present and not just the empty string
local function isVariableEmpty(s)
  return s == nil or s == ''
end

local function isVariablePopulated(s)
  return not isVariableEmpty(s)
end

-- Parse the different Pyodide options set in the YAML frontmatter, e.g.
--
-- ```yaml
-- ----
-- pyodide:
--   base-url: https://cdn.jsdelivr.net/pyodide/[version]
--   build-variant: full
--   packages: ['matplotlib', 'pandas']
-- ----
-- ```
--
-- 
function setPyodideInitializationOptions(meta)

  -- Let's explore the meta variable data! 
  -- quarto.log.output(meta)
  
  -- Retrieve the pyodide options from meta
  local pyodide = meta.pyodide

  -- Does this exist? If not, just return meta as we'll just use the defaults.
  if isVariableEmpty(pyodide) then
    return meta
  end

  -- The base URL used for downloading Python WebAssembly binaries 
  if isVariablePopulated(pyodide["base-url"]) then
    baseUrl = pandoc.utils.stringify(pyodide["base-url"])
  end

  -- The build variant for Python WebAssembly binaries. Default: 'full'
  if isVariablePopulated(pyodide["build-variant"]) then
    buildVariant = pandoc.utils.stringify(pyodide["build-variant"])
  end

  if isVariablePopulated(pyodide["build-variant"]) and isVariablePopulated(pyodide["base-url"]) then
    cdnURL = baseUrl .. buildVariant
  end

  -- The WebAssembly user's home directory and initial working directory. Default: '/home/pyodide'
  if isVariablePopulated(pyodide['home-dir']) then
    homeDir = pandoc.utils.stringify(pyodide["home-dir"])
  end

  -- Display a startup message indicating the pyodide state at the top of the document.
  if isVariablePopulated(pyodide['show-startup-message']) then
    showStartUpMessage = pandoc.utils.stringify(pyodide["show-startup-message"])
  end

  -- Attempt to install different packages.
  if isVariablePopulated(pyodide["packages"]) then
    -- Create a custom list
    local package_list = {}

    -- Iterate through each list item and enclose it in quotes
    for _, package_name in pairs(pyodide["packages"]) do
      table.insert(package_list, "'" .. pandoc.utils.stringify(package_name) .. "'")
    end

    installPythonPackagesList = table.concat(package_list, ", ")
  end
  
  return meta
end


-- Obtain a template file
function readTemplateFile(template)
  -- Establish a hardcoded path to where the .html partial resides
  -- Note, this should be at the same level as the lua filter.
  -- This is crazy fragile since Lua lacks a directory representation (!?!?)
  -- https://quarto.org/docs/extensions/lua-api.html#includes
  local path = quarto.utils.resolve_path(template) 

  -- Let's hopefully read the template file... 

  -- Open the template file
  local file = io.open(path, "r")

  -- Check if null pointer before grabbing content
  if not file then        
    error("\nWe were unable to read the template file `" .. template .. "` from the extension directory.\n\n" ..
          "Double check that the extension is fully available by comparing the \n" ..
          "`_extensions/coatless-quarto/pyodide` directory with the main repository:\n" ..
          "https://github.com/coatless-quarto/pyodide/tree/main/_extensions/pyodide\n\n" ..
          "You may need to modify `.gitignore` to allow the extension files using:\n" ..
          "!_extensions/*/*/*\n")
    return nil
  end

  -- *a or *all reads the whole file
  local content = file:read "*a" 

  -- Close the file
  file:close()

  -- Return contents
  return content
end

-- Obtain the initialization template file at pyodide-init.html
function initializationTemplateFile()
  return readTemplateFile("pyodide-init.html")
end


-- Obtain the editor template file at pyodide-context-interactive.html
function interactiveTemplateFile()
  return readTemplateFile("pyodide-context-interactive.html")
end

-- Cache a copy of each public-facing templates to avoid multiple read/writes.
interactive_template = interactiveTemplateFile()

-- Define a function that escape control sequence
function escapeControlSequences(str)
  -- Perform a global replacement on the control sequence character
  return str:gsub("[\\%c]", function(c)
    if c == "\\" then
      -- Escape backslash
      return "\\\\"
    end
  end)
end

function initializationPyodide()

  -- Setup different Pyodide specific initialization variables
  local substitutions = {
    ["SHOWSTARTUPMESSAGE"] = showStartUpMessage, 
    ["BASEURL"] = baseUrl, 
    ["HOMEDIR"] = homeDir,
    ["INSTALLPYTHONPACKAGESLIST"] = installPythonPackagesList,
  }
  
  -- Make sure we perform a copy
  local initializationTemplate = initializationTemplateFile()

  -- Make the necessary substitutions
  local initializedPyodideConfiguration = substitute_in_file(initializationTemplate, substitutions)

  return initializedPyodideConfiguration
end

-- Setup Pyodide's pre-requisites once per document.
function ensurePyodideSetup()
  
  -- If we've included the initialization, then bail.
  if hasDonePyodideSetup then
    return
  end
  
  -- Otherwise, let's include the initialization script _once_
  hasDonePyodideSetup = true

  local initializedConfigurationPyodide = initializationPyodide()
  

  -- Insert different partial files to create a monolithic document.
  -- https://quarto.org/docs/extensions/lua-api.html#includes

  -- Insert CSS styling and external style sheets
  quarto.doc.include_file("in-header", "pyodide-styling.html")

  -- Insert the Pyodide initialization routine
  quarto.doc.include_text("in-header", initializedConfigurationPyodide)

  -- Insert the Monaco Editor initialization
  quarto.doc.include_file("before-body", "monaco-editor-init.html")

end

-- Define a function to replace keywords given by {{ WORD }}
-- Is there a better lua-approach?
function substitute_in_file(contents, substitutions)

  -- Substitute values in the contents of the file
  contents = contents:gsub("{{%s*(.-)%s*}}", substitutions)

  -- Return the contents of the file with substitutions
  return contents
end


-- Replace the code cell with a Pyodide interactive editor
function enablePyodideCodeCell(el)
      
  -- Let's see what's going on here:
  -- quarto.log.output(el)
  
  -- Should display the following elements:
  -- https://pandoc.org/lua-filters.html#type-codeblock
  
  -- Verify the element has attributes and the document type is HTML
  -- not sure if this will work with an epub (may need html:js)
  if el.attr and quarto.doc.is_format("html") then

    -- Check for the new engine syntax that allows for the cell to be 
    -- evaluated in VS Code or RStudio editor views, c.f.
    -- https://github.com/quarto-dev/quarto-cli/discussions/4761#discussioncomment-5336636    
    if el.attr.classes:includes("{pyodide-python}") then
      
      -- Make sure we've initialized the code block
      ensurePyodideSetup()

      -- Modify the counter variable each time this is run to create
      -- unique code cells
      counter = counter + 1
      
      -- 7 is the default height and width for knitr. But, that doesn't translate to pixels.
      -- So, we have 504 and 360 respectively.
      -- Should we check the attributes for this value? Seems odd.
      -- https://yihui.org/knitr/options/
      local substitutions = {
        ["PYODIDECOUNTER"] = counter, 
        ["WIDTH"] = 504,
        ["HEIGHT"] = 360,
        ["PYODIDECODE"] = escapeControlSequences(el.text)
      }

      -- Make the necessary substitutions into the template
      local pyodide_enabled_code_cell = substitute_in_file(interactive_template, substitutions)

      -- Return the modified HTML template as a raw cell
      return pandoc.RawInline('html', pyodide_enabled_code_cell)

    end
  end

  -- Allow for a pass through in other languages
  return el
end

return {
  {
    Meta = setPyodideInitializationOptions
  }, 
  {
    CodeBlock = enablePyodideCodeCell
  }
}