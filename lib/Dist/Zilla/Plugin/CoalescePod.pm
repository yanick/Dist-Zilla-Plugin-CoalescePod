package Dist::Zilla::Plugin::CoalescePod;
BEGIN {
  $Dist::Zilla::Plugin::CoalescePod::AUTHORITY = 'cpan:YANICK';
}
{
  $Dist::Zilla::Plugin::CoalescePod::VERSION = '0.2.0';
}
# ABSTRACT: merge .pod files into their .pm counterparts

use strict;
use warnings;

use Moose;

with 'Dist::Zilla::Role::FileMunger';

sub munge_file {
    my ( $self, $file ) = @_;

    # only look under /lib
    return unless $file->name =~ m#^lib/.*\.pm$#;

    ( my $podname = $file->name ) =~ s/\.pm$/.pod/;

    my ( $podfile ) = grep { $_->name eq $podname } 
                           @{ $self->zilla->files } or return;

   $self->log( "merged $podfile into " . $file->name );

    my @content = split /(^__DATA__$)/m, $file->content;

    # inject the pod
    splice @content, 1, 0, $podfile->content;

    $file->content( join '', @content );

    $self->zilla->prune_file($podfile);
}

1;
#PODNAME: Foo

__END__

=pod

=head1 NAME

Foo - merge .pod files into their .pm counterparts

=head1 VERSION

version 0.2.0

=head1 SYNOPSIS

    # in dist.ini
    [CoalescePod]

=head1 DESCRIPTION

If the files I<Foo.pm> and I<Foo.pod> both exist, the content of the pod file is
appended at the end of the C<.pm>, and the pod file is removed.

=head1 AUTHOR

Yanick Champoux <yanick@babyl.dyndns.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Yanick Champoux.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
