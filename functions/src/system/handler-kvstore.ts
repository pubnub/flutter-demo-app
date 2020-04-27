import kvstore from 'kvstore'

import { Context, assertConsole } from './utils'

export async function handleKvstore(ctx: Context) {
  const payload = ctx.request.message.payload
  assertConsole(ctx)

  const type = payload.type

  switch (type) {
    case 'get':
      const val = await kvstore.get(payload.key)
      console.log(val)
      break
    case 'list':
      const list = await kvstore.getKeys()
      console.log(list)
      break
    case 'delete':
      await kvstore.removeItem(payload.key)
      console.log('removed')
      break
  }
}
