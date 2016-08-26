const env = process.env.MIX_ENV === 'prod' ? 'production' : 'development';
const Webpack = require('webpack');

const plugins = {
    production: [
        new Webpack.optimize.UglifyJsPlugin({
            exclude: /\.phoenix\.js/i,
            compress: {warnings: false}
        })
    ],
    development: []
};

module.exports = {
    entry: {
        component: './web/static/js/server_render.js'
    },
    output: {
        path: './priv/static/server/js',
        filename: 'app.js',
        library: 'app',
        libraryTarget: 'commonjs2'
    },
    module: {
        noParse: /\.elm$/,
        loaders: [
            {
                test: /\.js$/,
                exclude: /node_modules/,
                loader: 'babel',
                query: {
                    presets: ['es2015']
                }
            },
            {
                test: /\.elm$/,
                exclude: [/elm-stuff/, /node_modules/],
                loader: 'elm-webpack'
            }
        ]
    },
    resolve: {
        alias: {
            phoenix_html:
                __dirname + '/deps/phoenix_html/web/static/js/phoenix_html.js',
            phoenix:
                __dirname + './deps/phoenix/web/static/js/phoenix.js'
        }
    },
    plugins: [
        // Important to keep React file size down
        new Webpack.DefinePlugin({
            'process.env': {
                'NODE_ENV': JSON.stringify(env)
            }
        })
    ].concat(plugins[env])
};
