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
use HTML;

my ($gitlog, $giturl);
my %options = (
    outfile => cwd() . "/log.html",
);

#
# Get options
#


GetOptions (
    \%options,
    "repo=s",
    "count=i",
    "outfile=s",
    "prompt",
    "help|?",
);

#
# Check and set options
#

unless ($options{'prompt'}) {
    if ($options{'help'}) {
        HTML::ShowHelp();
    }
    if (Generic::HasValue($options{'repo'})) {
        unless (Generic::CheckRepo($options{'repo'})) {
            HTML::ShowHelp();
        }
    }
    else {
        HTML::ShowHelp();
    }
}
else {
    $options{'repo'} = Generic::GetInput("Please enter repository path: ", 1);
    unless (Generic::CheckRepo($options{'repo'})) {
        HTML::ShowHelp();
    }
    $options{'count'} = Generic::GetInput("Please enter count of commits: ");
    $options{'outfile'} = Generic::GetInput("Please enter outfile path: ");
}

#
# Do the job
#

$gitlog = Parser::ParseGitLog($options{'repo'}, $options{'count'});
unless ($gitlog) {
    print "Parsing `git log` command failed!\n";
    exit;
}

HTML::CreateHTML(HTML::Entities::encode($gitlog), $options{'outfile'});

exit;
