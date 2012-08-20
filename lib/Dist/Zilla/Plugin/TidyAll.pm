package Dist::Zilla::Plugin::TidyAll;
BEGIN {
  $Dist::Zilla::Plugin::TidyAll::VERSION = '0.01';
}
use Cwd qw(realpath);
use Code::TidyAll;
use Moose;
with 'Dist::Zilla::Role::FileMunger';

has 'mode'        => ( is => 'ro', default => 'dzil' );
has 'tidyall'     => ( is => 'ro', init_arg => undef, lazy_build => 1 );
has 'tidyall_ini' => ( is => 'ro', lazy_build => 1 );

sub _build_tidyall_ini {
    my ($self) = @_;

    my $root_dir = realpath( $self->zilla->root->stringify );
    return "$root_dir/tidyall.ini";
}

sub _build_tidyall {
    my ($self) = @_;

    return Code::TidyAll->new_from_conf_file(
        $self->tidyall_ini,
        mode       => $self->mode,
        no_cache   => 1,
        no_backups => 1
    );
}

sub munge_file {
    my ( $self, $file ) = @_;

    return if ref($file) eq 'Dist::Zilla::File::FromCode';

    my $source = $file->content;
    my $path   = $file->name;
    my $result = $self->tidyall->process_source( $source, $path );
    if ( $result->error ) {
        die $result->msg;
    }
    elsif ( $result->state eq 'tidied' ) {
        my $destination = $result->new_contents;
        $file->content($destination);
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;



=pod

=head1 NAME

Dist::Zilla::Plugin::TidyAll - Apply tidyall to files in Dist::Zilla

=head1 VERSION

version 0.01

=head1 SYNOPSIS

    # dist.ini
    [TidyAll]

    # or
    [TidyAll]
    tidyall_ini = /path/to/tidyall.ini

=head1 DESCRIPTION

Processes each file with L<tidyall|tidyall>, via the
L<Dist::Zilla::Role::FileMunger|Dist::Zilla::Role::FileMunger> role.

You may specify the path to the tidyall.ini; otherwise it is expected to be in
the dzil root (same as dist.ini).

=head1 SEE ALSO

L<tidyall|tidyall>

=head1 AUTHOR

Jonathan Swartz <swartz@pobox.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Jonathan Swartz.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

