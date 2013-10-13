#
# * node-hbs-pdf
# * Copyright(c) 2013 Dave Tonge <dave@simplecreativity.co.uk>
# * Part inspired by invoice-pdf from Storify
#

###
Module dependencies.
###
Handlebars = require('handlebars')
Swag = require('swag')
Swag.registerHelpers(Handlebars)
phantom = require("phantom")
_ = require "underscore"
fs = require "fs"
crypto = require("crypto")
stringify = require "json-stringify-safe"

defaults =
  tempDir: "/tmp"
  pageSize: "letter"
  pageMargin: "1cm"

capture = (data, html, callback) ->

  filePath = data.tempDir + "/" + crypto.createHash("md5").update(stringify(data)).digest("hex") + ".pdf"

  phantom.create (ph) ->
    ph.createPage (page) ->
      page.set "viewportSize", {width: 840,  height: 1400}, ->
        page.set "content", html, ->
          page.set "paperSize", {format: data.pageSize, orientation: "portrait", margin: data.pageMargin },->
            page.render filePath, (err) ->
              callback err, filePath
              ph.exit()


module.exports = (data, callback) ->
  try
    data = _.defaults data, defaults
    template = Handlebars.compile fs.readFileSync(data.template).toString()
    html = template(data)
  catch e
    return callback(e)
  capture data, html, callback