import Mastodon from "mastodon-api"
import * as config from "../config.json"
import * as fs from "fs"
import * as readline from "readline"
import * as EventEmitter from "events"

export class MstdnMonitor extends EventEmitter
  constructor: ->
    @lastId = -1
    @M = new Mastodon
      access_token: config.token
      timeout_ms: 60 * 1000
      api_url: "#{config.instance}/api/v1/"

saveConfig = () ->
  newObj = JSON.parse JSON.stringify config
  delete newObj.default
  new Promise (resolve, reject) =>
    fs.writeFile 'config.json', JSON.stringify(newObj, null, 4), 'utf8', (err) =>
      if err?
        reject err
      else
        resolve()

export authorize = ->
  return if config.token?
  if !(config.clientId? and config.clientSecret?)
    console.log "Requesting for client credentials..."
    Mastodon.createOAuthApp "#{config.instance}/api/v1/apps", config.name, "read"
      .then (res) =>
        config.clientId = res.client_id
        config.clientSecret = res.client_secret
        console.log "client_id: #{config.clientId}"
        console.log "client_secret: #{config.clientSecret}"
        console.log "The above information has been saved to config.json"
      .then =>
        saveConfig()
      .then => authorize()
      .catch (err) =>
        console.log err
    return
  Mastodon.getAuthorizationUrl config.clientId, config.cientSecret, config.instance, "read"
    .then (url) =>
      console.log "Please visit #{url} for authorization"
      rl = readline.createInterface
        input: process.stdin
        output: process.stdout
      new Promise (resolve) =>
        rl.question 'Please fill in the authorization code: ', (code) =>
          rl.close()
          resolve code
    .then (code) =>
      Mastodon.getAccessToken config.clientId, config.clientSecret, code, config.instance
    .then (token) =>
      config.token = token
      console.log "Access token: #{config.token}"
      saveConfig()
    .then => console.log "Saved to config.json"