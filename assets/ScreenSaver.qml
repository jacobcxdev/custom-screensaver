/* @@@LICENSE
*
*      Copyright (c) 2013-2019 LG Electronics, Inc.
*
* Confidential computer software. Valid license from LG required for
* possession, use or copying. Consistent with FAR 12.211 and 12.212,
* Commercial Computer Software, Computer Software Documentation, and
* Technical Data for Commercial Items are licensed to the U.S. Government
* under vendor's standard commercial license.
*
* LICENSE@@@ */

import QtQuick 2.12
import QtQuick.Particles 2.0

Item {
    id: screensaver

    readonly property url particle_image: Qt.resolvedUrl("../Components/images/particle_img.png")

    property int particle_life: (liteMode === true)? 4000 : 5000
    property int particle_life_variation: 1000

    property bool playing: false
    property bool liteMode: false
    property bool isPartial: false
    property string guideString: ""
    property alias animationTimer: animation_timer
    property alias screenSaverText: screenSaverText.text

    signal looped()

    onPlayingChanged: {
        if (playing) {
            visible = true;

            red_emitter.pulse(1000)
            cyan_emitter.pulse(1000)
            blue_emitter.pulse(1000)
            fadeIn();
            animation_timer.start();
        } else {
            visible = false;
            animation_timer.stop();
        }
    }

    Timer {

        id: animation_timer

        interval: 7500
        onTriggered: {
            looped();
        }
    }


    ParticleSystem { id: sys }

    ImageParticle {

        id: blue_particle

        system: sys
        groups: ['blue']

        source: particle_image
        colorTable: Qt.resolvedUrl("../Components/images/blue.png")
        alphaVariation: 0.9
        entryEffect: ImageParticle.Fade
    }

    ImageParticle {

        id: cyan_particle

        system: sys
        groups: ['cyan']

        source: particle_image
        colorTable: Qt.resolvedUrl("../Components/images/Turquoise.png")
        alphaVariation: 0.9
        entryEffect: ImageParticle.Fade
    }

    ImageParticle {

        id: red_particle

        system: sys
        groups: ['red']

        source: particle_image
        colorTable: Qt.resolvedUrl("../Components/images/red.png")
        alphaVariation: 0.9
        entryEffect: ImageParticle.Fade
    }

    Emitter {

        id: blue_emitter

        system: sys
        group: 'blue'

        anchors.centerIn: parent
        enabled: false

        lifeSpan: particle_life
        lifeSpanVariation: particle_life_variation
        emitRate: 500
        maximumEmitted: 800

        size: 1
        velocity: AngleDirection{magnitude: 7; magnitudeVariation: 3; angleVariation: 360}
        acceleration: AngleDirection {magnitude: 12; magnitudeVariation: 5; angleVariation: 360}
    }

    Emitter {

        id: cyan_emitter

        system: sys
        group: 'cyan'

        anchors.centerIn: parent
        enabled: false

        lifeSpan: particle_life
        lifeSpanVariation: particle_life_variation
        emitRate: 500
        maximumEmitted: 800

        size: 1
        velocity: AngleDirection{magnitude: 7; magnitudeVariation: 3; angleVariation: 360}
        acceleration: AngleDirection {magnitude: 12; magnitudeVariation: 5; angleVariation: 360}
    }

    Emitter {

        id: red_emitter

        system: sys
        group: 'red'

        anchors.centerIn: parent
        enabled: false

        lifeSpan: particle_life
        lifeSpanVariation: particle_life_variation
        emitRate: 500
        maximumEmitted: 800

        size: 1
        velocity: AngleDirection{magnitude: 7; magnitudeVariation: 3; angleVariation: 360}
        acceleration: AngleDirection {magnitude: 12; magnitudeVariation: 5; angleVariation: 360}
    }

    Turbulence {
        anchors.fill: parent
        strength: 10
    }

    Text {

        id: screenSaverText

        width: parent.width
        height: font.pixelSize * 3
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        anchors.horizontalCenter: parent.horizontalCenter

        text: ""
        color: "#6e6e6e"
        style: Text.Outline
        styleColor: "black"
        wrapMode: Text.Wrap
        fontSizeMode: Text.Fit
        horizontalAlignment: Text.AlignHCenter
        font.family: fontManager.smart_Regular.family
        font.weight: fontManager.smart_Regular.weight
        font.pixelSize: 27 * (isPartial ? 0.8 : 1)

        NumberAnimation on opacity {

            id: fadeInAnimation

            from: 0.0
            to: 1.0
            running: false
            easing.type: Easing.OutQuad
            duration: 3500

            onStopped: {
                fadeOut();
            }
        }

        NumberAnimation on opacity {

            id: fadeOutAnimation

            from: 1.0
            to: 0.0
            running: false
            easing.type: Easing.OutQuad
            duration: 3500

            onStopped: {}
        }
    }

    function fadeIn () {
        fadeOutAnimation.stop();
        fadeInAnimation.restart();
    }

    function fadeOut () {
        fadeInAnimation.stop();
        fadeOutAnimation.restart();
    }
}
