#!/usr/bin/perl -w
# 
# ***** BEGIN LICENSE BLOCK *****
# Version: ZPL 1.1
# 
# The contents of this file are subject to the Zimbra Public License
# Version 1.1 ("License"); you may not use this file except in
# compliance with the License. You may obtain a copy of the License at
# http://www.zimbra.com/license
# 
# Software distributed under the License is distributed on an "AS IS"
# basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
# the License for the specific language governing rights and limitations
# under the License.
# 
# The Original Code is: Zimbra Collaboration Suite.
# 
# The Initial Developer of the Original Code is Zimbra, Inc.
# Portions created by Zimbra are Copyright (C) 2005 Zimbra, Inc.
# All Rights Reserved.
# 
# Contributor(s):
# 
# ***** END LICENSE BLOCK *****
# 

use Time::HiRes qw ( time );
use strict;

use lib '.';

use LWP::UserAgent;

use XmlElement;
use XmlDoc;
use Soap;

my $ACCTNS = "urn:zimbraAdmin";
my $MAILNS = "urn:zimbraAdmin";

# If you're using ActivePerl, you'll need to go and install the Crypt::SSLeay
# module for htps: to work...
#
#         ppm install http://theoryx5.uwinnipeg.ca/ppms/Crypt-SSLeay.ppd
#
my $url = "https://localhost:7071/service/admin/soap/";

my $user;
my $action;

if (defined $ARGV[1] && $ARGV[1] ne "") {
    $user = $ARGV[0];
    $action = $ARGV[1];
} else {
    die "Usage reindex MBOX ACTION";
}

my $SOAP = $Soap::Soap12;
my $d = new XmlDoc;
$d->start('AuthRequest', $ACCTNS);
$d->add('name', undef, undef, "zimbra");
$d->add('password', undef, undef, "zimbra");
$d->end();

my $authResponse = $SOAP->invoke($url, $d->root());

print "AuthResponse = ".$authResponse->to_string("pretty")."\n";

my $authToken = $authResponse->find_child('authToken')->content;
print "authToken($authToken)\n";

my $sessionId = $authResponse->find_child('sessionId')->content;
print "sessionId = $sessionId\n";

my $context = $SOAP->zimbraContext($authToken, $sessionId);

my $contextStr = $context->to_string("pretty");
print("Context = $contextStr\n");

$d = new XmlDoc;
$d->add('ReIndexRequest', $MAILNS, { "id" => $user, "action" => $action });

print "\nOUTGOING XML:\n-------------\n";
my $out =  $d->to_string("pretty");
$out =~ s/ns0\://g;
print $out."\n";

my $start = time;
my $firstStart = time;
my $response;

$response = $SOAP->invoke($url, $d->root(), $context);

print "\nRESPONSE:\n--------------\n";
$out =  $response->to_string("pretty");
$out =~ s/ns0\://g;
print $out."\n";


