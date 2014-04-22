package Pod::Perldoc::Cache;
use 5.008005;
use strict;
use warnings;
use File::Spec::Functions qw(catfile catdir);
use Digest::MD5 qw(md5_hex);
use Pod::Text ();

our @ISA = ('Pod::Text');

our $VERSION = "0.01";

sub parse_from_file {
    my ($self, $file, $out_fh) = @_;
    my $parser = do {
        if (exists $self->{_parser_module}) {
            $self->{_parser_module}->new;
        } else {
            Pod::Text->new;
        }
    };

    # use $HOME/.pod_perldoc_cache/ as cache directory
    my $cached = catdir($ENV{HOME}, '.pod_perldoc_cache');
    unless (-e $cached) {
        mkdir $cached;
    }

    my $digest = _pod_md5($file);
    my $cachef = $file;
    $cachef =~ s!/!_!g;
    my $abs_cachef = catfile($cached, $cachef) . ".$digest";

    if (-f $abs_cachef && not $self->{_ignore_cache}) {
        open my $cache_fh, '<', $abs_cachef
            or die "Can't open $abs_cachef: $!";
        print $out_fh $_ while <$cache_fh>;
    } else {
        $parser->parse_from_file($file, $out_fh);
        open my $cache_fh, '>', $abs_cachef
            or die "Can't write formatted pod to $abs_cachef\n";
        seek $out_fh, 0, 0;
        print $cache_fh $_ while <$out_fh>;
    }
}

sub _pod_md5 {
    my $pod_file = shift;
    my $pod = do {
        local $/;
        open my $pod_fh, '<', $pod_file
            or die "Can't read pod file: $!";
        <$pod_fh>;
    };
    md5_hex($pod);
}

# called by -w option
sub parser {
    my ($self, $parser_module) = @_;
    my $parser_file = $parser_module;
    $parser_file =~ s!\::!/!g;
    eval {
        require "$parser_file.pm";
    };
    if ($@) {
        die $@;
    } else {
        $self->{_parser_module} = $parser_module;
    }
}

# called by -w option
sub ignore {
    my $self = shift;
    $self->{_ignore_cache} = 1;
}

1;
__END__

=encoding utf-8

=head1 NAME

Pod::Perldoc::Cache - It's new $module

=head1 SYNOPSIS

    use Pod::Perldoc::Cache;

=head1 DESCRIPTION

Pod::Perldoc::Cache is ...

=head1 LICENSE

Copyright (C) Yuuki Furuyama.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Yuuki Furuyama E<lt>addsict@gmail.comE<gt>

=cut

