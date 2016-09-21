module imagine.transform;

import std.algorithm;
import std.array;
import std.conv;
import std.experimental.ndslice;
import std.range;
import std.traits;
import std.string;

import dcv.core;
import dcv.imgproc;
import imagine.util;

auto binarize(Image i) {
    return i.sliced.theshold!ubyte(127);
}