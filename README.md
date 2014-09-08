# raven-objc-alt

Objective-c client for [Sentry](https://www.getsentry.com/welcome/). Fork of the [official client](https://github.com/getsentry/raven-objc).

This fork changes the public interface, because I wanted to add a number of features but this would have resulted in an unweildy interface and untidy code.

## Installation

Install manually.

1. Get the code: `git clone git://github.com/joerick/raven-objc-alt`
2. Drag the `Raven` subfolder to your project. Check both "copy items into destination group's folder" and your target.

Alternatively you can add this code as a Git submodule:

1. `cd [your project root]`
2. `git submodule add git://github.com/joerick/raven-objc-alt`
3. Drag the `Raven` subfolder to your project. Uncheck the "copy items into destination group's folder" box, do check your target.


## How to get started

The easiest way to get started is to use `+[RavenClient setupSharedClientWithDSN:]`.

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [RavenClient setupSharedClientWithDSN:@"http://example:dsn@server/1"];
    //
    return YES;
}
```

This will setup your `[RavenClient sharedClient]`, install the unhandled exception handler and send any messages that were previously deferred (as a result of a unhandled exception).

### Sending messages

```objective-c
// Sending a basic message
[[RavenClient sharedClient] send:[RavenMessage messageWithString:@"TEST 1 2 3"]];

// Sending a message with another level
[[RavenClient sharedClient] send:[RavenMessage messageWithString:@"TEST 1 2 3" level:kRavenLogLevelWarning]];

// Sending a parameterized message (these will be coalesced in Sentry according to the format string)
[[RavenClient sharedClient] send:[RavenMessage messageWithFormat:@"Failed to discombobulate %@", name]];

// Sending an error message with an NSError
[[RavenClient sharedClient] send:[RavenMessage messageWithError:error]];

// There are also convenience methods for the above on RavenClient
[[RavenClient sharedClient] captureMessage:@"TEST 1 2 3"];
[[RavenClient sharedClient] captureMessage:@"TEST 1 2 3" level:kRavenLogLevelDebugInfo];
[[RavenClient sharedClient] captureFormat:@"Failed to discombobulate %@", name];
[[RavenClient sharedClient] captureError:error];

// and a macro for convenient format-string logging
RavenLog(@"Failed to discombobulate %@", name);
```

You can also manipulate the RavenMessage object itself, to change the level, add tags or extra information, or change other properties before it is sent.

```objective-c
RavenMessage *message = [RavenMessage messageWithString:@"Arithmetic error"];

message.level = kRavenLogLevelError;
message.tags = @{ @"difficulty": @"easy" };
message.extra = @{ @"sum": @"2 + 2" };

[[RavenClient sharedClient] send:message];
```

### Supplying contextual information

Additional information to be added to messages can be supplied to the RavenClient.

```objective-c
[RavenClient sharedClient].tags = @{ @"timezone": [[NSTimeZone systemTimeZone] name] };
[RavenClient sharedClient].user = @{ @"id": @"bob@example.com" };
[RavenClient sharedClient].extra = @{ /* something */ };

## License

raven-objc-alt is available under the MIT license. See the LICENSE file for more info.
