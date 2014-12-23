_ = require 'lodash'

number = 0
junk = []
while number < 10000000
  junk.push number
  number++

lodashJunk = _.clone junk, true

beginning = new Date().getMilliseconds()
beginning = new Date().getSeconds() + ':' + beginning

lodashJunk = _.map lodashJunk, (number) ->
  number + 1.01

ending = new Date().getMilliseconds()
ending = new Date().getSeconds() + ':' + ending

console.log 'LODASH BEGINNING | END ', beginning, ' | ', ending

beginning = new Date().getMilliseconds()
beginning = new Date().getSeconds() + ':' + beginning

for numberIndex in [0..junk.length - 1] by 1
  junk[numberIndex] += 1.01

ending = new Date().getMilliseconds()
ending = new Date().getSeconds() + ':' + ending

console.log 'FOR BEGINNING | END ', beginning, ' | ', ending