import { Model } from './storage'

export const User = Model.of(
  class UserModel {
    static storagePrefix = 'user-account-'

    key(): string {
      return `${UserModel.storagePrefix}${this.email}`
    }

    email: string
    authKey: string
    uuid: string

    constructor(email: string, authKey: string, uuid: string) {
      this.email = email
      this.authKey = authKey
      this.uuid = uuid
    }

    static fromJson(data: any) {
      return new this(data.email, data.authKey, data.uuid)
    }

    toJson(): string {
      return JSON.stringify({
        email: this.email,
        authKey: this.authKey,
        uuid: this.uuid,
      })
    }
  }
)

export const Profile = Model.of(
  class ProfileModel {
    static storagePrefix = 'user-profile-'

    key(): string {
      return `${ProfileModel.storagePrefix}${this.uuid}`
    }

    constructor(
      public uuid: string,
      public displayName: string,
      public avatar: {
        emoji: string
        color: number
      }
    ) {}

    update(data: any) {
      if (typeof data.displayName === 'string') {
        this.displayName = data.displayName
      }

      if (data.avatar && typeof data.avatar.emoji === 'string') {
        this.avatar.emoji = data.avatar.emoji
      }

      if (data.avatar && typeof data.avatar.color === 'number') {
        this.avatar.color = data.avatar.color
      }
    }

    toJson(): string {
      return JSON.stringify({
        uuid: this.uuid,
        displayName: this.displayName,
        avatar: this.avatar,
      })
    }

    static fromJson(data: any) {
      return new this(data.uuid, data.displayName, data.avatar)
    }
  }
)
