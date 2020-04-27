import pubnub from 'pubnub'

import { Context } from './utils'
import { User, Profile, Account } from '../models'

export async function handleRegister(ctx: Context) {
  if (ctx.request.channels.indexOf('system.internal') !== 0) {
    throw 'not sent on system.internal'
  }

  const payload = ctx.request.message.payload

  const user = User.construct(payload.email, payload.authKey, payload.uuid)
  await ctx.storage.save(user)

  const account = Account.construct(
    payload.uuid,
    payload.email,
    payload.authKey
  )
  await ctx.storage.save(account)

  await pubnub.grant({
    authKeys: [account.authKey],
    channels: [`system.${account.uuid}`, `${account.uuid}.*`],
    write: true,
    read: true,
    manage: true,
  })

  const profile = Profile.construct(account.uuid, 'Anonymous', {
    color: 4288585374,
    emoji: 'question',
  })

  await ctx.storage.save(profile)
}
