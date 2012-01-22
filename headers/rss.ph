#!/usr/bin/perl -w

# GitlogParser
# Converts the output of `git log` to different output types
#
# Copyright (C) 2012, by:  Dennis Christ <jaed1@gmx.net>
# http://dev-blog.doesntmatter.de
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# The GNU General Public License is available at:
# http://www.gnu.org/copyleft/gpl.html

use strict;

package RSS;

#
# Variables
#

my %rss = (
    title => 'Title of the RSS 2.0 Feed',
    desc  => 'RSS 2.0 feed description',
    link  => 'http://dev-blog.doesntmatter.de/',
);

#
# Subroutines
#

sub ShowHelp {
    print <<"HELP";
Gitlog to RSS - Converts the output of `git log` to a RSS feed
Copyright (C) 2012, by:  Dennis Christ <jaed1\@gmx.net>

Options:
    --repo REPO         Path to your Git repository
    --count COUNT       Count of commits that shoud be parsed
                        Default: All commits
    --outfile FILE      Name and path of generated RSS file
                        Default: \$PWD/feed.rss
    --title TITLE       Title of your RSS Feed
                        Default: "Title of the RSS 2.0 Feed"
    --desc DESC         Description of your RSS Feed
                        Default: "RSS 2.0 feed description"
    --link LINK         Link of your RSS Feed
                        Default: http://dev-blog.doesntmatter.de
    --prompt            Prompt for input and do not use options
    --help              Show this output
HELP

    exit;
}

sub CreateRSS {
    my $gitlog = shift || return undef;
    my $file = shift || return undef;
    my $rss = shift || return undef;
    my @items = GENERIC::SplitCommits($gitlog, "\n&gt;");
    my $weblink = "https://github.com";

    # Header
    open(FILE, ">$file");
    print FILE "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<rss version=\"2.0\">
<channel>

<title>$rss{'title'}</title>
<link>$rss{'link'}</link>
<description>$rss{'desc'}</description>
";
    close(FILE);

    # Content
    open(FILE, ">>$file");
    for my $i ( 0 .. $#items ) {
        # $items[$i][0] Blank
        # $items[$i][1] Commit-Hash
        # $items[$i][2] Commit-Date
        # $items[$i][3] Author
        # $items[$i][4] E-Mail
        # $items[$i][5] Subject
        # $items[$i][6] Body

        $items[$i][6] =~ s/\n/<br><br>/; # Better formatting

        print FILE "
<item>
    <title>$items[$i][5]</title>
    <link>$rss{'link'}</link>
    <description><![CDATA[
<a href=\"$weblink/$items[$i][3]\">$items[$i][3]</a> &lt;$items[$i][4]&gt; committed $items[$i][1]<br><br>
$items[$i][5]<br><br>
$items[$i][6]
   ]]></description>
</item>";
    }
    close(FILE);

    # Footer
    open(FILE, ">>$file");
    print FILE "\n
</channel>
</rss>";
    close(FILE);

    return 1;
}

return 1;
