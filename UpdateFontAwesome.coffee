###
   @author: Martin Pavlik
###

module.exports = (grunt) ->
   grunt.registerTask 'update-fa', "Updates from FontAwesome 3 to 4", () ->
      fsOptions = 
         encoding: 'utf-8'

      options =
         src: [
            './libs/**/*'
            './app/**/*'
            './www/**/*'
         ]
         extensions: [
            'php', 'html', 'phtml', 'coffee', 'latte', 'js', 'coffee'
         ]

      errors = []

      rules = require './UpdateFontAwesome/rules.coffee'

      writeFile = (abspath, contents) ->
         grunt.file.write abspath, contents, fsOptions

      checkFile = (abspath) ->

         grunt.log.writeln "testing -> #{abspath}"

         # Read file to buffer
         try 
            buffer = grunt.file.read abspath, fsOptions
         catch e
            grunt.log.writeln "ERROR while opening: #{abspath}\n=========="
            grunt.log.error e
            errors.push e
            grunt.log.writeln "=========="
            return
         

         # Convert buffer to string
         contents = buffer.toString fsOptions.encoding, 0, buffer.length

         # Replace all instances of old icons with new ones
         newContents = contents
         for o, n of rules

            ###
               Match everything but fa fa- with prefix glyph
                  so:
                     glyphicon-test : no match
                     glyph fa fa-test : match
                     fa fa-test : match
                     hello fa fa-test : match
            ###
            regex = new RegExp("(glyph)?icon-#{o}", "gi")

            newContents = newContents.replace regex, ($0, $1) ->
               if $1
                  return $0
               else
                  return "fa fa-#{n}"

         ###
            Replace all other remaining icons!
         ###
         regex = new RegExp "(glyph)?(icon-)([^\s]+)", "gi"
         newContents = newContents.replace regex, ($0, $1, $2, $3) ->
               if $1
                  return $0
               else
                  return "fa fa-#{$3}"

         newContents = newContents.replace "fa fa-white", "icon-white"

         if contents isnt newContents
            writeFile(abspath, newContents) 
            grunt.log.writeln "\t fixed"
         else
            grunt.log.writeln "\t no fix needed"

      grunt.log.writeln "Oh, this might take a while. Wait a moment please, searching all relevant files..."

      grunt.file.expand(options.src).forEach (src) ->
         ext = src.split('.').pop()

         if ext and ext in options.extensions
            checkFile src
         else
            grunt.log.writeln "#{src}\n -> ignored"

      grunt.log.writeln "\n\n\nWarnings:"
      grunt.log.writeln e for e in errors 

