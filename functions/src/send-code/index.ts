import { Request, Response } from 'internal'

import kvstore from 'kvstore'
import utils from 'utils'

import { sendMail } from '../mail'

async function handler(request: Request, response: Response) {
  const body = await request.json()

  const email = body.email

  console.log(email)

  if (!/(.+)@(.+){2,}\.(.+){2,}/.test(email)) {
    throw { error: 'bad_email' }
  }

  const code = Array.from(Array(6), () => utils.randomInt(0, 9)).join(' ')

  console.log(code)

  await kvstore.set(
    `login-${email}`,
    {
      code: code,
      email: email,
    },
    60
  )

  let result = await sendMail(
    email,
    'Verification Code for PubNub Flutter Demo App',
    'login',
    {
      code: code,
    }
  )

  console.log(result)
}

export async function main(request: Request, response: Response) {
  response.headers = { 'Content-Type': 'application/json' }

  console.log(request)

  try {
    await handler(request, response)
    response.status = 200
    response.body = JSON.stringify({ success: true })
  } catch (e) {
    response.status = 400
    response.body = JSON.stringify(e)
  } finally {
    return response.send()
  }
}
