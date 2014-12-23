fs = require 'fs'
express = require 'express'
app = express()
http = require 'http'
{join} = require 'path'
bodyParser = require 'body-parser'
Nr = require './noideread'
_ = require 'lodash'

app.use bodyParser.urlencoded {extended: true}
app.use bodyParser.json()

PORT = Number process.env.PORT or 8097

router = express.Router()

router.use (request, response, next) ->
  console.log 'SOMETHIGN HAPPEN'
  next()

router.route '/:project'
  .get (request, response, next) ->
    projectTitle = request.params.project
    projectPath = projectTitle + '/' + projectTitle + '.json'
    fs.exists projectPath, (exists) ->
      return next() unless exists
      response.json project: fs.readFileSync projectPath, 'utf8'

  .post (request, response, next) ->
    project = request.body.project
    project = JSON.parse project
    if fs.existsSync project.title
      JSONInPath = project.title + '/' + project.title + '.json'
      fs.writeFileSync JSONInPath, JSON.stringify project, null, 2
      response.json msg: 'WORKD'
    else
      fs.mkdirSync project.title
      JSONInPath = project.title + '/' + project.title + '.json'
      fs.writeFileSync JSONInPath, JSON.stringify project, null, 2
      response.json msg: 'WORKD'

router.route '/play/:project'
  .post (request, response, next) ->
    project = request.body.project
    project = JSON.parse project
    clonedProject = _.clone project, true
    response.json {buffer: Nr.handleLatest project}
    JSONInPath = clonedProject.title + '/' + clonedProject.title + '.json'
    fs.writeFileSync JSONInPath, JSON.stringify clonedProject, null, 2
    
router.route '/init/:project'
  .post (request, response, next) ->
    project = request.body.project
    project = JSON.parse project
    clonedProject = _.clone project, true
    Nr.assembleAll project
    response.json msg: 'FINISHD'
    JSONInPath = clonedProject.title + '/' + clonedProject.title + '.json'
    fs.writeFileSync JSONInPath, JSON.stringify clonedProject, null, 2

app.use express.static join __dirname, 'public'

app.use '/api', router

app.get '/*', (request, response, next) ->
  htmlFileThroughWhichAllContentIsFunnelled = join __dirname, 'public/index.html'
  response.status 200
    .sendFile htmlFileThroughWhichAllContentIsFunnelled

httpServer = http.createServer app

httpServer.listen PORT, ->
  console.log 'SERVER RUNNING ON ' + PORT