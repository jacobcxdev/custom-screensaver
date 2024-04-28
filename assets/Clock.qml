/* @@@LICENSE
*
*      Copyright (c) 2019 LG Electronics, Inc.
*
* Confidential computer software. Valid license from LG required for
* possession, use or copying. Consistent with FAR 12.211 and 12.212,
* Commercial Computer Software, Computer Software Documentation, and
* Technical Data for Commercial Items are licensed to the U.S. Government
* under vendor's standard commercial license.
*
* LICENSE@@@ */

import QtQuick 2.12
import "../Components"

Item {

    id : root

    readonly property int displayDurationTime: 5000
    readonly property int mainFadeInOutTime: 3000
    readonly property int guideTextFadeInTime: 3000
    readonly property int infoFadeInOutTime: 500

    property int hours
    property int minutes
    property int seconds
    property string currentTime;
    property real shift
    property bool isPartial: false
    property string guideString: ""
    property bool playing: false
    property bool timeUpdated: false
    property var displayInfo:["time", "weather", "warningText"]
    property bool dataReady: playing && isWeather && root.timeUpdated
    property alias animation: anim

    signal looped()

    onDataReadyChanged: {
        if (dataReady) {
            visible = true;
            anim.start();
        } else {
            visible = false;
        }
    }

    SequentialAnimation {

        id: anim

        PropertyAnimation {
            target: mask
            properties: "opacity"
            from: 1
            to: 0
            duration: mainFadeInOutTime
        }

        PauseAnimation {
            duration: displayDurationTime
        }

        PropertyAnimation {
            target: dateTextArea
            properties: "opacity"
            from: 1
            to: 0
            duration: infoFadeInOutTime
        }

        PropertyAnimation {
            target: weatherArea
            properties: "opacity"
            from: 0
            to: 1
            duration: infoFadeInOutTime
        }

        PauseAnimation {
            duration: displayDurationTime
        }

        PropertyAnimation {
            target: mask
            properties: "opacity"
            from: 0
            to: 1
            duration: mainFadeInOutTime
        }

        onRunningChanged: {
            if (!running) {
                looped();
            }
        }
    }

    Item {

        id: clockMain

        width: parent.width
        height: childrenRect.height
        anchors.centerIn: parent

        Item {

            id: clockShape

            anchors.top: parent.top
            anchors.bottom: undefined
            anchors.horizontalCenter: parent.horizontalCenter

            width: 420
            height: 420

            Image {
                id: second

                anchors.centerIn: parent
                source: "../Components/images/2k/screensaver_clock_bg.png"
                antialiasing: true
                smooth: true

                RotationAnimation on rotation {
                    from: 0;
                    to: 360;
                    running: true
                    loops: Animation.Infinite
                    direction: RotationAnimation.Clockwise
                    duration: 3000
                }
            }

            Image {

                id: hourShape

                property real hourAngle: (root.hours + root.minutes / 60) * 30

                Behavior on hourAngle {

                    enabled: timeUpdated

                    RotationAnimation { direction: RotationAnimation.Clockwise; duration: 100 }
                }

                anchors.centerIn: parent
                source: "../Components/images/2k/screensaver_clock_arm_hour.png"
                transformOrigin: Item.Center
                rotation: hourAngle
                antialiasing: true
                smooth: true
            }

            Image {

                id: minuteShape

                property real minuteAngle: (root.minutes + root.seconds / 60) * 6

                Behavior on minuteAngle {

                    enabled: timeUpdated

                    RotationAnimation { direction: RotationAnimation.Clockwise; duration: 100 }
                }

                anchors.centerIn: parent
                source: "../Components/images/2k/screensaver_clock_arm_min.png"
                transformOrigin: Item.Center
                rotation: minuteAngle
                antialiasing: true
                smooth: true
            }
        }

        Item {

            id: dateArea

            width: parent.width - 132
            height: 40
            anchors.top: clockShape.bottom
            anchors.topMargin: 100
            anchors.bottom: undefined
            anchors.bottomMargin: 0
            anchors.horizontalCenter: parent.horizontalCenter

            Text {

                id: dateTextArea

                anchors.centerIn: parent
                text: currentTime
                color: "#808080"
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                font.family:  fontManager.smart_Regular.family
                font.weight: fontManager.smart_Regular.weight
                font.pixelSize: 33 * (isPartial ? 0.8 : 1)
            }
        }

        Item {

            id: weatherArea

            width: parent.width - 132
            height: 86
            anchors.top: clockShape.bottom
            anchors.topMargin: 100
            anchors.bottom: undefined
            anchors.bottomMargin: 0
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: 0

            Image {

                id: weatherIconImage

                width: 70
                height: 70
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: weatherText.left
                anchors.rightMargin: 15
                source: interfaces.weather.weatherImage
                antialiasing: true
                smooth: true
            }

            Text {

                id: weatherText

                width: contentWidth
                height: font.pixelSize + 10
                anchors.centerIn: parent

                visible: true
                color: "#808080"
                text: toTitleCase(interfaces.weather.weatherText) + " | " + interfaces.weather.getTemperature() + "˚"
                font.family: fontManager.smart_Regular.family
                font.weight: fontManager.smart_Regular.weight
                font.pixelSize: 33
            }

            Text {

                id: weatherTailText

                width: contentWidth
                height: font.pixelSize + 10
                anchors.left: weatherText.right
                anchors.leftMargin: -5
                anchors.bottom: weatherText.bottom

                visible: true
                color: "#808080"
                text: interfaces.weather.temperatureUnit
                font.family: fontManager.smart_Regular.family
                font.weight: fontManager.smart_Regular.weight
                font.pixelSize: 33
            }

            Text {

                id: accuweatherText

                width: contentWidth
                height: font.pixelSize + 10
                anchors.top: weatherText.bottom
                anchors.topMargin: 12
                anchors.horizontalCenter: parent.horizontalCenter

                visible: true
                color: "#808080"
                text: String("Welcome to The Tower")
                font.family: fontManager.smart_SemiBold.family
                font.weight: fontManager.smart_SemiBold.weight
                font.pixelSize: 16
            }
        }
    }

    Rectangle {

        id: mask
        anchors.fill: parent
        color: "black"
    }

    Timer {

        id: weatherRefreshTimer

        interval: 1000 * 60 * 30    // 30 min
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            interfaces.weather.getCurrentWeather();
        }
    }

    Component.onCompleted: {
        updateTime();
        timeManager.currentTimeUpdated.connect(updateTime);
        weatherRefreshTimer.restart();
    }

    Component.onDestruction: {
        timeManager.currentTimeUpdated.disconnect(updateTime);
        weatherRefreshTimer.stop();
    }

    function updateTime () {

        if (!timeManager.isFactoryTime && timeManager.broadcastUtcTime) {
            // dateType: "date" or "time"
            // formatType: 1) Date: "d" /  "dm" / "dmw" / "dmwy"   2) Time: "a" / "ah" / "ahm" / "ahms"
            // formatLength: "short" / "medium" / "long" / "full"

            if (!timeManager.isFactoryTime && timeManager.broadcastUtcTime) {
                currentTime = timeManager.dateTimeFormat(timeManager.broadcastUtcTime, "date", "dmy", "full");
                
                // Extract the day number
                var day = parseInt(currentTime.split(' ')[0]);

                // Replace the day number with the ordinal version
                currentTime = currentTime.replace(day.toString(), ordinalSuffix(day));
            } else {
                currentTime = ""
            }

            hours = timeManager.broadcastUtcTime.getUTCHours() % 12;
            minutes = timeManager.broadcastUtcTime.getUTCMinutes() % 60;
            seconds = timeManager.broadcastUtcTime.getUTCSeconds() % 60;
        }

        timeUpdated = true;
    }

    function ordinalSuffix(day) {
        var lastDigit = day % 10;
        var suffix = "th";  // Default suffix

        if (lastDigit === 1 && day !== 11) {
            suffix = "st";
        } else if (lastDigit === 2 && day !== 12) {
            suffix = "nd";
        } else if (lastDigit === 3 && day !== 13) {
            suffix = "rd";
        }

        return day + suffix;
    }

    function toTitleCase(str) {
        return str.replace(/\w\S*/g, function(txt) {
            return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();
        });
    }
}
