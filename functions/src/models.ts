import { Model } from './storage'

export class AccountModel {
  static storagePrefix = 'account-'

  key(): string {
    return `${AccountModel.storagePrefix}${this.uuid}`
  }

  constructor(
    public uuid: string,
    public email: string,
    public authKey: string
  ) {}

  static fromJson(data: any) {
    return new this(data.uuid, data.email, data.authKey)
  }

  toJson(): Record<string, any> {
    return {
      uuid: this.uuid,
      email: this.email,
      authKey: this.authKey,
    }
  }
}

export class UserModel {
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

  toJson(): Record<string, any> {
    return {
      email: this.email,
      authKey: this.authKey,
      uuid: this.uuid,
    }
  }
}

export class ProfileModel {
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

  toJson(): Record<string, any> {
    return {
      uuid: this.uuid,
      displayName: this.displayName,
      avatar: this.avatar,
    }
  }

  static fromJson(data: any) {
    return new this(data.uuid, data.displayName, data.avatar)
  }
}

export class FriendsModel {
  static storagePrefix = 'user-friends-'
  key(): string {
    return `${FriendsModel.storagePrefix}${this.uuid}`
  }

  constructor(public uuid: string, public friends: string[]) {}

  static fromJson(data: any): FriendsModel {
    return new this(data.uuid, data.friends)
  }

  toJson(): Record<string, any> {
    return {
      uuid: this.uuid,
      friends: this.friends,
    }
  }
}

export class InvitationsModel {
  static storagePrefix = 'user-invitations-'
  key(): string {
    return `${InvitationsModel.storagePrefix}${this.uuid}`
  }

  constructor(public uuid: string, public invitations: string[]) {}

  static fromJson(data: any): InvitationsModel {
    return new this(data.uuid, data.invitations)
  }

  toJson(): Record<string, any> {
    return {
      uuid: this.uuid,
      invitations: this.invitations,
    }
  }
}

export const Profile = Model.of(ProfileModel)
export const Friends = Model.of(FriendsModel)
export const Invitations = Model.of(InvitationsModel)
export const User = Model.of(UserModel)
export const Account = Model.of(AccountModel)
