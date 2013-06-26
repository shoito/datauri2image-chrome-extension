selectedText = undefined
menuItemId = chrome.contextMenus.create
    "id": "datauri2image"
    "title": "Data URI to Image"
    "contexts": ["selection"]

chrome.contextMenus.onClicked.addListener (info, tab) ->
    if info.menuItemId is "datauri2image"
        chrome.tabs.sendMessage tab.id, {selectedText: info.selectionText}, (response) ->

chrome.runtime.onMessage.addListener (message, sender, sendResponse) ->
    chrome.contextMenus.update menuItemId, {"enabled": message.selectedText?}
