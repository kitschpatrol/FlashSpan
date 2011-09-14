About
=====
FlashSpan is an open-source library for spanning Flash content across multiple screens.

FlashSpan relies on the fact that the code running on each computer should generate the exact same visuals over a certain number of frames. It works by keeping track of how many frames each client has rendered, and then closing any gaps in rendering speed.

The library’s written in ActionScript 3 and Java, and meant for development with Flex Builder 3 or similar code-oriented IDEs. The current incarnation wasn’t designed with the Flash CS3 authoring tool in mind, though future versions might add support. It’s all a bit rough, so consider this an alpha.

Some inspiration was draw from Daniel Shiffman’s epic Most Pixels Ever library for Processing, though the projects don’t share source code.

Source
=====
The code is divided into two core components: FlashSpanServer, a Java app responsible for keeping all of the screens in sync, and FlashSpanClient, an AS3 app built to handle the actual content and screen offsets.

History
=======
FlashSpan was initially developed for Newsworthy Chicago, an interactive installation at the Hyde Park Art Center.

FlashSpan emerged as a means of distributing the project’s live text content across an 80 foot, 10 projector video wall. Newsworthy was conceived of and designed by a group of graphic design graduate students at UIC: Sara Bassick, Renata Graw, Michael Ruberto, and Gretchen Schulfer. The code was written by Eric Mika.

License
=======
FlashSpan is licensed under the GNU Lesser General Public License.

Contact
=======
[Eric Mika](http://ericmika.com)