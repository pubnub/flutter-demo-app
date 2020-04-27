import pubnub from 'pubnub'

import { Context, assertNotInternal, assertSenderSystemChannel } from './utils'
import { Invitations } from '../models'

export async function handleMyInvitations(ctx: Context) {
  const senderUuid = ctx.request.params.uuid
  const responseId = ctx.request.message.requestId

  assertNotInternal(ctx)
  assertSenderSystemChannel(ctx)

  const invitations = await ctx.storage.load(Invitations, senderUuid)

  if (invitations === null) {
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
        payload: invitations.invitations,
      },
    })
  }
}
