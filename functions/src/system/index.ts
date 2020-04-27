import { Request } from 'internal'

import { Context } from './utils'
import { Storage } from '../storage'

import { handleDeleteUser } from './handler-delete-user'
import { handleRegister } from './handler-register'
import { handleMyProfile } from './handler-my-profile'
import { handleUpdateMyProfile } from './handler-update-my-profile'
import { handleKvstore } from './handler-kvstore'
import { handleInviteFriend } from './handler-invite-friend'
import { handleInviteToApp } from './handler-invite-to-app'
import { handleGetProfile } from './handler-get-profile'
import { handleMyInvitations } from './handler-my-invitations'
import { handleAcceptInvitation } from './handler-accept-invitation'
import { handleConnectFriends } from './handler-connect-friends'
import { handleMyFriends } from './handler-my-friends'

function handler(context: Context) {
  switch (context.request.message.type) {
    case 'delete-user':
      return handleDeleteUser(context)
    case 'register':
      return handleRegister(context)
    case 'get-profile':
      return handleGetProfile(context)
    case 'my-profile':
      return handleMyProfile(context)
    case 'update-my-profile':
      return handleUpdateMyProfile(context)
    case 'kvstore':
      return handleKvstore(context)
    case 'invite-friend':
      return handleInviteFriend(context)
    case 'invite-to-app':
      return handleInviteToApp(context)
    case 'my-invitations':
      return handleMyInvitations(context)
    case 'accept-invitation':
      return handleAcceptInvitation(context)
    case 'connect-friends':
      return handleConnectFriends(context)
    case 'my-friends':
      return handleMyFriends(context)
    default:
      return Promise.reject('unknown action type')
  }
}

export async function main(request: Request) {
  const storage = new Storage()

  const context = {
    request,
    storage,
  }

  try {
    await handler(context)
    console.log(`handled: ${request.message.type}`)
  } catch (e) {
    console.log(`failed: ${e}`)
  }

  return request.ok()
}
