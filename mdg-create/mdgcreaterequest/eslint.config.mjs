import fioriTools from '@sap-ux/eslint-plugin-fiori-tools';
import tseslint from 'typescript-eslint';

export default [
    {
        ignores: [
            'dist/**',
            'node_modules/**'
        ]
    },
    ...fioriTools.configs.recommended,
    {
        files: [
            '**/*.ts'
        ],
        languageOptions: {
            parser: tseslint.parser
        }
    }
];
