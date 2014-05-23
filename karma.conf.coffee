module.exports = (config) ->
  config.set
    basePath: ""

    frameworks: ["mocha", "chai", "browserify"]
    files: ["node_modules/es5-shim/es5-shim.js"]

    reporters: ["spec"]

    port: 9876
    colors: true
    logLevel: config.LOG_INFO

    singleRun: true
    autoWatch: false

    browsers: ["PhantomJS"]

    captureTimeout: 60000

    browserify:
      debug: true
      files: ["test/*.coffee"]
      extensions: [".coffee"]
      noParse: ["lodash", "react"]

    preprocessors:
      "/**/*.browserify": "browserify"
