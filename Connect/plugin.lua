local plugin = PluginManager():CreatePlugin();
local toolbar = plugin:CreateToolbar('call23re2')
local editorToRoblox = toolbar:CreateButton('e to r', '', '');
local robloxToEditor = toolbar:CreateButton('r to e', '', '');

local http = game:GetService('HttpService')
local eActive = false
local rActive = false
local scripts = {}

function getData(path, reqType, send)
	local data
	if reqType == 'get' then
		data = http:GetAsync('http://localhost:3000/' .. path)
	else
		data = http:PostAsync('http://localhost:3000/' .. path, send)
	end
	return data
end

function getSyncScripts(parent)
	local function recurse(parent)
		for i, value in pairs(parent:GetChildren()) do
			pcall(function()
				if value:IsA('Script') or value:IsA('LocalScript') or value:IsA('ModuleScript') then
					local code = string.sub(string.match(value.Source, '-- $connect [^%s]+'), 13)
					scripts[value] = code
				end
				if #value:GetChildren() > 0 then
					recurse(value)
				end
			end)
		end
	end
	scripts = {}
	recurse(parent)
end

editorToRoblox.Click:connect(function()
	eActive = not eActive
	rActive = false
	while eActive do
		getSyncScripts(game)
		for scr, code in pairs(scripts) do
			scr.Source = '-- $connect ' .. code .. '\n\n' .. getData(code, 'get')
		end
		wait(0.5)
	end
end)

robloxToEditor.Click:connect(function()
	rActive = not rActive
	eActive = false
	while rActive do
		getSyncScripts(game)
		for scr, code in pairs(scripts) do
			getData(code, 'post', scr.Source)
		end
		wait(0.5)
	end
end)
