import { Request } from 'internal'

import { Context } from './utils'
import { Storage } from '../storage'

import { handleDeleteUser } from './handler-delete-user'
import { handleRegister } from './handler-register'
import { handleMyProfile } from './handler-my-profile'
import { handleUpdateMyProfile } from './handler-update-my-profile'

function handler(context: Context) {
  switch (context.request.message.type) {
    case 'delete-user':
      return handleDeleteUser(context)
    case 'register':
      return handleRegister(context)
    case 'my-profile':
      return handleMyProfile(context)
    case 'update-my-profile':
      return handleUpdateMyProfile(context)
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
