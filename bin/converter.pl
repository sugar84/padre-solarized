#!/usr/bin/env perl
use common::sense;

my $dir = "./themes";

for my $filename (glob "$dir/*.tmpl") {
	my $contents = contents( $filename );
	
}

my $comp_templ = compile_template( $template );

my @content;
for my $key (keys %$conf) {
    my $data = $conf->{$key};
    $data->{'name'}   = $key;
    $data->{'port'} ||= 22;
    push @content, do_template( $comp_templ, $data );
}

sub prorcess_template {
    my ($template, $data) = @_;

    my ($first, $str, $key);
    my @keys = @{$template->{'keys'}};
    for my $piece (@{$template->{'pieces'}}) {
        if (!$first) {
            $str .= $piece;
            $first++;
        }
        else {
            $key  = shift @keys;
            $str .= $data->{$key} . $piece;
        }
    }
    return $str;
}

sub compile_template {
    my $template = shift;

    my @pieces = split /<\w+>/, $template;
    my @keys   = $template =~ /<(\w+)>/g;

    return {pieces => \@pieces, keys => \@keys};
}

sub contents {
	my $fname = shift;

	my @contents = do {
		open my $fh, "<", $fname
			or warn "cannot open template $fname: $!";
		local $/;
		<$fh>;
	};

	return \@contents;
}
