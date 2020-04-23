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

  export default KVStore
}

declare module 'pubnub' {
  class PubNub {
    grant(options: any): Promise<void>
    publish(options: { message: any; channel: string }): Promise<void>
  }

  export const pubnub: PubNub
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
