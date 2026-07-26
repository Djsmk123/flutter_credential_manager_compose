import typescript from 'rollup-plugin-typescript2';
import resolve from 'rollup-plugin-node-resolve';
import commonjs from 'rollup-plugin-commonjs';

export default {
    input: 'src/index.ts',
    output: {
        file: '../../web/passkey_authenticator.js',
        format: 'iife',
        name: 'CredentialManagerWeb',
    },
    plugins: [
        resolve({
            browser: true,
        }),
        commonjs(),
        typescript({
            tsconfig: 'tsconfig.json',
        }),
    ],
};