Against all odds, a very useful usability pattern emerged from the constraints of the physical world around the time when written language was just taking shape: the page. Its size and form have changed throughout history to arrive at common formats that that we'd recognize today. For example, US Letter measuring 8.5" x 11" for office printing, or 4.25" x 6.75" for a mass market paperback.

It's survived all the way to the present day in our printed mediums as an easily portable unit of text, but it also provides major usability benefits as well. The edges of a page provide convenient points of reference so that readers can easily track their position within a larger document, and often the width of pages are optimized to fit in an eminently readable 50 to 60 characters per line (although too wide for modern uses, even the 8.5" x 11" US Letter was well-suited in this respect back in the day of the typewriter).

The page is also quite beautiful. Print designers have been assembling stunning products for decades that demonstrate emminently fluid layouts and a creative use of space that has yet to be matched in digital design (in my opinion). For example, here's are a few pages from the [recent redesign of Transworld Surf](https://www.behance.net/gallery/Transworld-Surf-Redesign/13052023) and the [Italian magazine IL](http://www.behance.net/gallery/RANE/4282199):

[![Transworld Surf](/assets/death-of-the-page/transworld-surf.jpg)](https://www.behance.net/gallery/Transworld-Surf-Redesign/13052023)
[![RANE from IL](/assets/death-of-the-page/rane.jpg)](http://www.behance.net/gallery/RANE/4282199)

With the rise of the computer pages were adopted into the digital world, albeit in a slightly altered format. Unsurprisingly, the page construct was present in applications like Word and PostScript to build products that would end up on physical paper, but the page also provided a convenient metaphor for the amount of content that could be displayed on a monitor. Page up and down keys appeared to allow users to jump up and down by an entire screen of content. Paging remains the standard navigational paradigm to this day in programs like Vim to allow users efficient access to view and edit their data.

## Scan & Scroll, Hypertext, and Tablets

As the mouse became more widespread and the computer became more established as its own medium and started to relinquish its analogs with the real world, the page lost its dominance and was replaced by today's more common practice of scanning content while simultaneously scrolling a document incrementally. While effective in its own right, this scan and scroll technique is marginally more difficult to read when compared to a page as the text becomes a moving target shifting up or down the screen as the eye tries to keep pace.

As the web browser emerged, the page's convenient constraint on width that helped bound line length was also temporarily lost as browsers defaulted to expanding text occupy as much screen real estate as you were willing to give it. Modern designers account for this, but HTML's poor defaults continue to produce documents with reduced legibility all over the web.

Despite being relegated to the realm of power users, paging up and down remained quite effective until very recently for anyone inclined to use it, but the more recent rise of JavaScript is finally starting to take its toll on this old usability feature. For example, anchored headers are a common sight these days, and they seem innocent enough until you realize that exactly one "header height" worth of content is lost to the reader every time they page up or down, making paging very ineffective.

![Anchored Header](/assets/death-of-the-page/fp.png)

The more recent development of tablets has also send pages spiraling toward obsolescence as they're not a native concept in platforms like Android and iOS. In the world of touch-screen portables, not even apps renowned as champions of easy content consumption like Reeder and Readability provide paging mechanisms, leaving slow page scrolling the only available option.

## An Unlikely Champion

A recent unlikely re-emergence of the page is on iOS' Newsstand app, a surprising development for a company that tends to favor aesthetic over usability (see Spaces, iOS 7). I can say from first-hand experience that reading dead tree publications like the Economist on an iPad is a hugely gratifying experience; it comes with the eminent readability of the page and all the powerful features of a digital format, but none of the mess that comes with paper.

![Economist on iPad](/assets/death-of-the-page/economist.jpg)

## Slowing the Fall

Barring an explosion in popularity of digital magazines through apps like Newsstand, there's a good chance that the page in its traditional form is dead (in the digital world at least). Some of its inherited usability features like constrained width may carry on forever, but its precisely fixed proportions are likely gone for good.

There are however certain steps that we can take to slow its downfall and preserve its presence where we already have it today. Foremost among these is to take pagination into consideration when building out rich web applications, and avoiding common JavaScript-based pitfalls:

1. Anchoring elements that obscure vertical space (see the fixed header screenshot above). These break the browser's ability to judge how far to scroll up or down when paging.
2. Improperly capturing key events that are commonly used for paging like `Page Up`, `Page Down`, and `Space`.

Tablets.
