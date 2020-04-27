import { Request } from 'internal'
import { Storage } from '../storage'
import { UserModel } from '../models'

export type Context = {
  request: Request
  storage: Storage
}

export function assertNotInternal(ctx: Context) {
  if (ctx.request.channels.includes('system.internal')) {
    throw 'assertion failed: internal channel'
  }
}

export function assertInternal(ctx: Context) {
  if (!ctx.request.channels.includes('system.internal')) {
    throw 'assertion failed: not internal channel'
  }
}

export function assertConsole(ctx: Context) {
  if (!ctx.request.channels.includes('system.*')) {
    throw 'assertion failed: not console'
  }
}

export function assertSenderSystemChannel(ctx: Context) {
  if (!ctx.request.channels.includes(`system.${ctx.request.params.uuid}`)) {
    throw 'assertion failed: sender is not the owner'
  }
}

export function assertExists<T>(value: T): asserts value is NonNullable<T> {
  if (value === null || value === undefined) {
    throw 'assertion failed: value doesnt exist'
  }
}

export function assertSenderEmail(
  user: UserModel,
  senderUuid: string,
  senderEmail: string
) {
  if (user.uuid !== senderUuid || senderEmail !== user.email) {
    throw 'assertion failed: impersonation attempt'
  }
}

export function uuid() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
    var r = (Math.random() * 16) | 0,
      v = c == 'x' ? r : (r & 0x3) | 0x8
    return v.toString(16)
  })
}
