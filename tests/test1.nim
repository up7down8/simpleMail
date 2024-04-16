# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest

import simpleMail
test "print message":
  let message = initMessage("This is test subject", "sendFrom@test.com", @["sendTo@test.com"], @["ccTo@test.com"], @[("addHeaderName", "addHeaderValue")], "6328fdefd21m83jfffmf")
  echo $message
  

test "print html and files message":
  let message = initMessage("This is test subject", "sendFrom@test.com", @["sendTo@test.com"], @["ccTo@test.com"], @[("addHeaderName", "addHeaderValue")], "6328fdefd21m83jfffmf")
  message.addHtml("<h1>header1</h1>")
  message.addFiles(@["./tests/test1.nim"])
  echo $message
