module imagine.transform;

import std.algorithm;
import std.array;
import std.conv;
import std.range;
import std.random;
import std.math;
import std.string;
import std.stdio;

import dcv.core;
import dcv.imgproc;
import imagine.util;

auto improve(Image img, float sensitivity) {
    auto slice = img.sliced;
    auto lowlights = slice.slice;
    for (int i = 0; i < img.channels; i++) {
        auto sl = slice[0..$, 0..$, i];
        auto avg = min(255, sl.byElement.reduce!"a+b"/sl.elementsCount*sensitivity);
        auto slMask = sl.threshold!ubyte((avg).to!ubyte);

        sl[] &= slMask;
    }

    for (int i = 0; i < img.channels; i++) {
        auto low = lowlights[0..$, 0..$, i];
        auto sl = slice[0..$, 0..$, i];
        auto avg = min(255, sl.byElement.reduce!"a+b"/sl.elementsCount*sensitivity);
        auto slMask = low.threshold!ubyte(0, (avg).to!ubyte);

        low[] &= slMask;
        auto elem = low.byElement.retro;
        bringToFront(elem[0 .. $-avg.to!ubyte], elem[$-avg.to!ubyte .. $]);
        low[] = elem.retro.array.sliced(img.height, img.width);
    }
    
    slice[] += lowlights;
    return slice.asImage(img.format);
}

auto adjust(Image img, float intensity) {
    auto random = (img.width*img.height).iota.map!(a => uniform(0, 2).to!float);
    auto wmap = roundRobin(random, random).array.sliced(img.height, img.width, 2);

    return img.sliced.warp(wmap).asImage(img.format);
}
