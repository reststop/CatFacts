#  Cat Facts

## Decisions

### App Design

-   Keep the UI design as simple as possible, nothing flashy
-   Simple mechanism to switch between the App and Stats
-   Put dynamic info: Stats, into a table so it may be expanded as needed*

* If we have sufficient stats.  With only one or two API calls to get information, there isn't a need for this.  However, by using a table we allow the application to be expanded and other information can be displayed.  It also makes for a cleaner interface, without having individual labels and data values getting moved around bycause of device orientation.

Consider using a tabbed application with one tab displaying the views for the App itself, and another tab displaying the API stats

Based on the CatFact API described below, to design an App which has a list of names which when selected gives more detail, it seems appropriate to use the breed as the name, and the remaining information about each breed as the expanded data.  There really isn't a connection between the breeds and the facts (which is a shame).

To use more of the API calls, we could display a random cat fact on the view which displays more information about a breed.  However, this could be a distraction, especially since a random fact would likely have no direct correlation to the expanded data about any particular breed.

We'll consider adding this later.

One of the requirements is to page the data.  The site data shows there are currently only 98 total breeds, and 142 total facts.  There isn't really enough data that it would require paging, as to provide the best user experience we can easily hold all the data in memory quite easily.  However, if the data were to grow, it would make more sense to cache the data using Core Data, firebase or some other persistent store, including the cloud.  (In my personal apps, I originally used SQLite and considered using Core Data, to store a 50,000 word dictionary.  However when I realized a normal size JPEG image used more memory than my dictionary, I switched to using an in-memory array).

For the purposes of this code challenge, I plan to keep it simple. Start with the data, once read, cached in memory, and once I'm happy with the results, switche to keeping some data in memory, and refetching data as if there was a real memory issue.


### Improvements

I noted that I might add Notifications to update the statistics table.  I added that so we
could see the stats update in real time.

What I didn't add, was a comprehensive array/data management.  I left the fetching of
the original data as paged, and tried a couple of page sizes, settling on 8 for demo
purposes.  The full management would have looked at the most recent displayed cell
index and based on that decided whether pages of data entries could be removed and
replaced in the breeds array with nil entries (which then display ...loading... in the cell),
and when scrolling to an area that has been turned to nil, pages would be fetched again.

The same could be said for monitoring the last displayed cell and pre-fetch a page on
either side of the displayed data (via windowing).  I decided NOT to go through all the trouble
to do this in the app, and keep it as fairly simple as possible, and for such small amounts
of data I'm not sure the user would notice.

There are probably a few UI improvements which could be made

One last change was to add a quick error trap on the internet connection to pass back
the error info so that an alert could be put up on the main screen.  That addition was
quick and dirty to wrap the code in an if error == nil and an else whcih called the completion
with the error info.  I didn't bother to clean up the indenting around that.  Mostly so
I could pack up the project and send it along...

-Cheers!

### CatFact Ninja API (https://catfact.ninja)

The API appears to only have 3 major calls:

-   /breeds -- Returns a list of breeds
-   /fact -- Returns a random cat fact
-   /facts -- Get a list of cat facts

#### /breeds -- Returns a list of breeds

-   limit=n -- number of entries per page (max: 1000)
-   max_length=n  -- maximum length of each returned fact string
-   page=n -- specify which page (of limit entries) to return

```
GET 'https://catfact.ninja/breeds?limit=5' --header 'Accept: application/json'

"current_page": 1,
"data": [ ],
"first_page_url": "https://catfact.ninja/breeds?page=1",
"from": 1,
"last_page": 20,
"last_page_url": "https://catfact.ninja/breeds?page=20",
"next_page_url": "https://catfact.ninja/breeds?page=2",
"path": "https://catfact.ninja/breeds",
"per_page": "5",
"prev_page_url": null,
"to": 5,
"total": 98

```
```
"data":
{
    "breed": "Abyssinian",
    "coat": "Short",
    "country": "Ethiopia",
    "origin": "Natural/Standard",
    "pattern": "Ticked"
}

```


#### /fact -- Returns a random cat fact

-   max_length=n  -- maximum length of each returned fact string

```
GET 'https://catfact.ninja/fact?max_length=140' --header 'Accept: application/json'

{
    "fact": "Long, muscular hind legs enable snow leopards to leap seven times their own body length in a single bound.",
    "length": 106
}

```


#### /facts -- Get a list of cat facts

-   limit=n -- number of entries per page (max: 1000)
-   max_length=n  -- maximum length of each returned fact string
-   page=n -- specify which page (of limit entries) to return


