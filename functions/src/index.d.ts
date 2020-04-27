declare module 'kvstore' {
  export class KVStore {
    set<T>(key: string, data: T, ttl?: number): Promise<void>
    get<T>(key: string): Promise<T>

    setItem(key: string, data: string, ttl?: number): Promise<void>
    getItem(key: string): Promise<String>
    removeItem(key: string): Promise<void>
    getKeys(): Promise<Array<String>>

    getCounter(key: string): Promise<number>
    incrCounter(key: string, value: number): Promise<void>
    getCounterKeys(): Promise<Array<String>>
  }

  const kvstore: KVStore

  export default kvstore
}

declare module 'pubnub' {
  type PublishOptions = { message: any; channel: string }

  class PubNub {
    grant(options: any): Promise<void>
    publish(options: PublishOptions): Promise<void>
    fire(options: PublishOptions): Promise<void>
  }

  const pubnub: PubNub

  export default pubnub
}

declare module 'xhr' {
  class XHR {
    fetch(
      url: string,
      options: {
        method: string
        headers: Record<string, string>
        body: string
      }
    ): Promise<void>
  }

  const xhr: XHR

  export default xhr
}

declare module 'internal' {
  export class Request {
    ok(): Promise<void>

    verb: string
    pubkey: string
    subkey: string
    version: string
    meta: {
      clientip: string
      origin: string
      useragent: string
    }
    params: {
      uuid: string
      pnsdk: string
      timestamp: string
      signature: string
    }
    uri: string
    channels: Array<string>
    callback: string
    message: any
    messageSize: number
  }

  export const request: Request
}

declare const ENV_SENDGRID_API_KEY: string
declare const ENV_SENDGRID_IDENTITY: string
