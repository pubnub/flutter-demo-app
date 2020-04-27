import pubnub from 'pubnub'

import { Context, assertNotInternal, assertSenderSystemChannel } from './utils'
import { Friends } from '../models'

export async function handleMyFriends(ctx: Context) {
  const senderUuid = ctx.request.params.uuid
  const responseId = ctx.request.message.requestId

  assertNotInternal(ctx)
  assertSenderSystemChannel(ctx)

  const friends = await ctx.storage.load(Friends, senderUuid)

  if (friends === null) {
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
        payload: friends.friends,
      },
    })
  }
}
