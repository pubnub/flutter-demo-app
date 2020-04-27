import xhr from 'xhr'

export const sendMail = (to: string, subject: string, content: string) => {
  return xhr.fetch('https://api.sendgrid.com/v3/mail/send', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${ENV_SENDGRID_API_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      personalizations: [
        {
          to: [{ email: to }],
        },
      ],
      from: {
        email: 'artur.wojciechowski@pubnub.com',
      },
      subject: subject,
      content: [{ type: 'text/html', value: content }],
    }),
  })
}
