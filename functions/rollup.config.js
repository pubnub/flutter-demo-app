import ts from '@wessberg/rollup-plugin-ts'

function module(name) {
  return {
    input: `src/${name}/index.ts`,
    output: {
      file: `dist/${name}.js`,
      format: 'iife',
      banner:
        "export default (request, response) => {\nconst pubnub = require('pubnub')",
      footer: 'return module.main(request, response);\n}',
      name: 'module',
      preferConst: true,
      globals: {
        pubnub: 'pubnub',
      },
    },
    plugins: [ts()],
    external: ['pubnub', 'kvstore', 'internal'],
  }
}

export default [module('system')]
