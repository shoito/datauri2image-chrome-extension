selectedElem = undefined
selectedText = undefined

chrome.runtime.onMessage.addListener (message, sender, sendResponse) ->
    $(selectedElem).after "<img src='" + selectedText + "'>"
    sendResponse()

$(document.body).on "mouseup", (e) ->
    selectedText = window.getSelection().toString()
    selectedText = undefined unless /^data:image\/(.+);base64,(.*)$/m.test selectedText
    chrome.runtime.sendMessage({"selectedText": selectedText})

$(document).on "contextmenu", (e) ->
    selectedElem = e.srcElement