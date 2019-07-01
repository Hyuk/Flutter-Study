# Streams

Hey, everybody, and welcome to the third video in our "Flutter in Focus" series on asynchronous coding patterns in Dart. In this episode, I'm going to cover one of the fundamentals of reactive programming, streams. If you saw our previous video on futures, you may remember that each future represents a single value, either an error or data that it delivers asynchronously. Streams work similarly, only instead of a single thing, they can deliver zero or more values and errors over time. 
|Sync: |int |Iterator<int>|
|ASync: |Future<int> |Stream<int>|
If you think about the way a single value relates to an iterator of the same type, that's how a future relates to a stream. Just like with futures, the key is deciding in advance here's what to do when a piece of data is ready, when there's an error, and when the stream completes. And the Dart event loop is still running the show.

If you're using files.openRead method to read data from a file, for example, it returns a stream. Chunks of data are read from disk and arrive at the event loop. Dart:io looks at them and says "Ah, I've got somebody waiting for this," adds the data to the stream, and it pops out in your app's code. When another peice of data arrives, in it goes and out it comes. Timer-based streams, streaming data from a network socket, they work with the event loop too using clock and network events. 

Okay, let's talk about how to work with data provided by a stream.
```dart
final myStream = NumberCreator().stream;
```
Say I have a class that will give me a stream that kicks out a new integer once per second, one, two , three, four, five.
I can use the listen method to subscribe to the stream.
```dart
final subscription = myStream.listen(
    (data) => print('Data: $data'),
);
```
I give it a function, and every time a new value is emitted by the stream, my function gets called and prints it. That's how listen works. 
```dart
final subscription = myStream.listen(
    (data) => print('Data: $data'),
);
final subscription2 = myStream.listen(
    (data) => print('Data again: $data'),
);
```
One important thing to note is that, by default, streams are set up for single subscription. They hold onto their values until someone subscribes, and they only allow a single listener for their entire lifespan. If you try to listen to one twice, you'll get an exception.

Fortunately, Dart also offers broadcast streams.
```dart
final myStream = NumberCreator()
    .stream
    asBroadcastStream;

final subscription = myStream.listen(
    (data) => print('Data: $data'),
);

final subscription2 = myStream.listen(
    (data) => print('Data again: $data'),
);
```
You can use the asBroadcastStream method to make a broadcast stream from a single subscription one. They work the same as single subscription streams, but they can have multiple listeners. And if nobody's listening when a piece of data is ready, it gets tossed out. 
```dart
final myStream = NumberCreator().stream;

final subscription = myStream.listen(
    (data) => print('Data: $data'),
);
```
Let's go back to that first listen call though because there are a couple more things to talk about. 
```dart
final myStream = NumberCreator().stream;

final subscription = myStream.listen(
    (data) {
        print('Data: $data');
    },
    onError: (err) {
        print('Error!');
    }
);

```
I mentioned earlier that streams can produce errors just like futures can, by adding an onError method you can catch and process any errors.
```dart
final myStream = NumberCreator().stream;

final subscription = myStream.listen(
    (data) {
        print('Data: $data');
    },
    onError: (err) {
        print('Error!');
    },
    cancelOnError: false,
);

```
There's also a cancelOnError property that's true by default, but can be set to false to keep the subscription going even after an error. 
```dart
final myStream = NumberCreator().stream;

final subscription = myStream.listen(
    (data) {
        print('Data: $data');
    },
    onError: (err) {
        print('Error!');
    },
    cancelOnError: false,
    onDone: () {
        print('Done!');
    }
);

```
And there's an onDone method you can use to execute some code when the stream is finished sending data, such as when a file ahs been completely read. With all four of those properties combined, you can be ready in advance for whatever happens. Before moving on to the next section, I should mention that the little subscription object that's so far gone unnoticed has some useful methods of tis own. You can use it to pause, resume and even cancel the flow of data. 

```
subscription.pause()
subscription.resume()
subscription.cancel()
```

Okay, so that's a quick look at how you can use listen to subscribe to a stream and receive data events. 

Now we get to talk about what makes streams really cool: manipulating them. 

once you've got data in a sream, there are a lot of operations that suddenly become fluent and elegant. 

