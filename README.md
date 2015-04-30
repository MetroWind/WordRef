# WordRef

![Screenshot](https://github.com/Corsair/WordRef/raw/master/screenshot.png)

A Mac program to import BibTeX files into Micro$oft Word’s citation manager.

## About the citation management on Word

So, you are a scientific person who wants to write a paper, but not
*so* scientific to use LaTeX.  You look at all those citation manager
choices like Papers, Mendaley, EndNote, etc., and realize that only
EndNote *sort of* integrate with Word.  But you don’t want EndNote,
because it’s ugly, heavy, not native on Mac, and expensive, and worst
of all, doesn’t support exporting to/importing from BibTeX.  You raise
your head and look at the calendar—it’s 2015 now, and there’s a
citation manager (I mean besides Word of course) that doesn’t support
BibTeX.

## This program, and how to use it

So, what choices do you have? You are about to google for a bunch of
tutorials and start to learn LaTeX.  And suddenly you realize that
wait a minute, Word’s citation manager uses a XML to store all the
information, and a BibTeX file is just plain text.  What stops you
from using a program to convert a BibTeX to XML?  Exactly nothing!
Especially when this program opens the correct XML for you when you
run it, and you can just drag a BibTeX file onto it, click save, and
start doing your thing in Word.

## Limitations

For now this program supports only the “journal article” type of
entries (because I don’t have a sample of BibTeX and Word XML to know
how to convert other types).  The following attributes are mandatory
for each entry in order to be converted:

  - Author(s)
  - Title
  - Tag
