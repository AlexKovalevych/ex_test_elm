module.exports = {
    config: {
        paths: {
            watched: [
                'web/static/elm',
                'web/static/css',
                'web/static/assets'
            ],
            public: 'priv/static'
        },
        files: {
            stylesheets: {
                joinTo: 'css/app.css',
                order: {
                    before: [
                        'web/static/css/material.min.css',
                        'web/static/css/fonts.css'
                    ]
                }
            }
        },
        plugins: {
            elmBrunch: {
                executablePath: './node_modules/elm/binwrappers',
                mainModules: ['web/static/elm/Main.elm'],
                outputFolder: 'priv/static/js',
                outputFile: 'app.js'
            }
        }
    }
};
