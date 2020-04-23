import { Context, assertNotInternal } from './utils'
import { User } from '../models'

export async function handleDeleteUser(ctx: Context) {
  const payload = ctx.request.message.payload

  assertNotInternal(ctx)

  if (typeof payload !== 'string' || payload.length == 0) {
    throw 'payload must be a non-empty string'
  }

  await ctx.storage.delete(User, payload)
}
