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

package SQL;

#
# Subroutines
#

sub ShowHelp {
    print <<"HELP";
Gitlog to SQL - Converts the output of `git log` to a SQL file
Copyright (C) 2012, by:  Dennis Christ <jaed1\@gmx.net>

Options:
    --repo REPO         Path to your Git repository
    --count COUNT       Count of commits that shoud be parsed
                        Default: All commits
    --outfile FILE      Name and path of generated SQL file
                        Default: \$PWD/log.sql
    --prompt            Prompt for input and do not use options
    --help              Show this output
HELP

    exit;
}

sub TableStruct {
    my $file = shift || return undef;

    open(FILE, ">$file");
    print FILE "-- Create table structure 
CREATE TABLE IF NOT EXISTS `gitlog` (
    `hash`    varchar(40) NOT NULL DEFAULT '' COMMENT 'Unique identifier of commit',
    `date`    varchar(40) NOT NULL DEFAULT '' COMMENT 'Time of commit',
    `author`  varchar(30) NOT NULL DEFAULT '' COMMENT 'Author of commit',
    `email`   varchar(30) NOT NULL DEFAULT '' COMMENT 'Email of commit',
    `subject` text NOT NULL COMMENT 'Subject of commit',
    `body`    text NOT NULL COMMENT 'Body message of commit',
    PRIMARY KEY(`hash`)
);\n
-- Insert rows";
    close(FILE);

    return 1;
}

sub CreateSQL {
    my $gitlog = shift || return undef;
    my $file = shift || return undef;
    my @items = Parser::SplitCommits($gitlog);

    TableStruct($file);

    open(FILE, ">>$file");
    for my $i ( 0 .. $#items ) {
        # $items[$i][0] Blank
        # $items[$i][1] Commit-Hash
        # $items[$i][2] Commit-Date
        # $items[$i][3] Author
        # $items[$i][4] E-Mail
        # $items[$i][5] Subject
        # $items[$i][6] Body

        print FILE "
INSERT IGNORE INTO `gitlog` VALUES ('$items[$i][1]', '$items[$i][2]', '$items[$i][3]', '$items[$i][4]', '$items[$i][5]', '$items[$i][6]');";
    }
    close(FILE);

    return 1;
}

return 1;