```
GET 'https://catfact.ninja/facts?limit=5&max_length=140' --header 'Accept: application/json'

"current_page": 1,
"data": [ ],
"first_page_url": "https://catfact.ninja/facts?page=1",
"from": 1,
"last_page": 49,
"last_page_url": "https://catfact.ninja/facts?page=49",
"next_page_url": "https://catfact.ninja/facts?page=2",
"path": "https://catfact.ninja/facts",
"per_page": "5",
"prev_page_url": null,
"to": 5,
"total": 241

```
```
"data":
{
    "fact": "Cats and kittens should be acquired in pairs whenever possible as cat families interact best in pairs.",
    "length": 102
},

```

### Metrics (Statistics)

I decided that a tableview would work best for the statistics, since we may want to identify
numerous statistics along the way.  A Statistic class (so I could point multiple places to a
particular statistic).  Once implemented though, I didn't like the way it was updating, so I
rewrote it to store all the statistics in a single table, and used the Name to identify the
actual entry in the table, so eventually this could work either as a struct or a class with no
difference in functionality.  As a class, using class functions, as a struct usinf mutating
functions.


#### Device Make/Model
The Make is going to be "Apple".
The Model provided by UIDevice().model is simply "iPhone", or "iPad", etc.
A more accurate value is the raw value of utsname().machine, and then there is UIDevice.current.name.

(Choices, choices, choices)!

#### OS name/version
Relative straightforward: UIDevice.current.systemName/systemVersion

#### Application name/version
Not asked for, but something I always want in statistics.  Data gathrered from the mainBundle using keys: CFBundleName, CFBundleShortVersionString, and CFBundleVersion.

#### Current memory usage of the App
Ahhh, getting the current memory.  Apple doesn't like people trying to get low level information, and while there are standard unix methods to get this kind of information, Apple has decided not to make it "easy", and it seems the C to Swift interface is a moving target.

I debated whether to just add an Objective-C module in a wrapper, but was able with an hour or so of internet searching to find a Swift solution.  It is mentioned that this shouldn't be used in production code, so a more stable version ought to be identified.

This implementation thankfully provided by Quinn (one of Apple's developer relations experts) in an answer on the Apple Developer forums.  I'm sure that New Relic has a blessed version of what they like to use in production.


#### Each API called during this run and average response time in milliseconds

Not a whole lot of APIs called as I see it.  So what I thought might have been a lot really boils down to https://catfact.ninja/breeds, tracking the number of ms for each time it is called for an average, and the last time it was called.

What makes this interesting is that when it is called would determine the refill strategy fo cells in the tableview list.  I'll update this once that strategy code is written.



## New Relic Code Challenge


Create a mobile app (“app”) in Kotlin (Android) or Swift (iOS) that uses the current production version of Android Studio or XCode respectively and implements an app that displays scrollable lists of cat facts. The app should be able to efficiently show a very long list, and selecting an entry in the list should display more information. The user should be able to navigate back and forth between views. The app should capture performance information that is available in another view via a control of your choice that shows metrics for the average response time of the API calls you make, information about the OS version and device the app is running on, and current memory usage of the app.

### Primary Considerations

-   Consider user experience and loading time of that experience.
-   Let the user know you are fetching/waiting for data.
-   App may run on any kind/form factor of device, and it may be rotated.
-   The app should work correctly as defined below in Requirements.
-   The overall structure of the app should be simple.
-   The code of the app should be descriptive and easy to read, and the build method and runtime parameters must be well-described and work.
-   The design should be resilient with regard to network connectivity loss.

-   The App and its UI should be optimized for maximum performance and resource usage, weighed along with the other Primary Considerations and Requirements below.

### Requirements

-   Create a new project using the latest version of XCode.
-   Create a main scrollable text list view that displays names of cats. The data is pageable.
-   Use the Cat Facts API to download facts about cats (https://catfact.ninja)
-   Tapping cat names should display additional detail about the cat.
-   For each network call, you capture the response time of that call. You track the average response time per API endpoint..
-   You detect the device and OS version you are running on.
-   You capture the current memory usage of the app.
-   A control of your choice opens a view that displays a list of these metrics and metadata:
    -   Each API called during this run and average response time in milliseconds
    -   Device make/model
    -   OS version
    -   Current memory usage of app
-   User can navigate between all views.
-   Be as creative as you wish on the UI presentation.
-   Clearly state all of the assumptions you made in completing the app along with any instructions on how to set up and run it in a README file.

### Notes

-   You may write tests at your own discretion. Tests are useful to ensure your app passes the Primary Considerations.

-   You may use common libraries in your project, particularly if their use helps improve Application simplicity and readability.

-   We'll initially test your solution using the latest production version of the Android Studio or XCode development tools. If your project requires any components not found in a default install of the developer tool, you must provide instructions (and automation) to install those components (or include them in your archive).


