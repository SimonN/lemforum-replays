#!/usr/bin/rdmd

module windowsHabitsToLix;

/*
 * Windows Habits To Lix -- rename multiplayer level files to only [a-z1-9]
 * and sort them into the correct directories.
 *
 * Usage example: Assume "My Cool Level (3p).txt" is a Lix level. According to
 * its content, it's a 3-player level by CoolAuthor. Then:
 *
 * windows-habits-to-lix.d "My Cool Level (3p).txt"
 *  -> converts CRLF terminators to LF terminators
 *  -> renames to "mycoollevel3p.txt"
 *  -> creates directory "coolauthor/3p/"
 *  -> moves the file into that directory.
 */

import std.algorithm;
import std.conv;
import std.stdio;
import std.file;
import std.string;

void main(string[] args)
{
    if (args.length < 2) {
        writeln("windows-habits-to-lix: no input files");
    }
    foreach (arg; args[1 .. $])
        doOneFile(arg);
}

struct Content {
    int numPlayers;
    string author; // whitespace-stripped, otherwise unmodified from level
}

void doOneFile(string fn)
{
    try {
        auto f = File(fn, "r");
        Content content = readContent(f);
        moveFile(fn, content);
    }
    catch (Exception e) {
        writefln("Error for `%s': %s", fn, e.msg);
    }
}

Content readContent(File f)
{
    Content ret;
    foreach (line; f.byLine) {
        enum string keyAuthor = "$AUTHOR";
        enum string keyNumPlayers = "#INTENDED_NUMBER_OF_PLAYERS";
        if (line.startsWith(keyAuthor))
            ret.author = line[keyAuthor.length .. $].strip().idup;
        else if (line.startsWith(keyNumPlayers))
            ret.numPlayers = line[keyNumPlayers.length .. $].strip().to!int;
    }

    if (ret.author == "")
        throw new Exception("No author.");
    else if (ret.numPlayers == 0)
        throw new Exception("No player count.");
    return ret;
}

string goodFilename(string bad)
{
    import std.path;
    bool addExtension = bad.endsWith(".txt");
    string good = bad
        .baseName
        .toLower
        .filter!((dchar c) => c >= 'a' && c <= 'z'
                           || c >= '0' && c <= '9')
        .to!string;
    if (addExtension) {
        assert (good.endsWith("txt"));
        assert (! good.endsWith(".txt"));
        return good[0 .. $-3] ~ ".txt";
    }
    else
        return good;
}

void moveFile(in string fn, in Content c)
{
    string dir = format!"./%s/%dp/"(c.author.goodFilename, c.numPlayers);
    mkdirRecurse(dir);

    string outFn = dir ~ goodFilename(fn);
    File inFile = File(fn, "r");
    File outFile = File(outFn, "wb");
    foreach (line; inFile.byLine)
        outFile.write(line.strip(), "\n");
    std.file.remove(fn);
    writefln("%s -> %s", fn, outFn);
}
