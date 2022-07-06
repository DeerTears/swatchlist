# swatchlist
A tool to make, organize, and export palettes.

v0.1 right now, it's functional enough to get the idea across, but not fully functional in a way that is too useful yet.

## docs

See the [wiki](https://github.com/DeerTears/swatchlist/wiki/Basics) to learn how to use swatchlist.

## intent

swatchlist is a small app to let you play around with colours and save them for later use in multiple programs.

I wanted to make swatchlist for three main reasons:
1. I'm a graphic designer. I spend a good hour every week just inputting hex colours, most of that time spent precariously copying hex codes in small text fields with evil nearby text.
2. I'm tired of saving colour data with Adobe, Pantone, and other similar services. Colours should not be proprietary data.
3. I just wanted a little tool project to make for fun as a side project. ;)

## roadmap

This is all made in my spare time, but here's what I wanna do when I next work on this project.

Remove: click "delete mode" and click on swatch, rather than right clicking the swatch.

Move: Click and hold on swatch, it will automatically reposition itself along the list while the mouse is held down. Release to confirm current position. Show users their drop targets, let users increase swatch/target size.

Edit: Double click a swatch to open a colour dialog menu.

Shift: Click "shift mode" and select swatches. Then use buttons to adjust saturation, hue, and value of all colours at once.

Name colour: A name will show up as you hover over the colour.

List view: Colours display 1 by 1 vertically with optional names shown in full.

Android support: Shrink what UI is on screen to fit android comfortably, then create .apk downloadable from this site.

## Later features

Once I've got the above features mostly nailed down, I'll start looking at these features.

#### Import from other programs
You choose (or drop) a text file and determine if it's from GIMP, Paint.net, Asesprite, or something else. Load its colours as swatchlist swatches.

#### Export for other programs
Export: Write a palette file for GIMP, Paint.net, Asesprite, CSS, Photoshop, etc.

#### Subpalettes
Named groups of colours saved inside a single .swatchlist.

## not implementing

Stuff that I know won't work with Godot, or overbloats the program's small scope.

#### Screen-wide colour picking

This would require an external library in Python or something similar. Godot's OS access doesn't allow devs to look at the screen contents, so this is a bust unless there's a gdextension module for this. (if so, LMK!) It would be a better use of resources to recommend other companion programs to work alongside this one that already do colourpicking really well.

#### Image reference viewing

I really like how this works in a Notion or Coda environment, where you can link colours to images to give the colours context. But saving massive image collages really tests the limits of a hobbyist coder's ability to handle save data efficiently and safely. It would also introduce a whole new mode of using the program to orient and resize images. It could be done, but definitely as its own individual repo first. Godot doesn't seem like the best fit for something meant to scale up this big.

#### Transparent mode

Godot just doesn't allow it. :( Unless somebody manages to make a module for it.
