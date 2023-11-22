# custom-screensaver

- Probably the only custom screensaver you'll ever need on webOS TV.
- Requires root.

## Features

### App

* Auto-start registration
* Temporary application (until reboot)
* Run screensaver immediately (useful for testing)

### Tweak

* The default webOS screensaver has two distinct types: `normal`, and `advanced`.
  * `normal`: An explosion of pigments (like a firework), at a random position on the screen, with guide text (`Press any button…`) below. This has been customised to remove the guide text, and to add variation to the number of particles (it used to be 800, and is now from 100–2,000) in the explosion, and to account for this, the speed of the explosion (always 62.5% of the particle count).
  * `advanced`: An analogue clock with the date above or below, where the date fades to the current weather conditions (with some Accuweather text below), and then the whole thing fades to the guide text. This has been customised to remove the guide text completely, improve the date and weather conditions formatting, and to ensure the date and weather conditions always appear below the clock. The Accuweather text has also been customised (see below).
* Aside from the customisations listed above, the screensaver now alternates between `normal` and `advanced`, while it used to be one or the other (depending on whether you have your location set in Settings for weather information). It will show the clock, then three sequential varied fireworks, then repeat.

## Installation

There's an `.ipk` on the [GitHub releases page](https://github.com/jacobcxdev/custom-screensaver/releases), but the Accuweather replacement text is currently hard-coded to `Welcome to The Tower™` (I call my apartment 'The Tower™' lol). Feel free to fork and customise to your own liking…

## Acknowledgments

- According to WikiMedia Commons - DVD Video logotype does not meet the [threshold of originality](https://commons.wikimedia.org/wiki/Commons:Threshold_of_originality) needed for copyright protection, and is therefore in the public domain.
- Initially forked from [webosbrew/custom-screensaver](https://github.com/webosbrew/custom-screensaver).
