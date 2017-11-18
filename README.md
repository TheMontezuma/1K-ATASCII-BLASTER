# 1K-ATASCII-BLASTER

A computer game for the ATARI home computers by [Frederik Holst](http://www.phobotron.de/1KAtasciiBlaster.html)

DataMatrix (and related code in the game) by [Piotr Fusik](https://github.com/pfusik/datamatrix6502)

[EN](https://github.com/TheMontezuma/1K-ATASCII-BLASTER/tree/master/EN) / [PL](https://github.com/TheMontezuma/1K-ATASCII-BLASTER/tree/master/PL) folders contain source code of the game (5 programming steps) with english / polish comments

### HSC

[HSC](https://github.com/TheMontezuma/1K-ATASCII-BLASTER/tree/master/HSC) folder contains source code and graphics for the [HI-SCORE](http://xxl.atari.pl/hsc/) compatible version of the game

Additionally to showing a HSC DataMatrix, the game sends a "URL submit" SIO command to the "Smart device":

* SIO DDEVIC: $45
* SIO DUNIT: $01
* COMMAND ID: $55
* COMMAND TYPE: SEND
* AUX1: Data Length (least significant byte)
* AUX2: Data Length (most significant byte)

Data length should be given in AUX1 and AUX2. Max length is 2000.
Data (URL) should be ASCII coded and must not include the end of line character ($9B).
The URL has to start with the protocol name like: *http://* or *https://*

For example:
>http://atari.pl/hsc/?x=106001230

The Smart Device will submit the given URL to the web browser application and there will be no feedback provided to the ATARI.
This command can be used for example to submit the Hi-Score information.

The Smart Device is supported by:

* [RespeQt](https://github.com/jzatarski/RespeQt/releases) (WIndows/Linux/Mac)
* [SIO2BT](https://play.google.com/store/apps/details?id=org.atari.montezuma.sio2bt) Android App
* [AspeQt](https://play.google.com/store/apps/details?id=org.qtproject.example.AspeQt&hl=de) Android App
