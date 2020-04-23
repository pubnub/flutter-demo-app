import { pubnub } from 'pubnub'

import { Context } from './utils'
import { User, Profile } from '../models'

export async function handleRegister(ctx: Context) {
  if (ctx.request.channels.indexOf('system.internal') !== 0) {
    throw 'not sent on system.internal'
  }

  const payload = ctx.request.message.payload

  const account = User.construct(payload.email, payload.authKey, payload.uuid)
  await ctx.storage.save(account)

  await pubnub.grant({
    authKeys: [account.authKey],
    channels: [`system.${account.uuid}`, `${account.uuid}.*`],
    write: true,
    read: true,
    manage: true,
  })

  const profile = Profile.construct(account.uuid, 'Anonymous', {
    color: -926365441,
    emoji: 'question',
  })

  await ctx.storage.save(profile)
}