Let's go back to that number stream from earlier.
```dart
NumberCreator().stream
.where((i) => i % 2 == 0)
    .map((i) => 'String $i')
    .listen(print);
```
I can use a method called map to take each value from the stream and convert it, on the fly, into something else. I give map a function to do the conversion, and it returns a new stream, typed to match the return value of my function. Istead of a stream of ints, I now have a stream of strings. I can throw a listen call on the end, give it the print function and now I'm printing strings directly off the stream, asynchronously, as they arrive. There's a ton of methods you can chain up like this. If I only want to print the even numbers, for example, I can use where to filter the stream. I give it a test function that returns a Boolean for each element, and it returns a new stream that only includes values that pass that test.

distinct is another good one.
```dart
myReduxStore.onChange
    .map((s) => MyViewModel(s))
    .distinct()
```
If I have an app that uses a ReduxStore, that sotre emits new app state objects in an onChange stream. I can use map to convert that stream of state objects to a stream of ViewModels for one particular part of my app. Then I can use the distinct method to get a stream that filters out consecutive identical values, in case the store kicks out a change that doesn't affect the subset of data in MyViewModel. Then I can listen and update my UI whenever I get a new ViewModel.

There are a bunch of additional methods built into Dart that can use to shape and modify your streams. Plus, when you're ready for even more advanced stuff, there's the Async package, maintained by the Dart team and available on Pub.

It has classes that can merge two streams together, cache results and perform other types of stream-based wizardry. 

Alright, there's one more advanced topic that deserves a mention here, and that's how to create streams of your own. Just like with futures, most of the time, you're going to be working with streams created for you by network libraries, file libraries, state management and so on. But you can make your own as wel using a stream controller. Let's go back to that number creator we'd been using so far.

```dart
final myStream = NumberCreator().stream;
```

Here's the actual code for it.
```dart
class NumberCreator {
    NumberCreator() {
        Timer.periodic(Duration(seconds: 1), (t) {
            _controller.sink.add(_count);
            _count++;
        });
    }
}

var _count = 1;

final _controller = StreamController<int>();

Stream<int> get stream => _controller.stream;
```
As you can see, it keeps a running count, and it uses a timer to increment that count each second. The interesting bit though is the stream controller. A stream controller creates a brand new stream from scratch and gives you access to both ends of it. There's the stream end itself where data arrives. We've been using that one throughout this video, and there's the sink, which is where new data gets added to the stream. NumberCreator here uses both of them. When the timer goes off, it adds the latest count to the controller's sink, and then it exposes the controller's stream with a public property so other objects can subscribe to it. Now that we've covered creating, manipulating, and listening to streams, let's talk about how to put them to work building widgets in Flutter. 
```dart
FutureBuilder<String>(
    future: _fetchNetworkData(),
    builder: (context, snapshot) {
        /* build some widgets */
    },
)
```
If you saw the previous video on futures, you may remember FutureBuilder. You give it a future and a builder method, and it builds widgets based on the state of the future. For streams, there's a similar widget called StreamBuilder. 
```dart
StreamBuilder<String>(
    stream: NumberCreator().stream
        .map((i) => 'String $1'),
    builder: (context, snapshot) {

    }
)
```
Give it a stream, like the on from NumberCreator and a builder method, and it will rebuild its children whenever a new value is emitted by the stream. 
```dart
StreamBuilder<String>(
    stream: NumberCreator().stream
        .map((i) => 'String $1'),
    builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('No data yet.');
        } else if (snapshot.connectionState == ConnectionState.done) {
            return Text('Done!');
        } else if (snapshot.hasError) {
            return Text('Error!');
        } else {
            return Text(snapshot.data ?? '');
        }
    }
)
```
The snapshot parameter is an async snapshot just like with Futurebuilder. You can check its connectionState property to see if the stream hasn't yet sent any data, or if it's completely finished. And you can use the hasError property to see if the latest value is an error and handle data values as well.

The main thing is just to make sure your builder knows how to handle all the possible states of the stream. once you've got that, it can react to whatever the stream does. 

Okay, that's all we've got for this video, but there are more coming in the series. Next up, we'll be talking about Async and Await. They're two key words Dart offers to help you keep your asynchronous code tight and easy to read. So be on the lookout for that, and head to Dart.dev and Flutter.dev for more info on Dart and Flutter. 