import pubnub from 'pubnub'

import { Context, assertInternal } from './utils'
import { Friends, Account } from '../models'

export async function handleConnectFriends(ctx: Context) {
  const person = ctx.request.message.payload.of
  const friend = ctx.request.message.payload.add

  assertInternal(ctx)

  let personFriends = await ctx.storage.load(Friends, person)

  if (!personFriends) {
    personFriends = Friends.construct(person, [])
  }

  personFriends.friends.push(friend)

  await ctx.storage.save(personFriends)

  const account = await ctx.storage.load(Account, person)

  await pubnub.grant({
    authKeys: [account?.authKey],
    channels: [`${friend}.${person}`],
    write: true,
    manage: false,
    read: false,
  })
}
