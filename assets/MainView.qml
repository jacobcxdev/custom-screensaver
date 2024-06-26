﻿/* @@@LICENSE
*
* Copyright (c) 2019 LG Electronics, Inc.
*
* Confidential computer software. Valid license from LG required for
* possession, use or copying. Consistent with FAR 12.211 and 12.212,
* Commercial Computer Software, Computer Software Documentation, and
* Technical Data for Commercial Items are licensed to the U.S. Government
* under vendor's standard commercial license.
*
* LICENSE@@@ */

import QtQuick 2.12
import "../"
import "../../AppInitializer"
import "../../Utilities/ScreenSaverUtils.js" as ScreenSaverUtils
import "../../Constants.js" as C

FocusScope {

    id: root

    readonly property int normalSize: 600
    readonly property int aplusSize: 320
    readonly property int atelierSize: 443

    property var appId
    property var serviceComponent
    property var punchThrough
    property GlobalStyle styleSheet
    property SystemProperties systemProperties
    property bool partial: false
    property bool checkCompleted: interfaces.weather.checkCompleted
    property bool isAdvancedScreenSaverReady: systemProperties ? systemProperties.isAdvancedScreenSaverReady : false
    property bool isWeather: interfaces.weather.isWeatherReady
    property bool hasTime: !timeManager.isFactoryTime && timeManager.broadcastUtcTime !== null
    property bool finalCondition: isAdvancedScreenSaverReady && isWeather && hasTime
    property string guideString: partial ? stringSheet.aPlus_487 : stringSheet.screensaver_2
    property bool guideCompleted: false
    property int normalCount: 0

    property alias screenSaver: loader.item
    property alias loader: loader
    property alias oledFullScreenSaverTimer: oledFullScreenSaverTimer

    objectName: "mainView"
    focus: true
    width: parent.width
    height: parent.height
    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter

    onCheckCompletedChanged: {
        printLog("[STATE] onCheckCompletedChanged, state: " + state
                 + ", checkCompleted: " + checkCompleted
                 + ", finalCondition: " + finalCondition
                 + ", isAdvancedScreenSaverReady: " + isAdvancedScreenSaverReady
                 + ", isWeather: " + isWeather
                 + ", hasTime: " + hasTime);
        if (state === C.MODE_FULL && checkCompleted) {
            if (isAvaialbeAdvancedScreenSaver()) {
                loader.setComp(advancedScreenSaver);
            } else {
                loader.setComp(normalScreenSaver);
            }
        }
    }

    onFinalConditionChanged: {
        printLog("[STATE] onFinalConditionChanged, state: " + state
                 + ", checkCompleted: " + checkCompleted
                 + ", finalCondition: " + finalCondition
                 + ", isAdvancedScreenSaverReady: " + isAdvancedScreenSaverReady
                 + ", isWeather: " + isWeather
                 + ", hasTime: " + hasTime);
        if (state === C.MODE_FULL && checkCompleted && !finalCondition) {
            loader.setComp(normalScreenSaver);
        }
    }

    Timer {

        id: inputLaunchTimer

        interval: 120000

        onTriggered: {
            if (rootWindow.active) {
                printLog("[STATE] inputLaunchTimer onTriggered " + root.state);
                interfaces.application.launchApp(systemProperties.lastInput, {"id":"storeDemoLaunch","storeDemoLaunch":"screenSaver"})
            }
        }
    }

    Timer {

        id: oledFullScreenSaverTimer

        running: ScreenSaverUtils.isRunningOledTimer(systemProperties.isOLEDScreen, root.state)

        interval: 30*60*1000 // 30 min

        onTriggered: {
            printLog("[STATE] oledFullScreenSaverTimer onTriggered " + root.state);
            root.state = C.MODE_FULL;
            pigViews.started = false;
        }
    }

    Timer {

        id: guideDelayTimer

        interval: 1000

        onTriggered: {
            if (!guideCompleted && loader.item && loader.item.visible && root.state === C.MODE_FULL) {
                if (loader.sourceComponent === normalScreenSaver || loader.sourceComponent === advancedScreenSaver) {
                    interfaces.audioguide.readText(stringSheet.screensaver_3 + " \n " + guideString, true);
                    guideCompleted = true;
                }
            }
        }
    }

    Rectangle {

        id: mainBackground

        anchors.fill: parent
        color: "black"
        visible: false
        enabled: false
    }

    Loader {

        id: loader

        property int restScreenSaverCount: 0
        property var previousComp

        focus: true

        onLoaded: {
            printLog("[UI] LOADED");
            item.playing = true;
        }

        Connections {
            target: loader.item ? loader.item : null
            onVisibleChanged: {
                if (!guideCompleted && loader.item && loader.item.visible && root.state === C.MODE_FULL) {
                    guideDelayTimer.restart();
                } else {
                    guideDelayTimer.stop();
                }
            }
        }

        function setComp (comp) {
            if (comp && !loader.sourceComponent) {
                previousComp = comp;
            } else if (comp && (loader.sourceComponent === normalScreenSaver || loader.sourceComponent === advancedScreenSaver)) {
                previousComp = loader.sourceComponent;
            } else if (comp === undefined) {
                previousComp = null;
            }

            loader.sourceComponent = comp;
        }

        function changeToPreviousComp () {
            if (previousComp === advancedScreenSaver && isAvaialbeAdvancedScreenSaver()) {
                setComp(advancedScreenSaver);
            } else {
                setComp(normalScreenSaver);
            }
        }

        function reload() {
            active = false;
            if (root.normalCount === 3) {
                setComp(advancedScreenSaver);
                root.normalCount = 0;
            } else {
                setComp(normalScreenSaver);
                root.normalCount++;
            }
            active = true;
        }
    }

    Repeater {

        id: pigViews

        property bool started: false
        property bool hasValidPig: false

        objectName: "pigViews"
        visible: false
        model: started && systemProperties.foregroundApps ? systemProperties.foregroundApps.length : 0
        delegate: PigView {

            id: pigView

            appId: root.appId
            serviceComponent: root.serviceComponent
            punchThrough: root.punchThrough
            styleSheet: root.styleSheet
            systemProperties: root.systemProperties
            videoAppId: systemProperties.foregroundApps && systemProperties.foregroundApps[index] ? systemProperties.foregroundApps[index].appId : ""

            onStateChanged: {
                if (state !== C.PIG_STATE_NONE) {
                    checkHasPig();
                    printLog(`[PIG] appId: ${videoAppId}, state: ${state}`);
                }
            }

            function checkHasPig () {
                let hasPig = false;
                for (let i = 0; i < pigViews.count; i++) {
                    let item = pigViews.itemAt(i);
                    if (item) {
                        if (item.state === C.PIG_STATE_NONE) {
                            return;
                        }
                        if (item.state === C.PIG_STATE_SHOW) {
                            hasPig = true;
                        }
                    }
                }

                pigViews.hasValidPig = hasPig;
                pigViews.hasValidPigChanged();
            }
        }

        onHasValidPigChanged: {
            root.setScreenSaverState();
        }
    }

    Component {

        id: normalScreenSaver

        ScreenSaver {

            objectName: "normalScreenSaver"

            width: getScreenSaverWidth()
            height: getScreenSaverHeight()

            x: Math.random() * (root.width - width)
            y: Math.random() * ((root.partial ? getScreenSaverHeight() : root.height) - height)

            liteMode: (root.width === 1280)
            playing: false
            visible: false
            isPartial: root.partial
            guideString: root.guideString
            onLooped: {
                loader.reload();
            }
        }
    }

    Component {

        id: advancedScreenSaver

        Clock {

            objectName: "advancedScreenSaver"

            width: 1920
            height: 1080

            x: (root.width - width)/2
            y: (root.height - height)/2

            visible: false
            playing: false
            isPartial: root.partial
            guideString: root.guideString
            onLooped: {
                loader.reload();
            }
        }
    }

    onStateChanged: {
        printLog("[STATE] onStateChanged: " + state);
        resetGuide();
        switch(state) {
        case C.MODE_FULL:
            pigViews.visible = false;
            enableBackground();
            checkAdvancedScreenSaver();
            break;
        case C.MODE_PIG:
            pigViews.visible = true;
            enableBackground();
            loader.setComp();
            break;
        case C.MODE_NONE:
            pigViews.visible = false;
            enableBackground();
            loader.setComp();
            break;
        }
    }

    states: [
        State {
            name: C.MODE_NONE
        },
        State {
            name: C.MODE_FULL // full screensaver
        },
        State {
            name: C.MODE_PIG
        }
    ]

    function initialize () {
        //Check for rollableTV
        if (systemProperties.isRollable) {
            interfaces.application.getViewState(function(response) {
                root.partial = ScreenSaverUtils.getPartial(response);
                start();
            });
        } else {
            start();
        }
    }

    function start () {
        if (root.partial) {
            setScreenSaverState();
        } else {
            pigViews.started = true;
            if (!systemProperties.foregroundApps || systemProperties.foregroundApps.length <= 0) {
                setScreenSaverState();
            }
        }

        if (ScreenSaverUtils.needStoreInputLaunch(systemProperties.isStoreMode, root.partial, systemProperties.isForegroundFirstUse)) {
            inputLaunchTimer.start();
        }
    }

    function setScreenSaverState () {
        if (root.partial) {
            state = C.MODE_FULL;
            printLog("[STATE] partial");
            return;
        }

        if (!systemProperties.foregroundApps || systemProperties.foregroundApps.length <= 0) {
            printLog("[PIG] no foregroundApps");
            state = C.MODE_FULL;
            return;
        }

        if (pigViews.hasValidPig) {
            state = C.MODE_PIG;
        } else {
            state = C.MODE_FULL;
        }
    }

    function checkAdvancedScreenSaver () {
        interfaces.weather.getLocationInfoByPreference();
        timeManager.startToUpdateBroadcastTime();
    }

    function getRelativeWidth (width) {
        let ratio = root.width / 1920;
        return Math.round(width * ratio);
    }

    function getRelativeHeight (height) {
        let ratio = root.height / 1080;
        return Math.round(height * ratio);
    }

    function getScreenSaverWidth () {
        if (root.partial && systemProperties.isAplus) {
            return aplusSize;
        } else if (root.partial && systemProperties.isAtelier) {
            return atelierSize;
        } else {
            return getRelativeWidth(normalSize);
        }
    }

    function getScreenSaverHeight () {
        if (root.partial && systemProperties.isAplus) {
            return aplusSize;
        } else if (root.partial && systemProperties.isAtelier) {
            return atelierSize;
        } else {
            return getRelativeHeight(normalSize);
        }
    }

    function resetGuide () {
        guideDelayTimer.stop();
        guideCompleted = false;
    }

    function isAvaialbeAdvancedScreenSaver () {
        return finalCondition && checkCompleted && !partial;
    }

    function enableBackground () {
        mainBackground.visible = true;
        rootWindow.color = "black";
    }
}
