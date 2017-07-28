local pastebin = require(script.Parent).new('dev key', 'username', 'password')

local newPaste = pastebin:create(
	{
		text = 'This is a test paste.',
		optional = {
			api_paste_name = 'Hello World!',
			api_paste_format = 'lua',
			api_paste_private = 0,
			api_paste_expire_data = 'N'
		}
	}
)

local rawPaste,num = pastebin:getPaste(newPaste:gsub('https://pastebin.com/', ''))
print(rawPaste)
