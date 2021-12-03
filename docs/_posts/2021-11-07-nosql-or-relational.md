---
layout: post
title:  "Relational or Non-Relational. Which database Should You Use?"
date:   2021-11-07 14:08:14 -0700
categories: jekyll update
---

### Firstly, What Is SQL? And Why Would I Want It?

### SQL 101
SQL stands for Structured Query Language, and it has been around for longer than almost the entire Pantree team combined (1979). Despite it's age, there are some strong reasons for it to still be around. First and foremost, SQL has allows for incredible detail in the information that can be queried from the database. But, this does require a decent amount of thought to be put into the actual schema (design) for the database. The general breakdown of a relational database using SQL, is separated into two objects - tables and records. SQL requires the user to adhere very closely to the definition for each of these tables, where very little, to no wiggle room. This can be viewed as a strength or a weakness for SQL, as it requires your data to be very consistent, but it can also feel restrictive when developing against it.

### Why Firebase
Departing from SQL being a relational form of database, Firebase is a non-relational database that does not have relationships as a requirement between collections. Where SQL has tables, Firebase has collections, and records to documents as well. Consequently, it is much harder to break any sort of 'schema' that would exist in this style of database. Similarly to SQL, this can be viewed as a strength or a weakness, as we are able to add any field that we might desire to a particular document, and the entire collection does not have to adhere to the same fields that any other document within that collection needs. While this is a very nice feature for designing, it can equally be a hurdle to get over when creating documents that need to be consistent, as there are very little requirements for a new document. We were able to get around this issue, by creating empty fields on each document that we desired to have a particular field.

&nbsp;

### So Why Did the Pantree Team Choose Firebase?

Now that we know that there are some very powerful features in both relational and non-relational databases, let's dive into the reasons why we chose to use Firebase. The biggest and most obvious one would be that when we chose to use Flutter and Dart, Google pushes it's users to take up all the entire technology stack as they are marketed to be work quite nicely with each other. In practice, I would say this is fairly accurate, with the majority of the short-comings of the entire technology stack to be almost entirely isolated within the fact that Flutter and Dart have less documentation, and community support than other technology stacks. Additionally, Google's own documentation does often does not write their documentation in Dart, which we found to be very odd. 
