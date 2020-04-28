import xhr from 'xhr'

export class FormData {
  entries: { key: string; value: string }[] = []

  get headers(): Record<string, string> {
    return {
      'Content-Type': `application/x-www-form-urlencoded`,
    }
  }

  add(key: string, value: string) {
    this.entries.push({ key, value })
  }

  get body() {
    let body = []

    for (let { key, value } of this.entries) {
      body.push(encodeURIComponent(key) + '=' + encodeURIComponent(value))
    }

    return body.join('&')
  }
}

export const sendMail = (
  to: string,
  subject: string,
  template: string,
  variables: Record<string, string>
) => {
  let formData = new FormData()

  formData.add(
    'from',
    `PubNub Flutter Demo App <mailgun@${ENV_MAILGUN_IDENTITY}>`
  )
  formData.add('to', to)
  formData.add('subject', subject)
  formData.add('template', template)
  formData.add('h:X-Mailgun-Variables', JSON.stringify(variables))

  console.log(formData.body)

  return xhr.fetch(
    `https://api:${ENV_MAILGUN_API_KEY}@api.eu.mailgun.net/v3/${ENV_MAILGUN_IDENTITY}/messages`,
    {
      method: 'POST',
      headers: {
        ...formData.headers,
      },
      body: formData.body,
    }
  )
}
