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
      banner:
        "export default (request, response) => {\nconst pubnub = require('pubnub');\nconst kvstore = require('kvstore');\nconst xhr = require('xhr');\n",
      footer: 'return module.main(request, response);\n}',
      name: 'module',
      preferConst: true,
      globals: {
        pubnub: 'pubnub',
        kvstore: 'kvstore',
        xhr: 'xhr',
      },
    },
    plugins: [
      replace({
        ENV_SENDGRID_API_KEY: `"${process.env.SENDGRID_API_KEY}"`,
        ENV_SENDGRID_IDENTITY: `"${process.env.SENDGRID_IDENTITY}"`,
      }),
      ts(),
    ],
    external: ['pubnub', 'kvstore', 'internal', 'xhr'],
  }
}

export default [module('system')]
