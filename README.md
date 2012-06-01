Did
===
Time tracking for the non-clairvoyant. 

Instead of telling an app what you're about to do, you tell did what you have just worked on. 

In the face of frequent task switches, be they crucial emails or bathroom breaks, 
this method leads to more accuracy and less revision.
In addition, process-minded folks may enjoy the way that using this method highlights task switches in your workday, 
making you more aware of those costly demons.

Installation
---

Until this is a gem, you'll have to make sure that the bin folder is in your path. 
For example: 

<code>
    PATH=$PATH:~/did2/bin
</code>

To take advantage of tag text completion, make sure bash-complete is installed (via Brew on a Mac.) 
Then add this to your .profile or .bashrc file: 

<code>
    complete -C did_autocomplete did
</code>

Usage
----
When you start your day, tell did that you got started:

<code>
    did sit
</code>

The first entry of the day simply marks the beginning of your workday. I suggest picking a task, such as 'sit' 
so that if you stop working and resume, you will know to ignore it in reports.

When you've completed a task, or if you find yourself drawn to check your email, or if someone comes to chat with you, 
tell did what you just did:

<code>
    did ios tutorials
</code>

When you come back, tell it again.

<code>
    did client pm phonecall
<code>

Everything after <code>did</code> is a tag describing the task you just worked on. 
Tag the timespans with words that will help you report on your efforts later. 
Consider including acryonyms for your client, project, and task for use with billing and project planning apps,
and/or ticket numbers for use with bug tracking systems.
With tab completion in place and a sensible tagging scheme, entering time can become very quick.

To report on today's work, use:

<code>
    did --report
</code>

This results in a simple summary of the tags you worked on and the total time spent on them.

In future releases, expect more customization.

Under the covers
----
Did stores all data in flatfiles in a directory called <code>.did</code> in your home directory. 
Each day is a separate file, located in a folder named for the month. 
Each entry in these files is a line containing the timestamp and the tags entered by the user. For example:

<code>
    2012-05-31 12:20:23 -0400 kitchen tea pushups
</code>

Also in the did home directory is a <code>tags</code> file collecting all unique tags used so far.
This is used by the tab completion utility.

The location of the home directory is configurable, via the <code>DID_HOME</code> environment variable. 
In your .profile or .bashrc file do something like this:

<code>
    export DID_HOME=~/subdirectory
</code>

This will create a <code>.did</code> folder within <code>~/subdirectory</code> with the same contents as above.

To confirm where any did command will read/write from, use the 'which' operation:

<code>
    did --which
</code>