import pubnub from 'pubnub'

import { Context, assertNotInternal, assertSenderSystemChannel } from './utils'
import { Profile } from '../models'

export async function handleGetProfile(ctx: Context) {
  const senderUuid = ctx.request.params.uuid
  const responseId = ctx.request.message.requestId
  const payload = ctx.request.message.payload

  assertNotInternal(ctx)

  const profile = await ctx.storage.load(Profile, payload)

  if (profile === null) {
    await pubnub.publish({
      channel: `system.${senderUuid}`,
      message: {
        responseId: responseId,
        payload: null,
      },
    })
  } else {
    await pubnub.publish({
      channel: `system.${senderUuid}`,
      message: {
        responseId: responseId,
        payload: profile.toJson(),
      },
    })
  }
}
