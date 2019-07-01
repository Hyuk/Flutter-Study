# Isolates and Event Loops

Hey, everybody. I'm Andrew from the Flutter team and welcom to the "flutter in Focus" miniseries on a asynchronous programming in Dart. 
This is the first in a run of videos covering the ways Dart, despite being a single-threaded langueage, offers support for futures, streams, backgroundwork, and all the other things you need to write in a modern, asynchronous, and, in the case of Flutter, reactive way. Since this is the first video in the series, I'm going to start all the way down at the founcation of what makes asynchrony possible with Dart, and that's the isolate. 

An isolate is what all Dart code runs in. It's like a little space on the machine with its own private chunk of memory and a single thread running an event loop. In a lot of other languages like C++, you could have multiple threads sharing the same memory and running whatever code they want. In Dart, though, each thread is in tis own isolate with its own memory and it just processes events. More on that in a minute. Many Dart apps run all their code in a single isolate, but you can have more than one if you need it. If you have a computation to perform that's so enormous it could casuse you to drop frames if it were run in the main isolate, you can use isolate.spawn() or Flutter's compute function, both of which create a separate isolate to do the number crunching, leaving your main one free to rebuild and render the widget tree in the meantime. 
```dart
Isolate.spawn(
    aFunctionToRun,
    {
        'data': 'Here is some data.'},
    }
);

compute(
    (params) {
        /* do something */
    },
    {'data': 'Here is some data.'},
);
```

That new isolate will get its own event loop and its own memory, which the original isolate, even though it's the parent of this new one, isn't allowed to access. That's the source of the name isolate. These little spaces are kept isolated from one another. In fact, the only way they can work together is by passing messages back and forth. One isolate will send a message to the other, and that receiving isolate process is the message using its event loop.

This lack of shared memory may sound kind of strict, especially if you're coming from a language like Java or C++, but it has some key benefits for Dart coders. For example, memory allocation and garbage collection in an isolate don't require locking. There's only one thread, so if it's not busy, you know the memory's not being mutated. That works out really well for Flutter apps, which sometimes need to build up and tear down a bunch of widgets really quickly. 

All right. So that's a basic introduction to isolates. Now let's dig into what really makes async code possible, the event loop. Imagine the life of an app stretched out on a timeline. here you start, there you stop, and in between, there are all these little events, like I/O from the disk, or finger taps from the user, all kinds of stuff. Your app can't predict when these events will happen or in what order, and it has to handle all of them with a single thread that never blocks, so it runs an event loop. Simple as can be. It grabs the oldest event from the event queue, processes it, goes back for the next one, processes that one, and so on until the event queue is empty. The whole time the app is running, you're tapping on the screen, things are downloading, a timer goes off, that event loop is just going around and around, processing those events one at a time. Whenever there's a break in the action, the tread just kind of hangs out, waiting for the next event. It can trigger the garbage collector, get some coffee, whatever. All of the high level APIs we're used to for asynchronous programming, futures, streams, async and await, they're all built on and around this simple loop.

For example, say you have a button that initiates a network request, like this one.
```dart
RaisedButton(
    child: Text('Click me'),
    onPressed: () {
        final myFuture = http.get('https://example.com');
        myFuture.then((response) {
            if(response.statusCode == 200) {
                print('Success!');
            }
        });
    },
)
```
You run your app and Flutter builds the button and puts it on screen, then it waits. 
The event loop just sort of idles, waiting for the next things to process. Other events not related to the button might come in and get handled while the button just sits there waiting for the user to tap on it. Eventually they do, and a tap event enters the queue. That event gets picked up for processing, Flutter looks at it, and the rendering system says, hey, those coordinates match the RaisedButton, so Flutter executes the onPressed function. That code initiates a network request, which returns a future and registers a completion handler for the future by using then. And that's it

The loop is finished processing that tap event and it's discarded. Now, onPressed was a property on Raised Button, and here we're talking about a callback for a future. But both of those techniques are doing basically the same thing. They're both a way to tell Flutter, hey, later on, you might see a particular type of event come in. When you do, please execute this piece of code. onPressed is waiting for a tap and the future is waiting for network data. But from Dart's perspective, those are both just events in the queue. And that's how a synchronous coding works in Dart. futures, streams, async, and await, these APIs are all just ways for you to tell Dart's event loop, here's some code. Please run it later. If we look back at the code example, you can now see exactly how it's broken up into blocks for particular events. There's the initial build, the tap event, and the network response event. Once you get used to working with async code, you'll start recognizing these partterns all over the place. And understanding the event loop is going to help as we move on to the higher lever APIs.

All right. So that's a quick look at isolates, the event loop, and the foundation of async coding in Dart. In our next video, we're going to talk about futures, a simple API you can use to take advantage of these capabilities without a ton of code. In the meantime, leave a comment below if you have a question, and come see us at flutter.io.
