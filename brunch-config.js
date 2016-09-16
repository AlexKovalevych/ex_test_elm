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
            },
            copycat:{
                'js' : ['node_modules/chart.js/dist/Chart.min.js'],
                // "images": ["someDirectoryInProject", "bower_components/some_package/assets/images"],
                verbose : true, //shows each file that is copied to the destination directory
                onlyChanged: true //only copy a file if it's modified time has changed (only effective when using brunch watch)
            }
        }
    }
};
