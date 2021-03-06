#jshint camelcase: false

# Generated on 2013-05-11 using generator-chrome-extension 0.1.1
"use strict"
mountFolder = (connect, dir) ->
  connect.static require("path").resolve(dir)


# # Globbing
# for performance reasons we're only matching one level down:
# 'test/spec/{,*/}*.js'
# use this if you want to match all subfolders:
# 'test/spec/**/*.js'
module.exports = (grunt) ->
  
  # load all grunt tasks
  require("matchdep").filterDev("grunt-*").forEach grunt.loadNpmTasks
  
  # configurable paths
  yeomanConfig =
    app: "app"
    dist: "dist"

  grunt.initConfig
    yeoman: yeomanConfig
    watch:
      coffee:
        files: ["<%= yeoman.app %>/scripts/{,*/}*.coffee"]
        tasks: ["build"]

      coffeeTest:
        files: ["test/spec/{,*/}*.coffee"]
        tasks: ["coffee:test"]

      less:
        files: ["<%= yeoman.app %>/styles/**/*.less"]
        tasks: ["build"]

    connect:
      options:
        port: 9000
        
        # change this to '0.0.0.0' to access the server from outside
        hostname: "localhost"

      test:
        options:
          middleware: (connect) ->
            [mountFolder(connect, ".tmp"), mountFolder(connect, "test")]

    clean:
      dist:
        files: [
          dot: true
          src: [".tmp", "<%= yeoman.dist %>/*", "!<%= yeoman.dist %>/.git*", "package/*"]
        ]

      server: ".tmp"

    jshint:
      options:
        jshintrc: ".jshintrc"

      all: ["Gruntfile.js", "<%= yeoman.app %>/scripts/{,*/}*.js", "test/spec/{,*/}*.js"]

    mocha:
      all:
        options:
          run: true
          urls: ["http://localhost:<%= connect.options.port %>/index.html"]

    coffee:
      dist:
        files: [
          expand: true
          cwd: "<%= yeoman.app %>/scripts"
          src: "{,*/}*.coffee"
          dest: ".tmp/scripts"
          ext: ".js"
        ]

      test:
        files: [
          expand: true
          cwd: "test/spec"
          src: "{,*/}*.coffee"
          dest: ".tmp/spec"
          ext: ".js"
        ]

    less:
      production:
        files:
          "<%= yeoman.app %>/styles/*.css": "<%= yeoman.app %>/styles/{,*/}*.less"
        options:
          basePath: "app/styles"
          yuicompress: true
    
    # not used since Uglify task does concat,
    # but still available if needed
    #concat: {
    #            dist: {}
    #        },
    
    # not enabled since usemin task does concat and uglify
    # check index.html to edit your build targets
    # enable this task if you prefer defining your build targets here
    #uglify: {
    #            dist: {}
    #        },
    useminPrepare:
      html: ["<%= yeoman.app %>/popup.html", "<%= yeoman.app %>/options.html"]
      options:
        dest: "<%= yeoman.dist %>"

    usemin:
      html: ["<%= yeoman.dist %>/{,*/}*.html"]
      css: ["<%= yeoman.dist %>/styles/{,*/}*.css"]
      options:
        dirs: ["<%= yeoman.dist %>"]

    imagemin:
      dist:
        files: [
          expand: true
          cwd: "<%= yeoman.app %>/images"
          src: "{,*/}*.{png,jpg,jpeg}"
          dest: "<%= yeoman.dist %>/images"
        ]

    svgmin:
      dist:
        files: [
          expand: true
          cwd: "<%= yeoman.app %>/images"
          src: "{,*/}*.svg"
          dest: "<%= yeoman.dist %>/images"
        ]

    cssmin:
      dist:
        files:
          "<%= yeoman.dist %>/styles/main.css": [".tmp/styles/{,*/}*.css", "<%= yeoman.app %>/styles/{,*/}*.css"]

    htmlmin:
      dist:
        options: {}
        
        files: [
          expand: true
          cwd: "<%= yeoman.app %>"
          src: "*.html"
          dest: "<%= yeoman.dist %>"
        ]

    
    # Put files not handled in other tasks here
    copy:
      jquery:
        files: [
          expand: true
          dot: true
          cwd: "<%= yeoman.app %>"
          dest: ".tmp"
          src: [
            "components/jquery/jquery.js"
          ]
        ]
      dist:
        files: [
          expand: true
          dot: true
          cwd: "<%= yeoman.app %>"
          dest: "<%= yeoman.dist %>"
          src: [
            "*.{ico,txt}"
            "images/{,*/}*.{webp,gif}"
            "_locales/{,*/}*.json"
            "components/bootstrap/bootstrap/js/bootstrap.js"
            "components/bootstrap/bootstrap/img/glyphicons-halflings-white.png"
            "components/bootstrap/bootstrap/img/glyphicons-halflings.png"
            "components/bootstrap/bootstrap/css/bootstrap.css"
          ]
        ]

    concurrent:
      server: ["coffee:dist", "less"]
      test: ["coffee", "less"]
      dist: ["coffee", "less", "imagemin", "svgmin", "htmlmin", "cssmin"]

    compress:
      dist:
        options:
          archive: "package/datauri2image.zip"

        files: [
          expand: true
          cwd: "dist/"
          src: ["**"]
          dest: ""
        ]

  grunt.renameTask "regarde", "watch"
  grunt.registerTask "prepareManifest", ->
    scripts = []
    concat = grunt.config("concat") or dist:
      files: {}

    uglify = grunt.config("uglify") or dist:
      files: {}

    manifest = grunt.file.readJSON(yeomanConfig.app + "/manifest.json")
    if manifest.background.scripts
      manifest.background.scripts.forEach (script) ->
        scripts.push ".tmp" + "/" + script

      concat.dist.files["<%= yeoman.dist %>/scripts/background.js"] = scripts
      uglify.dist.files["<%= yeoman.dist %>/scripts/background.js"] = "<%= yeoman.dist %>/scripts/background.js"
    if manifest.content_scripts
      manifest.content_scripts.forEach (contentScript) ->
        if contentScript.js
          contentScript.js.forEach (script) ->
            uglify.dist.files["<%= yeoman.dist %>/" + script] = ".tmp/" + script


    grunt.config "concat", concat
    grunt.config "uglify", uglify

  grunt.registerTask "manifest", ->
    manifest = grunt.file.readJSON(yeomanConfig.app + "/manifest.json")
    manifest.background.scripts = ["scripts/background.js"]
    grunt.file.write yeomanConfig.dist + "/manifest.json", JSON.stringify(manifest, null, 2)

  grunt.registerTask "test", ["clean:server", "concurrent:test", "connect:test", "mocha"]
  grunt.registerTask "build", ["clean:dist", "copy:jquery", "prepareManifest", "useminPrepare", "concurrent:dist", "concat", "uglify", "copy:dist", "usemin", "manifest", "compress"]
  grunt.registerTask "default", ["jshint", "test", "build"]
