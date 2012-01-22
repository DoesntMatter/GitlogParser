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
use HTML::Entities;

my %options;
my $gitlog;
my %rss = (
    title => 'Title of the RSS 2.0 Feed',
    desc => 'RSS 2.0 feed description',
    link => 'http://dev-blog.doesntmatter.de/',
);

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
    "prompt",
    "help|?",
);

#
# Check and set options
#

unless ($options{'prompt'}) {
    if ($options{'help'}) {
        ShowHelp();
    }
    if ($options{'repo'} and $options{'repo'} ne '') {
        unless (CheckRepo($options{'repo'})) {
            ShowHelp();
        }
    }
    else {
        ShowHelp();
    }
    unless ($options{'outfile'} and $options{'outfile'} ne '') {
        $options{'outfile'} = cwd() . "/feed.rss";
    }
    if ($options{'title'} and $options{'title'} ne '') {
        $rss{'title'} = $options{'title'};
    }
    if ($options{'desc'} and $options{'desc'} ne '') {
        $rss{'desc'} = $options{'desc'};
    }
    if ($options{'title'} and $options{'title'} ne '') {
        $rss{'desc'} = $options{'desc'};
    }
}
else {
    $options{'repo'} = GetInput("Please enter repository path: ", 1);
    unless (CheckRepo($options{'repo'})) {
        ShowHelp();
    }
    $options{'count'} = GetInput("Please enter count of commits: ");
    $options{'outfile'} = GetInput("Please enter outfile path: ");
    $rss{'title'} = GetInput("Please enter RSS title: ");
    $rss{'desc'} = GetInput("Please enter RSS description: ");
    $rss{'link'} = GetInput("Please enter RSS link: ");
}

#
# Do the job
#

$gitlog = ParseGitLog($options{'repo'}, $options{'count'});
unless ($gitlog) {
    print "Parsing `git log` command failed!\n";
    exit;
}

CreateRSS($gitlog, $options{'outfile'}, \%rss);

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
};

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

sub CreateRSS {
    my $gitlog = shift || return undef;
    my $file = shift || return undef;
    my $rss = shift || return undef;
    my @items = SplitCommits($gitlog);
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

    return;
}
