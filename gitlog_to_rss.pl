#!/usr/bin/perl -w

# Gitlog to RSS
# Converts the output of `git log` to a RSS feed
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
use Getopt::Long;

my %options;

GetOptions (
    \%options,
    "repo=s",
    "outfile=s",
    "help|?",
);

if ($options{'help'}) {
    ShowHelp();
}

exit;

#
# Subroutines
#

sub ShowHelp {
    print <<"HELP";
Gitlog to RSS - Converts the output of `git log` to a RSS feed
Copyright (C) 2012, by:  Dennis Christ <jaed1\@gmx.net>

Options:
    --repo REPO         Path to your Git repository
    --outfile FILE      Name and path of generated RSS file
    --help              Show this output
HELP

    exit;
};
