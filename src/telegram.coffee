import rp from "request-promise"
import striptags from "striptags"
import * as config from "../config.json"

BASEURL = "https://api.telegram.org/bot#{config.tgBot}"

sendMessage = (text) ->
  options = 
    method: 'POST'
    uri: "#{BASEURL}/sendMessage"
    body:
      chat_id: config.tgChannel
      text: text
      parse_mode: 'HTML'
      disable_web_page_preview: no
    json: yes
  rp options
    .then (res) =>
      throw new Error res.description if !res.ok

export onUpdate = (toot) ->
  if toot.reblog?
    toot.content = toot.reblog.content
  msg = toot.content + "\n-- From <a href=\"#{toot.url}\">Mastodon</a>"
  if toot.reblog?
    msg += " (Reblog)"
  msg = striptags msg, ['a', 'b', 'strong', 'em', 'code', 'pre']
  msg = msg.replace /\&apos\;/g, '&quot;'
  sendMessage msg
    .then =>
      console.log "#{toot.id} => #{config.tgChannel}"
    .catch (err) =>
      console.log err