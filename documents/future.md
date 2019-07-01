# Future

Hey, everybody, and welcome to the second video in our Flutter in Focus series on asynchronous coding patterns in Dart.
Today we're going to cover one of the most basic APIs Dart has for async - Futures.

Most modern languages have some kind of support for asynchronous programming.

Many offer a futures API, and some call them Promises.

And for the most part, Dart's Futures are very similar to those found in other languages.

I like to think of them as little gift boxes for data. Somebody hands you one, and it starts off closed. Then a little while later, it pops open. And inside, there's either a value or an error. So thoses are the three states a Future can be in. First, the box is closed. We call that uncompleted. Then the box opens, and it's completed with a value or completed with an error. Most of the code you're about to see revolves around dealing with these three states. You know, one of your functions gets a Future, it needs to decide, OK, what do I do if the box isn't open yet? What do I do when it opens later and I have a value? And what about an error? And so on. So you're to see that one, two, three pattern a lot. 

You might also remember this guy from our previous video about the Dart Event Loop. A good thing to know about Futures is they're really just an API build to make using the Event Loop easier. The Dart code you is executed by a single thread. The whole time your app is running, that one little thread just keeps going around, picking up events from the Event Queue and processing them. FUtures work with the Event Loop to simplify things. Say you have some code for a download button. The user taps, and it starts downloading a picture of a cupcake or something.

Well, first, the tap event occurs. The Event Loop gets it, and your tap handler gets called. It uses the http library to make a request, and it gets a future in return. So now you've got your little box, right? It starts off closed, so your code uses Then to register a callback for when it opens. Then you wait. Maybe some other events come in. The user does some stuff and your little box just sits there while the Event Loop keeps going around. Eventually, data for the image arrives. And the https library says, great. I've got this Future right here. It puts the data in the box and pops it open, which triggers your callback.

```dart
RaisedButton(
    onPressed: () {
        final myFuture = http.get('https://my.image.url');
        myFuture.then((resp){
            setImage(resp);
        });
    },
    child: Text('Click me!'),
)
```
Now that little piece of code executes and displays the image. Throughout that process, your code never had to touch the Event Loop directly. Didn't care what else was going on, what other events came in. All it needed to do was get the Future from the https library and then say what it was going to do when the future completed. If I were a better coder, I probably would have added a code in case it completed with an error. But this series is a safe space. 

All right, first question. How to get an instance of a Future? Most of the time, you;re probably not going to be creating Futures directly. That's because many of the common async tasks already have libraries that generate Futures for you. 
```dart
myFuture = http.get('http://example.com');
```
Like network communication returns a Future. 

Accessing shared preferences returns a Future. 
```dart
myFuture = SharedPreferences.getInstance
```
But there are also constructors you can use.
```dart
import 'dart:async';

void main() {
    final myFuture = Future((){
        return 12;
    });
}
```
The simplest is the default, which takes a function and returns a Future with the same type. Then later, it runs the function asynchronously and uses the return value to complete the Future.

Let me add a couple print statements here to make clear the asynchronous part.
```dart
import 'dart:async';

void main() {
    final myFuture = Future((){
        print('Creating the future.');
        return 12;
    });
    print('Done with main().");
}
```
Now when I run this, you can see the entire main method finishes before the function I gave to the Future constructor. That's because the Future constructor just returns an uncompleted Future at first. It says, here's this box. You hold onto that for now, and later, I'll go run your function and put some data in there for you.
```dart
final myFuture = Future.value(12);
```
If you already know the value for the future, you can use the Future.value named constructor. The Future still completes asynchronously, though. I've used this one when building services that use caching. Somethies you've already got the value you need, so you can just pop it right in there.
```dart
final myFuture = Future.error(Exception());
```
Future.value also has a counterpart for completing with an error, by the way. It's called Future.error, and it works essentially the same way. but it takes an error object and an optional stack trace. 
```dart
final myFuture = Future.delayed(
    Duration(seconds: 5),
    () => 12,
)
```
The constructor I probably use the most, though, is Future.delayed. It works just like the default one, only it waits for a specified length of time before running the function and completing the Future. I use this one all the time when creating mock network services for testing. If I need to make sure my little loading spinner is displaying right and then goes away, somewhere, there's a delayed Future helping me out.

All right.  So that's where Futures come from. Now let's talk about how to use them. As I mentioned earlier, it's mostly about accounting for the three states a Future can be in, uncompleted, completed with a value, or completed with an error.

