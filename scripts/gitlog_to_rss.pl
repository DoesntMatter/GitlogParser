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
use Getopt::Long;
use Cwd;
use HTML::Entities;
use FindBin;

use lib "$FindBin::Bin/../libs";
use Generic;
use Parser;
use RSS;

my %options;
my ($gitlog, $giturl);

#
# Get options
#

GetOptions (
    \%options,
    "repo=s",
    "count=i",
    "outfile=s",
    "title=s",
    "desc=s",
    "link=s",
    "github",
    "prompt",
    "help|?",
);

#
# Check and set options
#

unless ($options{'prompt'}) {
    if ($options{'help'}) {
        RSS::ShowHelp();
    }
    if ($options{'repo'} and $options{'repo'} ne '') {
        unless (Generic::CheckRepo($options{'repo'})) {
            RSS::ShowHelp();
        }
    }
    else {
        RSS::ShowHelp();
    }
    unless ($options{'outfile'} and $options{'outfile'} ne '') {
        $options{'outfile'} = cwd() . "/feed.rss";
    }
    if ($options{'title'} and $options{'title'} ne '') {
        $RSS::rss{'title'} = $options{'title'};
    }
    if ($options{'desc'} and $options{'desc'} ne '') {
        $RSS::rss{'desc'} = $options{'desc'};
    }
    if ($options{'title'} and $options{'title'} ne '') {
        $RSS::rss{'desc'} = $options{'desc'};
    }
    if ($options{'github'}) {
        $giturl = Generic::GetGithubUrl($options{'repo'});
    }
}
else {
    $options{'repo'} = Generic::GetInput("Please enter repository path: ", 1);
    unless (Generic::CheckRepo($options{'repo'})) {
        RSS::ShowHelp();
    }
    $options{'count'} = Generic::GetInput("Please enter count of commits: ");
    $options{'outfile'} = Generic::GetInput("Please enter outfile path: ");
    $RSS::rss{'title'} = Generic::GetInput("Please enter RSS title: ");
    $RSS::rss{'desc'} = Generic::GetInput("Please enter RSS description: ");
    $RSS::rss{'link'} = Generic::GetInput("Please enter RSS link: ");
    $options{'github'} = Generic::GetInput("Please confirm github usage (0|1): ");
    if ($options{'github'}) {
        $giturl = Generic::GetGithubUrl($options{'repo'});
    }
}

#
# Do the job
#

$gitlog = Parser::ParseGitLog($options{'repo'}, $options{'count'});
unless ($gitlog) {
    print "Parsing `git log` command failed!\n";
    exit;
}

RSS::CreateRSS(HTML::Entities::encode($gitlog), $options{'outfile'}, \%RSS::rss, $giturl);

exit;
