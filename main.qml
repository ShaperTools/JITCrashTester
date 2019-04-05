import QtQuick 2.12
import QtQuick.Window 2.12

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")

    property var shortFunctionItemObject: null
    property var shortFunctionItemInstance: null

    function callLongFunction() {
        // This is implementedcall in a way that the JITted code can then be released
        var longFunctionItemObject = Qt.createComponent("LongFunctionItem.qml")
        var longFunctionItemInstance = longFunctionItemObject.createObject()
        for(var i = 0; i < 10; i++) { longFunctionItemInstance.longFunction() }
        // I must explicitly clear the cache or it will just refer to the same one, and not create many copies
        quickUtil.clearComponentCache()
    }

    function callShortFunction() {
        // This keeps around a permanent copy
        if(!shortFunctionItemObject) {
            shortFunctionItemObject = Qt.createComponent("ShortFunctionItem.qml")
            shortFunctionItemInstance = shortFunctionItemObject.createObject()
        }
        for(var i = 0; i < 10; i++) { shortFunctionItemInstance.shortFunction() }
    }

    Timer {
        // This is implemented as a timer because for some reason unless a function *returns*, I can't get it to release the JITted
        // executable memory allocations associated with local variables. I'm not sure why and I didn't bother to investigate.
        property int loopCount: 0
        interval: 100
        running: true
        repeat: true
        onTriggered: {
            var i
            var j

            console.log("Triggered " + loopCount)
            if(loopCount == 0) {
                callLongFunction()
                callShortFunction()
            }
            else if(loopCount == 1) {
                callLongFunction()
                callShortFunction()
            }

            // Run the garbage collector to make sure stuff gets freed.
            gc()
            loopCount++
            console.log("Done")
        }
    }
}
