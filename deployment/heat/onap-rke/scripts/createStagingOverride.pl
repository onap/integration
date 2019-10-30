#! /usr/bin/perl
# ============LICENSE_START====================================================
# =============================================================================
# Copyright (c) 2019 AT&T Intellectual Property. All rights reserved.
# =============================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============LICENSE_END======================================================


use LWP::Simple;
use JSON;

my $browser = LWP::UserAgent->new;
if(defined $ENV{'HTTPS_PROXY'}) {
   $browser->proxy('https', $ENV{'HTTPS_PROXY'});
}
elsif(defined $ENV{'http_proxy'}) {
   $browser->proxy('https', $ENV{'https_proxy'});
}



#############################################################################################
#  Usage: createStagingOverride.yaml staging-image-override.yaml
#      generates staging-image-orveride.yaml.out which can be used as a -f override file
#
#      script queries nexus3 docker.snapshot repository for the image tags 
#             query is only for lines with "onap/"  in the override.yaml file
#             ignores 2019/2010, v* tagged images to try to find the latest version numbered SNAPSHOT/STAGING:latest
#
#############################################################################################
$infile=$ARGV[0];
$outfile=">" . $infile . ".out";

my %VERSIONS='' ;

open (INFILE, $infile) or die "couldnt open INFILE $infile\n";
open(OUTOVER,$outfile) or die "couldnt open OUTOVER $outfile\n";

while ($line=<INFILE>) {
	#image: onap/portal-app:2.6.0-STAGING-latest
	if ($line=~/: onap\//) {
		chomp($line);
		($imageJunk,$imagePath,$imageVersion) = split(':', $line);
		$imagePath=~s/ //g;
		$imageVersion=~s/ //g;
		$stagingImageVersion=&getVersion($imagePath,$imageVersion);
		$stagingImageVersion=~s/ //g;
		print "$imagePath , $imageVersion, $stagingImageVersion\n";
                $VERSIONS{$imagePath}=$stagingImageVersion;
                $line=~s/$imageVersion/$VERSIONS{$imagePath}/;
                print OUTOVER $line . "\n";
	}
	else {
                print OUTOVER $line;
	}
}	

exit ;


sub getVersion {
	my   ($path, $version) = @_;
	#print $path , $version , "\n";
        my $url = "https://nexus3.onap.org:10001/v2/$path/tags/list"  ;
	#print $url , "\n";
        my $response = $browser->get( $url );
        die "Can't get $url -- ", $response->status_line 
		unless $response->is_success;
	#print $response->decoded_content;
	# name , tag [ ]
	$response_json=decode_json $response->decoded_content; 
	#print $response_json->{'name'} , "\n";	
	$latest_tag=$response_json->{'tags'}->[0] ;	
        $tags=$response_json->{'tags'};
	foreach my $element (@$tags)  {
		if ($element=~/^v/) {
			next ;
		}
		if ($element=~/2019/) {
			next ;
		}
		if ($element=~/2020/) {
			next ;
		}
		if ($element=~/\d\./) {
			#print $element , "\n";
			if($element gt $latest_tag) {
				$latest_tag=$element;
			}	
		}
	}
        return $latest_tag 
}


