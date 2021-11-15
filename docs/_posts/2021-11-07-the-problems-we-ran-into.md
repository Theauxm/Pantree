---
layout: post
title:  "The timeline of Pantree"
date:   2021-11-07 14:08:14 -0700
categories: jekyll update
---

### Cooking, the Pandemic hobby. How on Earth am I supposed to organize a pantry??

### How we got started
The idea for Pantree came about as a result of living with 6 roommates during the Coronavirus shutdown. We were bored out of our minds, hungry for decent food, and all extremely broke (hence the 6 roommates). We couldn't afford to use meal services like DoorDash or UberEats everyday, so why not cook for each other? Well, if everybody wants to pitch in with ingredients, why not create a massive list so we can tell what needs to be bought at the grocery store?

That's great and all, but what about the roommates who are absolutely god awful at coming up with ideas for food to make? What if there was a way that you could tell exactly what you could make by opening an app? From there, Pantree was formed.

&nbsp;

### The technology -- Engineering decisions!
Early on we realized that using our own hardware would take up too much time. We wanted a service that provided exactly what we needed without any additional setup required. We needed a front-end language/framework that would let all of us (with next to no experience) be able to learn the foundational technology at a steady pace. On top of this, we knew we were going to need a database to hold massive amounts of data about food. Any freemium service would most likely cost money down the line, but there has to be something that at least gives a free tier, right?

We narrowed it down to a few frameworks and databases, ultimately deciding on Google Firestore. Each of us had extremely limited exposure to Google Cloud, but nonetheless it checked all of our boxes. Dart, Google's version of a front-end language, had a massive community and more tutorials than we would have time to watch over the course of the semester. However, their database options were another story.

The decision of a NoSQL database or MySQL database took about a week of talking to come to a conclusion. It is talked more about in another blog post, [NoSQL or Relational. Which should you use?][astley], but in short we decided to go with NoSQL since we knew structural changes were going to be made extremely often. The "dependency" nature of MySQL would lead us down a path of bad coding practice and un-necessary workarounds in the end.

&nbsp;

### The Web Scraper -- It's alive!!
After deciding on a NoSQL database, we needed some way of showing off an early version of what the backend would look like. This had more to do with the deadlines of marketing presentations than any actual coding necessities at that time. We didn't want to spend the time figuring out every niche edge case of web scraping, so we instead decided to go with a library that did the majority of the work for us. After many iterations, we were able to figure out how to recur down any website to get any and all recipes associated with it.

&nbsp;

### Pantree, a skeleton.
The team decided we wanted to focus on figuring out the best way to organize Pantree's app UI to keep the amount of tech debt at a low. No one on the team had used Dart prior to this project, meaning a lot of time was dedicated to learning best practices. By the end of the semester we had basic functionality for navigation between views, and front-end logic for searching recipes.

&nbsp;

### To finals week, and beyond!
By the time the semester began winding down we decided to take a break with Pantree. We didn't want to put pressure on anybody to put in additional work, though we made an agreement to begin having mettings a few weeks before the semester started up again. Thankfully, the project was left in a state at which it would be easy to pick up after a few months of dust.

&nbsp;

### Tech Debt -- Who knew?
During the first few weeks of our second semester we decided to refactor a few parts of the project after realizing a few better ways to go about architecting the code. This included improving the web scraper, and adding a user object that can be passed around to each view for easier access to data that is universal. It was at this point in the project that things really started to take form in terms of what the project was going to actually look like.

### Code organization
We began creating an organizational structure to our code, making sure that what each person worked on could be easily found by another. This included making standardizations to naming conventions, where files were in the code structure, and a general outline of arguments for each view's object to take along with it. This helped us cut down on the amount of time it would take to integrate a team member's code into their own. 

### Alpha Release
As the second semester went on, we were each mainly working independently on an assigned view. This was in an attempt to let each person work at their own pace, hopefully being able to get the code to a point where we could beging mering and interacting with each other's views. It wasn't until the week before Alpha that we realized how far behind we were. A meeting with our professor showed that we didn't really have much to show in terms of what the app promised, and as a result we spent the last week cranking out features.

Alpha release ended up being a success, and we were overall happy with where the app ended up. There were incomplete features and bugs, but the amount of work put into the application during that week proved the team was able to pull something together in a short time if necessary.

### Beta release
Once Alpha was finished, we had a pretty decent idea of where we wanted the app to end up. This included things like showing Missing Ingredients for the recipe search, being able to add and remove friends, upload photos to the social view, adding collaborators to pantries, adding and removing quantities from ingredients in the pantry/shopping list, and being able to let users create their own recipes. In retrospect it waas quite a tall order for the time we had, but overall the team spread out the work a lot better this time around.

Beta release also ended up being a success, and put the app in a position to be useable by industry standards. It was by no means polished and still had its fair share of bugs, but the original idea had finally began to take form.

[astley]: https://www.youtube.com/watch?v=dQw4w9WgXcQ