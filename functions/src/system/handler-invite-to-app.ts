import pubnub from 'pubnub'
import { Context, assertInternal } from './utils'
import { Profile } from '../models'
import { sendMail } from '../mail'

export async function handleInviteToApp(ctx: Context) {
  const payload = ctx.request.message.payload

  assertInternal(ctx)

  const profile = await ctx.storage.load(Profile, payload.from)

  if (!profile) {
    throw 'unknown sender'
  }

  await sendMail(
    payload.to,
    'You have been invited to PubNub Flutter Demo App!',
    'invite',
    {
      who: profile.displayName,
    }
  )
}
