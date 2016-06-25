const env = process.env.MIX_ENV === 'prod' ? 'production' : 'development';
const Webpack = require('webpack');
const ExtractTextPlugin = require('extract-text-webpack-plugin');
const CopyPlugin = require('copy-webpack-plugin');
const Autoprefixer = require('autoprefixer');

const plugins = {
    production: [
        new Webpack.optimize.UglifyJsPlugin({
            compress: {warnings: false}
        })
    ],
    development: []
};

const URLLoader = (dir, mimetype, limit) => {
    return 'url?' + [
        `limit=${limit}`,
        `mimetype=${mimetype}`,
        `name=${dir}/app/[name].[ext]`
    ].join('&');
};

var devtool;
if (env === 'development') {
    devtool = 'inline-source-map';
}

module.exports = {
    devtool: devtool,
    entry: [
        './web/static/js/index.js',
        'bootstrap/dist/css/bootstrap.css',
        './web/static/css/app.css'
    ],
    output: {
        path: './priv/static',
        filename: 'js/app.js',
        publicPath: '/'
    },
    module: {
        loaders: [{
            test: /\.js$/,
            exclude: /node_modules/,
            loader: 'babel',
            query: {
                plugins: ['transform-decorators-legacy'],
                presets: ['react', 'es2015', 'stage-2']
            }
        },
        {
            test: /\.css$/,
            loader: ExtractTextPlugin.extract('style', 'css?localIdentName=[hash:base64]!postcss')
        },
        {
            test: /\.png$/,
            loader: URLLoader('images', 'image/png', 10000)
        }, {
            test: /\.gif$/,
            loader: URLLoader('images', 'image/gif', 10000)
        }, {
            test: /\.jpg$/,
            loader: URLLoader('images', 'image/jpeg', 10000)
        }, {
            test: /\.(woff|woff2)$/,
            loader: URLLoader('fonts', 'application/x-font-woff', 10000)
        }, {
            test: /\.ttf$/,
            loader: URLLoader('fonts', 'application/x-font-ttf', 10000)
        }, {
            test: /\.eot$/,
            loader: URLLoader('fonts', 'application/vnd.ms-fontobject', 10000)
        }, {
            test: /\.svg$/,
            loader: URLLoader('fonts', 'image/svg+xml', 10000)
        }]
    },
    postcss: [
        Autoprefixer({
            browsers: ['last 2 versions']
        })
    ],
    resolve: {
        extensions: ['', '.js', '.less', '.css'],
        modulesDirectories: ['node_modules', __dirname + '/web/static/js'],
        alias: {
            styles: __dirname + '/web/static/css'
        }
    },
    plugins: [
        // Important to keep React file size down
        new Webpack.DefinePlugin({
            'process.env': {
                'NODE_ENV': JSON.stringify(env)
            }
        }),
        new Webpack.optimize.DedupePlugin(),
        new ExtractTextPlugin('css/app.css'),
        new CopyPlugin([{from: './web/static/assets'}])
    ].concat(plugins[env])
};
