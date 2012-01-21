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
use Cwd;

my %options;
my $gitlog;

#
# Get options
#

GetOptions (
    \%options,
    "repo=s",
    "outfile=s",
    "help|?",
);

#
# Check and set options
#

if ($options{'help'}) {
    ShowHelp();
}

if ($options{'repo'} and $options{'repo'} ne '') {
   unless (-d $options{'repo'}) {
       print "Repository does not exist in given path!\n";
       exit;
   }
   unless (-d ($options{'repo'} . "/.git")) {
       print "Given directory is not a Git repository!\n";
       exit;
   }
}
else {
    ShowHelp();
}

unless ($options{'outfile'} and $options{'outfile'} ne '') {
    $options{'outfile'} = cwd();
}

#
# Do the job
#

$gitlog = ParseGitLog($options{'repo'});
unless ($gitlog) {
    print "Parsing `git log` command failed!\n";
    exit;
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

sub ParseGitLog {
    my $repo = shift || return undef;
    my $cmd = "git log --pretty=tformat:%H%n%cd%n%cn%n%ce%n%s%n%b%m $repo";
    my $result;

    $result = qx/$cmd/;
    if ($? == -1) {
        print "Command failed: $!\n";
        return undef;
    }
    return $result; 
}

sub SplitCommits {
    my $gitlog = shift || return undef;
    my @items = split(/\n>/, $gitlog);
    my $size = scalar @items;
    my (@lines, @commit, $i);

    for $i ( 0 .. ($size - 1) ) {
        @lines = split(/\n/, $items[$i], 6);
        $commit[$i] = [ @lines ];
    }
    return @commit;
}
