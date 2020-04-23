import { KVStore } from 'kvstore'

type Constructor<T extends IModel> = {
  new (...[]: any[]): T
  fromJson(data: unknown): T
  storagePrefix: string
}

abstract class IModel {
  abstract key(): string
  abstract toJson(): string
}

export class Model<T extends IModel> {
  modelConstructor: Constructor<T>

  constructor(modelConstructor: Constructor<T>) {
    this.modelConstructor = modelConstructor
  }

  static of<T extends IModel>(modelConstructor: Constructor<T>) {
    return new this(modelConstructor)
  }

  construct(...args: any[]): T {
    return new this.modelConstructor(...args)
  }
}

export class Storage {
  private kvstore: KVStore

  constructor() {
    this.kvstore = require('kvstore')
  }

  async load<T extends IModel>(
    model: Model<T>,
    key: string
  ): Promise<T | null> {
    const data = await this.kvstore.get(
      `${model.modelConstructor.storagePrefix}${key}`
    )

    return model.modelConstructor.fromJson(data)
  }

  async save<T extends IModel>(instance: T): Promise<void> {
    const data = instance.toJson()

    return this.kvstore.set(instance.key(), data)
  }

  async delete<T extends IModel>(model: Model<T>, key: string): Promise<void> {
    return this.kvstore.set(
      `${model.modelConstructor.storagePrefix}${key}`,
      null
    )
  }
}
