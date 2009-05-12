= Rubidium =

== What is Rubidium? ==

Rubidium is a high-performance application to serve JavaScript for your applications. Based on a custom URL, it concatenates any number of JavaScript files, then uses the YUI Compressor to compress the result. The file is then cached, and served directly by nginx from that point forward. 

== Installation ==

Rubidium is a rack application, but it will only function as intended on [Nginx/Passenger](http://www.modrails.com/), since we rely on nginx's secure link module (details below). After cloning the repository, simply edit config/rubidium.sample.conf to reflect the path you're serving the application from, then choose a secret password. Edit your nginx.conf to "include" this file, eg.

    server {
      ...
      include /srv/rack/rubidium.53cr.com/config/rubidium.conf;
      ...
    }

== Crafting URLs ==

A Rubidium URL looks like:

    /some md5 hash/jquery+cufon+taffydb+++github.com+53cr.com.js

The first part, the md5 hash, is a security token. It's described in more detail below. The rest of the URL (up to the final ".js"), is made up of two lists. The first list, each item separated from the next by a "+", is a javascript file to include in the final script. Scripts are concatenated, in order, into the output file. 

A second, optional list -- a list of domains allowed to include this javascript -- can be started with a "+++", then delimited in the same way as the previous list. If the javascript is loaded on a page not in this list (if specified), an alert will pop up.

== Security ==

It didn't seem like a great idea to leave this wide open for people to hijack. I'd rather not serve JavaScript for sites I don't have anything to do with. You can specify a number of domains that 
