--This assumes that it is a script inside of the MainModule module.

local webhook = require(script.Parent)
local settings = {
	['id'] = 'webhook id';
	['token'] = 'webhook token';
}

local newWebhook = webhook.new(settings.id, settings.token)

local embed = newWebhook:createEmbed({
	color = {0,162,255};
	thumbnail = {
		url = 'https://pbs.twimg.com/profile_images/801513448785879040/f3txAdY2_bigger.jpg',
		dimensions = {100, 100}
	};
	fields = {
		{
			name = 'Username',
			value = 'call23re2',
			inline = false
		};
		{
			name = 'Feedback',
			value = 'Feedback here.',
			inline = false
		};		
	};
})

newWebhook:execute({
	username = 'Feedback';
	avatar_url = 'https://pbs.twimg.com/profile_images/801513448785879040/f3txAdY2_bigger.jpg';
	embeds = {embed}
})
