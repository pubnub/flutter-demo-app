import { Request } from 'internal'
import { Storage } from '../storage'

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
