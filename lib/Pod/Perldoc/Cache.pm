package Pod::Perldoc::Cache;
use 5.008005;
use strict;
use warnings;
use File::Spec::Functions qw(catfile catdir);
use File::Path qw(mkpath);
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

    my $cache_dir = _cache_dir($ENV{POD_PERLDOC_CACHE_DIR});
    my $digest = _pod_md5($file);
    my $cache_file = $file;
    $cache_file =~ s!/!_!g;
    my $abs_cache_path = catfile($cache_dir, $cache_file) . ".$digest";

    if (-f $abs_cache_path && not $self->{_ignore_cache}) {
        open my $cache_fh, '<', $abs_cache_path
            or die "Can't open $abs_cache_path: $!";
        print $out_fh $_ while <$cache_fh>;
    } else {
        $parser->parse_from_file($file, $out_fh);
        open my $cache_fh, '>', $abs_cache_path
            or die "Can't write formatted pod to $abs_cache_path\n";
        seek $out_fh, 0, 0;
        print $cache_fh $_ while <$out_fh>;
    }
}

sub _cache_dir {
    my $cache_dir = shift;
    unless ($cache_dir) {
        $cache_dir = catdir($ENV{HOME}, '.pod_perldoc_cache');
    }
    unless (-e $cache_dir) {
        mkpath $cache_dir
            or die "Can't create cache directory: $cache_dir";
    }

    return $cache_dir;
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

