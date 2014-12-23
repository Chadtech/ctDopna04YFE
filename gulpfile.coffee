gulp = require 'gulp'
concat = require 'gulp-concat'
stylus = require 'gulp-stylus'
jade = require 'gulp-jade'
reload = require 'gulp-livereload'
awatch = require 'gulp-autowatch'
source = require 'vinyl-source-stream'
buffer = require 'vinyl-buffer'
coffeeify = require 'coffeeify'
browserify = require 'browserify'

paths =
  public: './public'
  coffee: './client/js/*.coffee'
  jade:   './client/html/*.jade'
  stylus: './client/css/*.styl'

gulp.task 'server', (cb) ->
  require './server'

gulp.task 'coffee', ->
  bCache = {}
  b = browserify './client/js/ctDPNQPTFS03.coffee',
    debug: true
    interestGlobals: false
    cache: bCache
    extensions: ['.coffee']
  b.transform coffeeify
  b.bundle()
  .pipe source 'ctDPNQPTFS03.js'
  .pipe buffer()
  .pipe gulp.dest paths.public
  .pipe reload()

gulp.task 'jade', ->
  gulp.src paths.jade
  .pipe jade()
  .pipe gulp.dest paths.public
  .pipe reload()

gulp.task 'stylus', ->
  gulp.src paths.stylus
  .pipe stylus()
  .pipe gulp.dest paths.public
  .pipe reload()

gulp.task 'watch', ->
  awatch gulp,
    jade: './client/html/*.jade'
    stylus: './client/css/*.styl'
    coffee: './client/js/*.coffee'

gulp.task 'default', ['coffee', 'jade', 'stylus', 'server', 'watch']