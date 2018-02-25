#!/usr/bin/rdmd

/*
 * relocate-replays
 *
 * This is a D script. To run it, you must have rdmd installed (ships with
 * dmd). Allow this script to execute (chmod +x relocate-replays) and run
 * it without arguments to see purpose & usage.
 *
 * Assumes a Unix-like environment with sed installed.
 */

module relocateReplays;

import std.algorithm;
import std.file;
import std.process;
import std.range;
import std.stdio;
import std.string;

immutable string[] usage = [
    "Within all replays in a given directory, examine the pointed-to level",
    "filename: Consider its directory incorrect, but its dir-less filename",
    "correct. We find a level with that dir-less filename in levels/, then",
    "change the replay in place to point to the found filename.",
    "If more than one level matches, we'll pick one at random, no warning!",
    "",
    "Usage: Be in Lix's root directory, then run:",
    "    replays/proofs/relocate-replays.d dirWithReplays",
];

void main(string[] args)
{
    if (args.length <= 1)
        usage.each!writeln;
    else
        foreach (dir; args[1 .. $])
            workOnReplayDir(dir);
}

void workOnReplayDir(string rpDir)
{
    executeShell("bin/lix --coverage " ~ rpDir)
        .output.splitter("\n")
        .filter!(line => line.startsWith("(NO-LEV)"))
        .map!parseNoLevLine
        .each!changeReplayInPlace;
}

struct NoLevLine
{
    string replay;
    string oldLevelFull;
    string oldLevelFile;
}

NoLevLine parseNoLevLine(string line) pure
{
    NoLevLine ret;
    auto fields = line.splitter(",");
    fields.save.drop(1).takeOne.each!(s => ret.replay = s);
    fields.save.drop(2).takeOne.each!(s => ret.oldLevelFull = s);
    ret.oldLevelFile = ret.oldLevelFull;
    while (ret.oldLevelFile.findSkip("/"))
        {}
    return ret;
}

enum levelDir = "./levels/";

string cutOffLevelDir(in string path) pure
{
    foreach (x; 0 .. 3)
        if (path.startsWith(levelDir[x .. $]))
            return path[(levelDir.length - x) .. $];
    return path;
}

void changeReplayInPlace(in NoLevLine nll)
{
    dirEntries(levelDir, nll.oldLevelFile, SpanMode.depth)
        .takeOne
        .each!((foundLevel) {
            immutable command = "sed -i 's:%s:%s:' '%s'".format(
                nll.oldLevelFull.cutOffLevelDir, // change this string...
                foundLevel.cutOffLevelDir, // ...to this string...
                nll.replay // in this file.
            );
            executeShell(command);
            writeln("Changed: ", nll.oldLevelFull.cutOffLevelDir, " -> ",
                foundLevel.cutOffLevelDir);
        });
}
