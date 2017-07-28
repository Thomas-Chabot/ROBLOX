--[[
	Title: Pastebin Module
	Written by: call23re2
	Description: Basic pastebin module. Currently only has 2 functions. Planning on adding more at some point.
	
	new:
		Description: Creates a new pastebin object.
		Arguments:
			-key (string): developer key (you can get it on this page: https://pastebin.com/api)
			-username (string): pastebin username
			-pw (string): pastebin password
		Returns: new pastebin object
	
	create:
		Description: Creates new pastebin paste.
		Arguments:
			-data (dictionary):
				-text (string): Text in the paste.
				-optional (dictionary):
					-api_paste_name (string): Name of the paste.
					-api_paste_format (string): Paste format. (list can be found here: https://pastebin.com/api)
					-api_paste_private (integer): public = 0, unlisted = 1, private = 2
					-api_paste_expire_data (string): Time it takes for paste to expire.
						N = Never
						10M = 10 Minutes
						1H = 1 Hour
						1D = 1 Day
						1W = 1 Week
						2W = 2 Weeks
						1M = 1 Month
	
	getPaste:
		Description: Gets raw paste data from provided url.
		Arguments:
			-url (string): The end of an existing paste's url. (i.e aGsL0Mkp)
--]]


local http = game:GetService('HttpService')

local pastebin = {}
pastebin.__index = pastebin

function pastebin.new(key, username, pw)
	local userKey = http:PostAsync('https://pastebin.com/api/api_login.php','api_dev_key=' .. key .. '&api_user_name=' .. username .. '&api_user_password=' .. pw, 2)
	
	local newPastebin = setmetatable({},pastebin)
	
	newPastebin.devKey = key
	newPastebin.userKey = userKey
	newPastebin.name = username
	newPastebin.pw = pw
	
	return newPastebin
end

function pastebin:create(data)
	local params = 'api_option=paste&api_user_key=' .. self.userKey .. '&api_dev_key=' .. self.devKey .. '&api_paste_code=' .. http:UrlEncode(data.text)
	for label, value in pairs(data['optional']) do
		if label == 'api_paste_name' then
			params = params .. '&' .. label .. '=' .. http:UrlEncode(value)
		else
			params = params .. '&' .. label .. '=' .. value
		end
	end
	local res = http:PostAsync('https://pastebin.com/api/api_post.php', params, 2)
	return res
end

function pastebin:getPaste(url)
	return http:GetAsync('https://pastebin.com/raw/' .. url)
end

return pastebin
