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
use HTML::Entities;

package GENERIC;

#
# Subroutines
#

sub GetInput {
    my $text = shift || return undef;
    my $mandatory = shift || 0;
    my $input;

    if ($mandatory) {
        until ($input) {
            print STDERR $text;
            $input = <>;
            chomp($input);
        }
    }
    else {
        print STDERR $text;
        $input = <>;
        chomp($input);
    }
    return $input;
}

sub CheckRepo {
    my $repo = shift || return undef;

    unless (-d $repo) {
        print "Repository does not exist in given path!\n";
        return undef;
    }
    unless (-d ($repo . "/.git")) {
        print "Given directory is not a Git repository!\n";
        return undef;
    }
    return 1;
}

sub ParseGitLog {
    my $repo = shift || return undef;
    my $count = shift;
    my ($cmd, $result);

    if ($count) {
        $cmd = "git log -n$count --pretty=tformat:%H%n%cd%n%cn%n%ce%n%s%n%b%m $repo";
    }
    else {
        $cmd = "git log --pretty=tformat:%H%n%cd%n%cn%n%ce%n%s%n%b%m $repo";
    }

    $result = "\n" . qx/$cmd/;
    if ($? == -1) {
        print "Command failed: $!\n";
        return undef;
    }
    $result =~ s/\s+$//; # Remove trailing whitespaces
    return HTML::Entities::encode($result);
}

sub SplitCommits {
    my $gitlog = shift || return undef;
    my @items = split(/\n&gt;/, $gitlog);
    my $size = scalar @items;
    my (@lines, @commit, $i);

    for $i ( 0 .. ($size - 1) ) {
        @lines = split(/\n/, $items[$i], 7);
        $commit[$i] = [ @lines ];
    }
    return @commit;
}

return 1;
