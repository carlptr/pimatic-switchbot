# #pimatic-switchbot configuration options
# Declare your config option for your plugin here. 
module.exports = {
  title: "Pimatic Switchbot config options"
  type: "object"
  properties:
    apiKey:
      description: "The API key to access your switchbot"
      type: "string"
      default: ""
    debug:
      description: "Debug flag"
      type: "boolean"
      default: false
}