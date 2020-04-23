import { pubnub } from 'pubnub'

import { Context, assertNotInternal, assertSenderSystemChannel } from './utils'
import { Profile } from '../models'

export async function handleMyProfile(ctx: Context) {
  const senderUuid = ctx.request.params.uuid
  const responseId = ctx.request.message.requestId

  assertNotInternal(ctx)
  assertSenderSystemChannel(ctx)

  const profile = await ctx.storage.load(Profile, senderUuid)

  if (profile === null) {
    throw 'profile doesnt exist'
  }

  await pubnub.publish({
    channel: `system.${profile.uuid}`,
    message: {
      responseId: responseId,
      payload: profile.toJson(),
    },
  })
}
