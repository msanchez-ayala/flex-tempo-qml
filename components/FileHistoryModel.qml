import QtQuick

ListModel {
    id: fileHistoryModel

    // keys are url and fileName

    // Set the given file URL to the top of the list. If
    // it's already in the model, then just move it to the
    // first element.
    function setCurrentFileUrl(fileUrl) {
        if (urlIsInModel(fileUrl)) {
            const idx = getIndexOfUrl(fileUrl)
            move(idx, 0)
        } else {
            insertNewUrl(fileUrl)
        }

    }

    // Return the current file URL or null if none
    // have been selected yet
    function getCurrentFileUrl() {
        return getUrlAtIndex(0)
    }

    // Insert a new URL into the model at the 0th index
    function insertNewUrl(fileUrl) {
        const fileName = urlToFileName(fileUrl)
        const entry = {url: fileUrl.toString(), fileName: fileName}
        console.log('entry filename', entry.fileName, entry.url)
        insert(0, entry)
        console.log(get(0).fileName)
    }

    // Return whether the given URL is already in the model
    function urlIsInModel(fileUrl) {
        return getIndexOfUrl(fileUrl) !== -1
    }

    // Return the URL at the given index
    function getUrlAtIndex(index) {
        return get(index).url
    }

    // Return the index of the given file URL if it exists
    // in the model. Else, return -1.
    function getIndexOfUrl(fileUrl) {
        var idx = -1
        for (let i = 0; i < count; i++) {
            if (getUrlAtIndex(i) === fileUrl) {
                idx = i
                break
            }
        }
        return idx
    }
}
