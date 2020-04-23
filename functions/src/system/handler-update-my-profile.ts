import { pubnub } from 'pubnub'

import {
  Context,
  assertNotInternal,
  assertSenderSystemChannel,
  assertExists,
} from './utils'
import { Profile } from '../models'

export async function handleUpdateMyProfile(ctx: Context) {
  const responseId = ctx.request.message.requestId

  assertNotInternal(ctx)
  assertSenderSystemChannel(ctx)

  const profile = await ctx.storage.load(Profile, ctx.request.params.uuid)

  assertExists(profile)

  profile.update(ctx.request.message.payload)

  await ctx.storage.save(profile)

  return pubnub.publish({
    channel: `system.${profile.uuid}`,
    message: {
      responseId: responseId,
      payload: 'ok',
    },
  })
}
