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

no warnings 'uninitialized'; # We can use uninitialized variables without any problem here
package HTML;

#
# Subroutines
#

sub ShowHelp {
    print <<"HELP";
Gitlog to HTML - Converts the output of `git log` to a HTML file
Copyright (C) 2012, by:  Dennis Christ <jaed1\@gmx.net>

Options:
    --repo REPO         Path to your Git repository
    --count COUNT       Count of commits that shoud be parsed
                        Default: All commits
    --outfile FILE      Name and path of generated SQL file
                        Default: \$PWD/log.html
    --prompt            Prompt for input and do not use options
    --help              Show this output
HELP

    exit;
}

sub CreateHTML {
    my $gitlog = shift || return undef;
    my $file = shift || return undef;
    my @items = Parser::SplitCommits($gitlog, "\n&gt;");

    open(FILE, ">$file");
    print FILE "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE html 
     PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"
    \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">
<html xmlns=\"http://www.w3.org/1999/xhtml\">
<head>
    <title></title>
</head>
<body>";
    close(FILE);

    open(FILE, ">>$file");
    for my $i ( 0 .. $#items ) {
        # $items[$i][0] Blank
        # $items[$i][1] Commit-Hash
        # $items[$i][2] Commit-Date
        # $items[$i][3] Author
        # $items[$i][4] E-Mail
        # $items[$i][5] Subject
        # $items[$i][6] Body

        print FILE "<h3>$items[$i][5]</h3>
<p>$items[$i][3] &lt;$items[$i][4]&gt; committed $items[$i][1]</p>
<p>$items[$i][2]</p>
<p>$items[$i][5]</p>
<p>$items[$i][6]</p>";
    }
    close(FILE);

    open(FILE, ">>$file");
    print FILE "</body>
</html>";
    close(FILE);

    return 1;
}

return 1;
