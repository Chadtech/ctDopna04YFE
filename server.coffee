fs          = require 'fs'
express     = require 'express'
app         = express()
http        = require 'http'
{join}      = require 'path'
bodyParser  = require 'body-parser'
Nt          = require './NtYhS/noitech'
_           = require 'lodash'
init        = require './init'


app.use bodyParser.json()

app.use bodyParser({limit: '50mb'})
app.use bodyParser.urlencoded {extended: true}

PORT = Number process.env.PORT or 1776

router = express.Router()


router.route '/create'
  .post (request, response, next) ->

    projectString = request.body.project
    project       = JSON.parse request.body.project

    if not fs.existsSync project.name
      fs.mkdirSync project.name
      pathToJSON = project.name + '/' + project.name + '.json'
      fs.writeFileSync pathToJSON, request.body.project
      response.json message: 'worked'
    else
      response.json message: 'didnt worked'


router.route '/open'
  .post (request, response, next) ->

    projectName = request.body.projectName

    if fs.existsSync projectName
      pathToFile = projectName + '/' + projectName + '.json'
      project = fs.readFileSync pathToFile, 'utf8'

      response.json {project: project, message: 'worked'}
    else
      response.json message: 'didnt worked'


router.route '/update'
  .post (request, response, next) ->

    projectName = request.body.projectName

    if not fs.existsSync projectName
      fs.mkdirSync projectName
    pathToJSON = projectName + '/' + projectName + '.json'
    fs.writeFileSync pathToJSON, request.body.project

    response.json {message: 'worked'}


router.route '/build'
  .post (request, response, next) ->

    projectName = request.body.projectName
    currentPart = request.body.currentPart

    data =
      name:         projectName
      project:      request.body.project
      currentPart:  currentPart

    init(data)

    response.json {message: 'worked'}


router.route '/play'
  .post (request, response, next) ->

    projectName = request.body.projectName
    currentPart = request.body.currentPart

    data =
      name:         projectName
      project:      request.body.project
      currentPart:  currentPart

    #init(data)

    pathToAudio =  projectName + '/'
    pathToAudio += projectName + '.wav'

    responseObject = 
      message:    'worked'
      audioData:  (Nt.open 'stPuchLR.wav')

    response.json responseObject


app.use '/api', router

app.use express.static join __dirname, 'public'

app.get '/', (request, response, next) ->
  indexPage = join __dirname, 'public/index.html'
  response.status 200
    .sendFile indexPage

httpServer = http.createServer app

httpServer.listen PORT, ->
  console.log 'SERVER RUNNING ON ' + PORT