import { MstdnMonitor } from './mastodon'
import { onUpdate } from './telegram'

main = ->
  mstdn = new MstdnMonitor
  mstdn.on 'toot', onUpdate

main()