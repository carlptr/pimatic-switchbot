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
      env.logger.info("Hello World")
      deviceConfigDef = require('./device-config-schema')
      @framework.deviceManager.registerDeviceClass("SwitchBot", {
        configDef: deviceConfigDef.SwitchBot,
        createCallback: (config) => 
          return new SwitchBotDevice(config, this)
      })

  class SwitchBotDevice extends env.devices.SwitchActuator

    constructor: (@config, @plugin) ->
      @id = @config.id
      @name = @config.name
      @botId = @config.botId
      super();

    #Performs a press with the SwitchBot
    changeStateTo: (state) ->
      env.logger.info("SwitchBot " + @name + " (" + @botId + ") pressed.")
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

      got('https://api.switch-bot.com/v1.0/devices/' + @botId + '/commands', options)
        .then (result) =>
          message = result.body.message
          if(message != "success")
            env.logger.error('Sending press command failed ' + result.body.statusCode)
          else if(@plugin.config.debug)
            env.logger.debug('Command sent successfully') 
          Promise.resolve()
      
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
