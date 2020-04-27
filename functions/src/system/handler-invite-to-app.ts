import pubnub from 'pubnub'
import { Context, assertInternal } from './utils'
import { Profile } from '../models'
import { sendMail } from '../sendgrid'

export async function handleInviteToApp(ctx: Context) {
  const payload = ctx.request.message.payload

  assertInternal(ctx)

  const profile = await ctx.storage.load(Profile, payload.from)

  await sendMail(
    payload.to,
    'You have been invited to PubNub Flutter Demo App!',
    `<div>
      <p>Welcome to <em>PubNub Flutter Demo App</em>!</p>
      <p></p>
      <p>
        You have been invited by <strong>${profile?.displayName}</strong>.
        To join, open the app, log in using this e-mail and accept the invitation!
      </p>
    </div>`
  )
}
