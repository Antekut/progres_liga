import withNuxt from './.nuxt/eslint.config.mjs'
import tsEslintPlugin from '@typescript-eslint/eslint-plugin'
import tsParser from '@typescript-eslint/parser'
import vueParser from 'vue-eslint-parser'
import { globalIgnores } from 'eslint/config'
import stylistic from '@stylistic/eslint-plugin'

export default withNuxt([
  globalIgnores([
    'node_modules/**',
    '.nuxt/**',
    '.output/**',
    'dist/**',
    'nuxt.config.ts',
    'eslint.config.mjs',
  ]),
  {
    files: ['app/**/*.{ts,vue}', 'app.vue'],
  },
  {
    languageOptions: {
      parser: vueParser,
      parserOptions: {
        parser: tsParser,
        ecmaVersion: 'latest',
        sourceType: 'module',
        project: './tsconfig.eslint.json',
        extraFileExtensions: ['.vue'],
      },
    },
  },
  {
    plugins: {
      '@stylistic': stylistic,
      '@typescript-eslint': tsEslintPlugin,
    },
    rules: {
      'no-unused-vars': 'off',
      '@stylistic/indent': ['error', 2],
      '@stylistic/object-curly-spacing': ['error', 'always'],
      '@stylistic/semi': ['error', 'never'],
      'vue/multi-word-component-names': 'off',
      'vue/html-indent': ['error', 2],
      'vue/html-self-closing': [
        'error',
        {
          html: { void: 'always', normal: 'never', component: 'always' },
        },
      ],
      '@typescript-eslint/no-unused-vars': ['warn', { argsIgnorePattern: '^_' }],
      'prefer-const': 'error',
      eqeqeq: ['error', 'always'],
      'no-var': 'error',
    },
  },
])
