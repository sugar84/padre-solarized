#!/usr/bin/env perl
use common::sense;


my $dir       = "./themes";
my $NEW_EXT   = "txt";
my $LEFT_TAG  = '%';
my $RIGHT_TAG = '%';
my $GET_TOKEN = qr/$LEFT_TAG(\w+)$RIGHT_TAG/o;

for my $filename (glob "$dir/*.tmpl") {
	my $contents = slurp_file( $filename );
	my $settings = get_settings( $contents );
	process_template( $contents, $settings );
	save_file( $filename, $contents );
}

sub get_settings {
	my $contents = shift;
	
	my $settings = {};
	for my $line (@$contents) {
		if ($line =~ /^#+\s*settings/ .. $line =~ /^#+\s*end/) {
			my ($key, $value) = $line =~ /^#\s+(w+)\s+\(w+)/;
			$settings->{$key} = $value;
		}
	}

	return $settings;
}

sub process_template {
	my ($contents, $settings) = @_;

	for my $line (@$contents) {
		if (my ($token) = $line =~ $GET_TOKEN) {
			die "no token $token is reperesnted in settings section"
				unless $settings->{$token};
			$line =~ s/${LEFT_TAG}$token$RIGHT_TAG/$settings->{$token}/;
		}
	}
 
	return;
}

sub slurp_file {
	my $fname = shift;

	my @contents = do {
		open my $fh, "<", $fname
			or warn "cannot open template $fname: $!";
		local $/;
		<$fh>;
	};

	return \@contents;
}

sub save_file {
	my ($fname, $contents) = @_;

	$fname =~ s/\.\w+$/_new.$NEW_EXT/;
	open my $fh, ">", $fname
		or die "cannot save file $fname: $!";
	print {$fh} @$contents;

	return;
}
