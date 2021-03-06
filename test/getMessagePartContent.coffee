require("mocha-cakes")
should = require("should")
utf8 = require("utf8")
app = require("./context/appContext")
request = app.request

Feature "Get message part content",
	"As a user",
	"I want to get the message part content of the messages in my mailbox",
	"So that a can download the attachments", ->

		Scenario "Unauthenticated user", ->
			result = null
			error = null
			Given "An unauthenticated user", (done)->
				app.logout(done)
			When "I send a request", (done)->
				request.get("/boxes/INBOX/messages/16/parts/1.1/content").end (err, res)->
					error = err
					result = res
					done()
			Then "it should get a result", ->
				should.not.exist error
				should.exist result
			And "the response should be a HTTP 401", ->
				result.statusCode.should.be.exactly 401

		Scenario "Get the content of a non existing message", ->
			result = null
			error = null
			Given "An authenticated user", (done)->
				app.login(done)
			When "I send a request", (done)->
				request.get("/boxes/INBOX/messages/999999/parts/1").end (err, res)->
					error = err
					result = res
					done()
			Then "it should get a result", ->
				should.not.exist error
				should.exist result
			And "the response should be a HTTP 404", ->
				result.statusCode.should.be.exactly 404

		Scenario "Get an existing part content encoded in base64", ->
			result = null
			error = null
			Given "An authenticated user", (done)->
				app.login(done)
			When "I send a request", (done)->
				request.get("/boxes/INBOX/messages/16/parts/2/content").end (err, res)->
					error = err
					result = res
					done()
			Then "it should get a result", ->
				should.not.exist error
				should.exist result
			And "the response should be a HTTP 200", ->
				result.statusCode.should.be.exactly 200
			And "the response should contains the part content", ->
				result.text.should.be.exactly("Voici le contenu de la PJ")
			And "the response have the right content type", ->
				result.header["content-type"].should.be.startWith("text/plain")
			And "the response have the right content disposition", ->
				result.header["content-disposition"].should.be.exactly("attachment; filename=\"myAttachment_base64.txt\"")

		Scenario "Get an existing part content encoded in quoted-printable with utf-8 charset", ->
			result = null
			error = null
			Given "An authenticated user", (done)->
				app.login(done)
			When "I send a request", (done)->
				request.get("/boxes/INBOX/messages/17/parts/1/content").end (err, res)->
					error = err
					result = res
					done()
			Then "it should get a result", ->
				should.not.exist error
				should.exist result
			And "the response should be a HTTP 200", ->
				result.statusCode.should.be.exactly 200
			And "the response should contains the part content", ->
				utf8.decode(result.text).should.be.exactly("Accents: àèëäÄù%$!:\"'}{")
			And "the response have the right content type", ->
				result.header["content-type"].should.be.startWith("text/plain")
				(result.header["content-type"].indexOf("charset=utf-8") > -1).should.be.true
			And "the response have the right content disposition", ->
				result.header["content-disposition"].should.be.exactly("attachment; filename=\"attachment\"")

		Scenario "Get an existing part content encoded in quoted-printable with iso-8859-1 charset", ->
			result = null
			error = null
			Given "An authenticated user", (done)->
				app.login(done)
			When "I send a request", (done)->
				request.get("/boxes/INBOX/messages/18/parts/1/content").end (err, res)->
					error = err
					result = res
					done()
			Then "it should get a result", ->
				should.not.exist error
				should.exist result
			And "the response should be a HTTP 200", ->
				result.statusCode.should.be.exactly 200
			And "the response should contains the part content", ->
				result.text.should.be.exactly("Accents: àèëäÄù%$!:\"'}{")
			And "the response have the right content type", ->
				result.header["content-type"].should.be.startWith("text/plain")
				(result.header["content-type"].indexOf("charset=iso-8859-1") > -1).should.be.true
			And "the response have the right content disposition", ->
				result.header["content-disposition"].should.be.exactly("attachment; filename=\"attachment\"")
