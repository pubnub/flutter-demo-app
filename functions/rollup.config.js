import ts from '@wessberg/rollup-plugin-ts'
import replace from '@rollup/plugin-replace'
import dotenv from 'dotenv'

dotenv.config()

function module(name) {
  return {
    input: `src/${name}/index.ts`,
    output: {
      file: `dist/${name}.js`,
      format: 'iife',
      banner: `export default (request, response) => {
  const pubnub = require('pubnub');
  const kvstore = require('kvstore');
  const xhr = require('xhr');
  const utils = require('utils');
  `,
      footer: 'return module.main(request, response);\n}',
      name: 'module',
      preferConst: true,
      globals: {
        pubnub: 'pubnub',
        kvstore: 'kvstore',
        xhr: 'xhr',
        utils: 'utils',
      },
    },
    plugins: [
      replace({
        ENV_MAILGUN_API_KEY: `"${process.env.MAILGUN_API_KEY}"`,
        ENV_MAILGUN_IDENTITY: `"${process.env.MAILGUN_IDENTITY}"`,
      }),
      ts(),
    ],
    external: ['pubnub', 'kvstore', 'internal', 'xhr', 'utils'],
  }
}

export default [module('system'), module('send-code')]
