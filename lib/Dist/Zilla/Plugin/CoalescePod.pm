use strict;
use warnings;
package Dist::Zilla::Plugin::CoalescePod;
# ABSTRACT: merge .pod files into their .pm counterparts

use Moose;

with 'Dist::Zilla::Role::FileMunger';

sub munge_file {
    my ( $self, $file ) = @_;

    return unless $file->name =~ /\.pm$/;

    ( my $podname = $file->name ) =~ s/\.pm$/.pod/;

    my ( $podfile ) = grep { $_->name eq $podname } 
                           @{ $self->zilla->files } or return;

    $file->content(
        $file->content . $podfile->content
    );

    $self->zilla->prune_file($podfile);
}

1;
