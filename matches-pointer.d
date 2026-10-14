#!/usr/bin/rdmd

module matchesReplay;

import std.algorithm;
import std.file;
import std.process;
import std.range;
import std.stdio;
import std.string;

immutable string[] usage = [
    "Error: No input files.",
    "",
    "For each replay file given as argument, this script does:",
    "Look at the replay's basename.",
    "Look at the pointed-to level's basename excluding the level's extension,",
    "Happy case: replayBase starts with (levelBase ~ '-'). Print nothing.",
    "Bad case: replayBase doesn't start like that.",
    "On warning, you should manually rename the replay to satisfy Rep4Lev.",
];

void main(string[] args)
{
    if (args.length <= 1) {
        usage.each!writeln;
        return;
    }
    foreach (repFn; args[1 .. $]) {
        try {
            doOneFile(repFn);
        }
        catch (std.stdio.StdioException e) {
            if (e.msg == "Is a directory") {
                continue;
            }
            throw e;
        }
    }
}

void doOneFile(in string repFn)
{
    immutable repBase = repFn.basenameOf;
    immutable levBase = repFn.pointedLevel;
    if (levBase.empty) {
        writeln(repFn, ": Doesn't point to anything");
        return;
    }
    immutable whatRep4LevFinds = levBase.noExt ~ '-';
    if (repBase.startsWith(whatRep4LevFinds)) {
        return; // The happy case.
    }
    writeln(repFn);
    writeln(" -> ", levBase,
        ". Rename ", repBase.upToIncludingFirstHyphen,
        " to ", whatRep4LevFinds);
}

string basenameOf(in string src)
{
    immutable slash = src.indexOf('/');
    return slash == -1 ? src : src[slash + 1 .. $].basenameOf;
}

string upToIncludingFirstHyphen(in string src)
{
    immutable bn = basenameOf(src);
    immutable hyphen = bn.indexOf('-');
    return hyphen == -1 ? bn : bn[0 .. hyphen + 1];
}

string noExt(in string src)
{
    immutable dot = src.lastIndexOf('.');
    return dot == -1 ? src : src[0 .. dot];
}

string pointedLevel(in string repFn)
{
    auto f = File(repFn); // Open for reading
    auto range = f.byLine()
        .filter!(line => line.startsWith("$FILENAME "))
        .takeOne;
    if (range.empty) {
        return "";
    }
    auto withoutFILENAME = range[0]["$FILENAME ".length .. $];
    auto trimmed = withoutFILENAME.strip;
    return trimmed.idup.basenameOf;
}