```dart
import 'dart:async';

void main(){
    Future<int>.delayed(
        Duration(seconds: 3),
        () {return 100;},
    );
    print('wating for a value...');
}
```
Here's a Future.delayed creating a Future that will complete three seconds later with a value of 100. Now when I execute this, main runs from top to bottom, creates the Future, and prints waiting for a value. That whole time, the Future is uncompleted. It won't complete for another three seconds. 
```dart
import 'dart:async';

void main(){
    Future<int>.delayed(
        Duration(seconds: 3),
        () {return 100;},
    ).then((value){
        print(value);
    });
    print('wating for a value...');
}
```
So if I want to use that value, I'll use then. This is an instance method on each Future that you can use to register a callback for when the Future completes with a value. You give it a function that takes a single parameter matching the type of the Future. And then once the Future completes with a value, your function executes with that value. So if I run this, I still get waiting for a value first. And then three seconds later, my callback executes and prints the value.
```dart
final myFuture = _fetchNameForId(12)
    .then((name) => _fetchCountForName(name))
    .then((count) => print(count);)
```
In addition, then returns a Future of its own matching the return value of whatever function you give it. So if you have a couple asynchronous calls you need to make, you can chain them together, even if they have different return types. 
```dart
import 'dart:async';

void main(){
    Future<int>.delayed(
        Duration(seconds: 3),
        () {return 100;},
    ).then((value){
        print(value);
    });
    print('wating for a value...');
}
```
Back to our first example, though, what happens if that initial Future doesn't complete with a value? What if it completes with an error? Then expects a value. We need a way to register another callback in case of an error. And you could do that with Catcherror.
```dart
import 'dart:async';

void main(){
    Future<int>.delayed(
        Duration(seconds: 3),
        () { throw 'Error!'; },
    ).then((value){
        print(value);
    }).catchError(
        (err){
            print('Caught $err');
        }
    );
    print('wating for a value...');
}
```
Catcherror works just like then, only it takes an error instead of a value, and it executes if the Future completes with an error. Just like then, it returns a Future of its own. So you can build a whoe chain of thens and catch errors and thens and catch errors that wait on one another. 
```dart
import 'dart:async';

void main(){
    Future<int>.delayed(
        Duration(seconds: 3),
        () { throw Exception(); },
    ).then((value){
        print(value);
    }).catchError(
        (err){
            print('Caught $err');
        },
        test: (err) => err.runtimeType == String,
    );
    print('wating for a value...');
}
```
You can even give it a test method to check the error before invoking the callback. You can have multiple catch error methods this way, each one checking for a diffent kind of error.

Now that we've gotten this far, hopefully you can see what I mean about how the three states of a Future are often reflected by the structure the code. There are three blocks here. The first creates an uncompleted Future. THen there's a function to call when the Future completes with a value and another if it completes with an error. 

I do have one more method to show you, though, which is when complete.
```dart
import 'dart:async';

void main(){
    Future<int>.delayed(
        Duration(seconds: 3),
        () { throw Exception(); },
    ).then((value){
        print(value);
    }).catchError(
        (err){
            print('Caught $err');
        },
        test: (err) => err.runtimeType == String,
    ).when Complete((){
        print('All finished!');
    });
    print('wating for a value...');
}
```
You can use this to execute a method when the future is completed, no matter whether it's with a value or an error. It's like the finally block in a try catch finally. There's code executed if everything goes right, code for an error, and then code that runs no matter what. So that's how you create Futures and a bit about how you can use their values. Now let's talk putting them to work in Flutter. This will probably be the least complicated section of this video. Let me show you why. 

Say you have a network service that's going to return some JSON, and you want to display it. You could create a stateful widget that will create the Future, check for completion or error, call set state, and generally handle all that wiring manually. Or you can use FutureBuilder. 
```dart
class MyWidget extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return FutureBuilder<String>(
            future: _fetchNetworkData(),
            builder: (context, snapshot) {

            },
        );
    }
}
```
It's widget that comes with the Flutter SDK. You give it a Future and a builder method, and it will automatically rebuild its children when the Future completes. It does that by calling its builder method, which takes a context and a snapshot of the current state of the Future. 
```dart
class MyWidget extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return FutureBuilder<String>(
            future: _fetchNetworkData(),
            builder: (context, snapshot) {
                if (snapshot.hasError) {
                    return Text(
                        'There was an error ', 
                        style: Theme.of(context).textTheme.headline,
                    )
                }
            },
        );
    }
}
```
You can check the snapshot to see if the Future completed with an error and report it. 
```dart
class MyWidget extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return FutureBuilder<String>(
            future: _fetchNetworkData(),
            builder: (context, snapshot) {
                if (snapshot.hasError) {
                    return Text(
                        'There was an error ', 
                        style: Theme.of(context).textTheme.headline,
                    )
                } else if (snapshot.hasData) {
                    return Text(
                        json.decode(snapshot.data)['delay_was'],
                        style: Theme.of(context).textTheme.headline,
                    )
                } else {
                    return Text(
                        'No value yet!',
                        style: Theme.of(context).textTheme.headline,
                    );
                }
            },
        );
    }
}
```
Otherwise, you can check the has data property to see if it completed with a value. And if not, you know you're still waiting. So you can output something for that as well. Even in Flutter code, you can see how those three states keep popping up, uncompleted, completed with value, and completed with error. 

All right. That's all we've got for this video, but there are more coming in the series. Next up, we'll be talking about streams. They're a lot like Futures, in that they can either provide values or errors. But where Futures just give you one and stop, streams keep right on going. So be on the lookout for that and head to dart.dev and flutter.dev for more info on Dart and Flutter. 