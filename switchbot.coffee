# #Plugin template

# This is an plugin template and mini tutorial for creating pimatic plugins. It will explain the 
# basics of how the plugin system works and what a plugin should look like.

# ##The plugin code

# Your plugin must export a single function, that takes one argument and returns a instance of
# your plugin class. The parameter is an envirement object containing all pimatic related functions
# and classes. See the [startup.coffee](http://sweetpi.de/pimatic/docs/startup.html) for details.
module.exports = (env) ->

  # ###require modules included in pimatic
  # To require modules that are included in pimatic use `env.require`. For available packages take 
  # a look at the dependencies section in pimatics package.json

  # Require the  bluebird promise library
  Promise = env.require 'bluebird'

  # Require the [cassert library](https://github.com/rhoot/cassert).
  assert = env.require 'cassert'
  got = require 'got'

  BaseUrl = 'https://api.switch-bot.com/v1.0'

  # Include your own depencies with nodes global require function:
  #  
  #     someThing = require 'someThing'
  #  

  # ###Switchbot class
  # Create a class that extends the Plugin class and implements the following functions:
  class SwitchBotPlugin extends env.plugins.Plugin

    # ####init()
    # The `init` function is called by the framework to ask your plugin to initialise.
    #  
    # #####params:
    #  * `app` is the [express] instance the framework is using.
    #  * `framework` the framework itself
    #  * `config` the properties the user specified as config for your plugin in the `plugins` 
    #     section of the config.json file 
    #     
    # 
    init: (app, @framework, @config) =>
      if(@config.debug)
        env.logger.debug('Init of pimatic-switchbot')
      deviceConfigDef = require('./device-config-schema')
      @framework.deviceManager.registerDeviceClass("SwitchBot", {
        configDef: deviceConfigDef.SwitchBot,
        createCallback: (config) => 
          return new SwitchBotDevice(config, this)
      })

      # auto discovery
      @framework.deviceManager.on('discover', (eventData) =>
        @framework.deviceManager.discoverMessage(
          'pimatic-switchbot', "Scanning for SwitchBot devices"
        )
        options = {
          'headers': {'Authorization': @config.apiKey} 
        }

        #got(BaseUrl + '/devices', options).json()
        got(BaseUrl + '/devices/', options).json()
        .then (result) =>
          if(@config.debug)
            env.logger.debug(JSON.stringify(result));
          if(result.statusCode != 100)
            throw new Error(result.message + ' ' + result.statusCode)
          for device in result.body.deviceList
            if(device.deviceType == 'Bot')
              config = {
              class: 'SwitchBot',
              id: "bot-" + device.deviceId,
              botId: device.deviceId
              }
              @framework.deviceManager.discoveredDevice('pimatic-switchbot',
                "SwitchBot " + device.deviceName + " (#" + device.deviceId + ")", config
              )
        .catch (error) ->
          env.logger.error("Error on searching switchbots " + error)
      )

  class SwitchBotDevice extends env.devices.SwitchActuator

    constructor: (@config, @plugin) ->
      @id = @config.id
      @name = @config.name
      @botId = @config.botId
      super();

    #Performs a press with the SwitchBot
    changeStateTo: (state) ->
      if(@config.debug)
        env.logger.debug("SwitchBot " + @name + " (" + @botId + ") pressed.")
      command = {
        command: "press",
        parameter: "default",
        commandType: "command"
      }
      headers = {
        'Authorization': @plugin.config.apiKey
      }
      options = {
        'method': 'POST',
        'json': {command: "press", parameter: "default", commandType: "command"},
        'headers': {'Authorization': @plugin.config.apiKey},
        responseType: 'json'
      }

      got(BaseUrl + '/devices/' + @botId + '/commands', options).json()
        .then (result) =>
          if(result.statusCode != 100)
            throw new Error(result.message + ' ' + result.statusCode)
          Promise.resolve(result.body)
      
      #  .then (body) =>
      #    env.logger.info('Press command sent')
      #    Promise.resolve()

    destroy: () ->
      super()      

  # ###Finally
  # Create a instance of my plugin
  switchBotPlugin = new SwitchBotPlugin
  # and return it to the framework.
  return switchBotPlugin
