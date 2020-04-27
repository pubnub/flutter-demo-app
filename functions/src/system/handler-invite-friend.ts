import pubnub from 'pubnub'
import {
  Context,
  assertNotInternal,
  assertSenderSystemChannel,
  uuid,
} from './utils'
import { User, Invitations } from '../models'

export async function handleInviteFriend(ctx: Context) {
  const senderUuid = ctx.request.params.uuid
  const payload = ctx.request.message.payload

  assertNotInternal(ctx)
  assertSenderSystemChannel(ctx)

  let invitee = await ctx.storage.load(User, payload)
  let sendMail = false

  if (!invitee) {
    invitee = User.construct(payload, uuid(), uuid())

    await pubnub.fire({
      channel: 'system.internal',
      message: {
        type: 'register',
        payload: {
          uuid: invitee.uuid,
          email: invitee.email,
          authKey: invitee.authKey,
        },
      },
    })

    sendMail = true
  }

  let invList = await ctx.storage.load(Invitations, invitee.uuid)

  if (!invList) {
    invList = Invitations.construct(invitee.uuid, [])
  }

  invList.invitations.push(senderUuid)

  await ctx.storage.save(invList)

  if (sendMail) {
    await pubnub.fire({
      channel: 'system.internal',
      message: {
        type: 'invite-to-app',
        payload: { from: senderUuid, to: payload },
      },
    })
  } else {
    await pubnub.publish({
      channel: `system.${invitee.uuid}`,
      message: {
        type: 'invitation',
        from: senderUuid,
      },
    })
  }
}
