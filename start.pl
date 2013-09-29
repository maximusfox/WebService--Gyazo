#!/usr/bin/env perl

use strict;
use warnings;

use lib('lib');
use WebService::Gyazo;

my $timeID = time();
my $upAgent = WebService::Gyazo->new(id => $timeID);

print "Use id[".$timeID."]\n";

my $result = $upAgent->uploadFile('1.jpg');

unless ($upAgent->isError) {
	print "Returned result[".$result->getImageUrl()."]\n";
} else {
	print "Error:\n".$upAgent->error()."\n\n";
}