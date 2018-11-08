# LandmarkRemark


This app allows users to save notes on the map at thier current location. It also allows users to see each
other's notes at the location it was written in.

So this implies that there are "Users" which means a logging-in/out system has to be included to differentiate 
notes from each other.

It also implies the usage of some storage system to save the notes and view them when users view the map, and for
that, Firebase Database, and Firebase Authentication was used.




An outline of the capabilities of the app:

1. Registering /logging-in/Logging-out users
2. Adding text notes on the map at the designated location
3. Viewing notes of all users at the designated location
3. Searching for notes by the usernames or the text of the note
4. Deleting notes of the logged in user


https://imgur.com/a/gTo1Et7


Time on each functionality:

- ViewControllers navigation logic : 20 mins
- Authentication mechanism : 1 Hour
- Creating a custom note and placing it on the location : 2 Hours
- Saving data to firebase : 1 Hour
- Retrieving data from fire-base and updating the map : 2.5 Hours
- Search functionality : 1.5 Hour
- UI design and buttons : 30 Mins

Known issue:

- Deleting note by a user will note immediatly be removed from all the users, because the .ChildRemoved API call is not being called for some reasion


Resources:

https://firebase.google.com/docs/ios/setup
https://stackoverflow.com/questions/38274115/ios-swift-mapkit-custom-annotation
https://stackoverflow.com/questions/30793315/customize-mkannotation-callout-view
http://sweettutos.com/2016/03/16/how-to-completely-customise-your-map-annotations-callout-views/
https://stackoverflow.com/questions/31446458/how-to-change-height-of-search-bar-swift
https://www.youtube.com/watch?v=zgP_VHhkroE
https://www.youtube.com/watch?v=UPKCULKi0-A
https://stackoverflow.com/questions/45291215/how-to-handle-internet-connection-status-firebase
https://stackoverflow.com/questions/32365654/how-do-i-compare-two-dictionaries-in-swift
