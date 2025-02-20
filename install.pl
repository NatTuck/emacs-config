#!/usr/bin/perl
use 5.30.0;
use warnings FATAL => 'all';

use LWP::UserAgent;
use HTTP::Request;
use JSON;

my $base = "http://ftp.gnu.org/gnu/emacs/";

my $req = HTTP::Request->new(GET => "$base");

my $ua = LWP::UserAgent->new();
my $resp = $ua->request($req);

unless ($resp->is_success) {
    die $resp->status_line;
}

my $max_vers = 0.0;
my $max_file = "";

my $parser = HTML::Parser->new(
    api_version => 3, 
    start_h => [\&on_tag, "tagname, attr"],
);
$parser->parse($resp->decoded_content);
$parser->eof();

sub on_tag {
    my ($tag, $attr) = @_;
    return unless $tag eq 'a';
    my $file = $attr->{'href'};
    return unless $file =~ /^emacs-([\d\.]*)\.tar\.xz$/;
    my $vers = $1;
    if ($vers > $max_vers) {
	$max_vers = $vers;
	$max_file = $file;
    }
}

unless ($max_vers > 0.0) {
    say "Nothing found.";
    exit(1);
}

say "Best file = $max_file";

my $apps = "$ENV{'HOME'}/Apps/src/emacs";

unless (-e "$apps/$max_file") {
    system(qq{mkdir -p "$apps"});
    system(qq{wget -O "$apps/$max_file" "$base/$max_file"});
}

system(qq{cd "$apps" && tar xvf "$max_file"});
system(qq{cd "$apps/emacs-$max_vers" && \
	  ./configure && make -j && \
          sudo make install});

