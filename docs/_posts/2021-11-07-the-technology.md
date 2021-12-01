---
layout: post
title:  "What technology did we use?"
date:   2021-11-07 14:00:00 -0700
categories: jekyll update
---

### Flutter and the Google technology stack

### Why Flutter?
In an age where creating your own framework might be right around the corner.. why did the Pantree team decide to use Flutter and the Google technology stack? That, reader, is a fantastic question. There are a few reasons why Flutter shines a bit brighter than many current frameworks. 

### Cross-Platform Support
In our case, the most notable feature was the cross-platform support. Our first goal was to make a mobile application, as we believed that this would be the most useful medium for our application to be used on. As Flutter has support for iOS, Android, and Web, this felt like a very easy option for us as we would not have to develop three separate applications to serve the same code, we could keep it all in one project, which is much easier to maintain. 

&nbsp;

### Dart and Flutter 2.0
Google's home cooked language and framework were definitely a bit to get used to but we quickly found the strengths for both of these. One of our favorite features that was pivotal for many of our features is the framework's ability to handle state of the application. In our initial set up, we definitely viewed this as more of a hurdle, as state was something that most of us on the team had not encountered before - but the benefits it provided when we found out how to use it were great, and will come further into focus in the next section.

&nbsp;
### Firebase and Cloud Storage
When asked the question of where we would be storing our data, it was a very easy choice for us. Living within the Google technology stack enabled us to hook our database up seamlessly within our application, and have direct communication with objects that lived within our database. Beyond developing our UI, this was the largest focus in developing the Pantree application, as the majority of our features were centered around interacting with the database. One notable area that departs a bit from the paradigm that has been set up, is utilizing Cloud Storage. This is yet another service that Google provides, that is primarily used for larger objects over 1MB, such as images. We were able to integrate this into our application by carrying a reference that the Cloud Storage provides within Firebase, enabling this service to be used in a much wider scope.