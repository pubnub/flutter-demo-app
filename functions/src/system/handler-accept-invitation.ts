import pubnub from 'pubnub'

import {
  Context,
  assertNotInternal,
  assertSenderSystemChannel,
  assertSenderEmail,
} from './utils'
import { Invitations, User } from '../models'

export async function handleAcceptInvitation(ctx: Context) {
  const senderUuid = ctx.request.params.uuid
  const responseId = ctx.request.message.requestId
  const payload = ctx.request.message.payload

  assertNotInternal(ctx)
  assertSenderSystemChannel(ctx)

  const invitations = await ctx.storage.load(Invitations, senderUuid)

  if (invitations === null || !invitations.invitations.includes(payload)) {
    await pubnub.publish({
      channel: `system.${senderUuid}`,
      message: {
        responseId: responseId,
        payload: null,
      },
    })
  } else {
    invitations.invitations.splice(invitations.invitations.indexOf(payload))

    await ctx.storage.save(invitations)

    await pubnub.fire({
      channel: `system.internal`,
      message: {
        type: 'connect-friends',
        payload: {
          of: senderUuid,
          add: payload,
        },
      },
    })

    await pubnub.fire({
      channel: `system.internal`,
      message: {
        type: 'connect-friends',
        payload: {
          of: payload,
          add: senderUuid,
        },
      },
    })

    await pubnub.publish({
      channel: `system.${senderUuid}`,
      message: {
        responseId: responseId,
        payload: invitations.invitations,
      },
    })
  }
}
