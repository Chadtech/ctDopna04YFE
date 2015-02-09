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

    console.log '6'

    projectName = request.body.projectName
    currentPart = request.body.currentPart

    data =
      name:         projectName
      project:      request.body.project
      currentPart:  currentPart

    console.log '7'

    #init(data)

    console.log '8'

    pathToAudio =  projectName + '/'
    pathToAudio += projectName + '.wav'

    console.log '9'

    responseObject = 
      message:    'worked'
      audioData:  (Nt.open 'stPuchL.wav')[0]

    console.log '9.1'

    response.json responseObject



  # router.use (request, response, next) ->
  #   console.log 'SOMETHIGN HAPPEN'
  #   next()

# router.route '/:project'
#   .get (request, response, next) ->
#     projectTitle = request.params.project
#     projectPath = projectTitle + '/' + projectTitle + '.json'
#     fs.exists projectPath, (exists) ->
#       return next() unless exists
#       response.json project: fs.readFileSync projectPath, 'utf8'

#   .post (request, response, next) ->
#     project = request.body.project
#     project = JSON.parse project
#     if fs.existsSync project.title
#       JSONInPath = project.title + '/' + project.title + '.json'
#       fs.writeFileSync JSONInPath, JSON.stringify project, null, 2
#       response.json msg: 'WORKD'
#     else
#       fs.mkdirSync project.title
#       JSONInPath = project.title + '/' + project.title + '.json'
#       fs.writeFileSync JSONInPath, JSON.stringify project, null, 2
#       response.json msg: 'WORKD'

# router.route '/play/:project'
#   .post (request, response, next) ->
#     project = request.body.project
#     project = JSON.parse project
#     clonedProject = _.clone project, true
#     response.json {buffer: Nr.handleLatest project}
#     JSONInPath = clonedProject.title + '/' + clonedProject.title + '.json'
#     fs.writeFileSync JSONInPath, JSON.stringify clonedProject, null, 2
    
# router.route '/init/:project'
#   .post (request, response, next) ->
#     project = request.body.project
#     project = JSON.parse project
#     clonedProject = _.clone project, true
#     Nr.assembleAll project
#     response.json msg: 'FINISHD'
#     JSONInPath = clonedProject.title + '/' + clonedProject.title + '.json'
#     fs.writeFileSync JSONInPath, JSON.stringify clonedProject, null, 2



app.use '/api', router

app.use express.static join __dirname, 'public'

app.get '/', (request, response, next) ->
  indexPage = join __dirname, 'public/index.html'
  response.status 200
    .sendFile indexPage

httpServer = http.createServer app

httpServer.listen PORT, ->
  console.log 'SERVER RUNNING ON ' + PORT