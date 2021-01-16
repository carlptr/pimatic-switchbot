pimatic-switchbot
=======================

This plugin for [Pimatic](https://pimatic.org) allows to control [Switch Bots](https://www.switch-bot.com) via the [Switch Bot API](https://github.com/OpenWonderLabs/SwitchBotAPI)

### Requirements
* Get a API token from the Switch Bot app, see https://github.com/OpenWonderLabs/SwitchBotAPI#getting-started. Please note that you need a SwitchBot hub and the bots to control must be cloud-enabled. 
* Install this plug to your pimatic environment
* Configure the API token in the plugin configuration.

### Usage
* This plugin provdes a device SwitchBot. Through the property *botId* you specify the corresponding bot. Discovering bots is supported.
