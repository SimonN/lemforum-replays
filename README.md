Lix Proof Collection
====================

A collection of replays for singleplayer [Lix](https://github.com/SimonN/LixD)
levels to ensure solvability.

You can let Lix in noninteractive mode verify that all its levels have
at least one solving replay. This is useful because I (Simon N.) would like
to ship only solving levels with a Lix release.

Befitting open-source Lix, levels and solutions are open, too. In theory, you
could watch these replays in interactive Lix, spoiling the joy of solving the
puzzles on your own. :-)

How to use
----------

For **self-contained Lix**, i.e., not installed by package managers,
start from Lix's root directory to install and run the replay collection:

    cd replays
    git clone https://github.com/SimonN/lemforum-replays proofs
    cd ..
    bin/lix --coverage replays/proofs

For **Linux-packaged Lix**, your replay directory sits inside the
XDG-conformant application data directory. Do this instead:

    cd ~/.local/share/lix/replays
    git clone https://github.com/SimonN/lemforum-replays proofs
    lix --coverage proofs

Get Lix
-------

* [Homepage](http://www.lixgame.com)
* [Github repo](https://github.com/SimonN/LixD)
* [IRC webchat](http://webchat.quakenet.org/?channels=lix,neolemmix):
    #lix on QuakeNet
