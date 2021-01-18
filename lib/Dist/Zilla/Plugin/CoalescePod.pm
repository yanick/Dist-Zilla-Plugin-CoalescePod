package Dist::Zilla::Plugin::CoalescePod;
# ABSTRACT: merge .pod files into their .pm counterparts

use strict;
use warnings;

use Moose;

with qw(
    Dist::Zilla::Role::FileMunger
    Dist::Zilla::Role::FilePruner
);

has _pod_files => (
   is      => 'rw',
   isa     => 'ArrayRef',
   default => sub { [] },
);

sub munge_file {
    my ( $self, $file ) = @_;

    # only look under /lib
    return unless $file->name =~ m#^lib/.*\.pm$#;

    ( my $podname = $file->name ) =~ s/\.pm$/.pod/;

    my ( $podfile ) = grep { $_->name eq $podname } 
                           @{ $self->_pod_files } or return;

    $self->log( "merged " . $podfile->name . " into " . $file->name );

    my @content = split /(^__DATA__$)/m, $file->content;

    # inject the pod
    splice @content, 1, 0, $podfile->content;

    $file->content( join '', @content );

    return;
}

sub prune_files {
   my ($self) = @_;

   my @files = @{ $self->zilla->files };
   foreach my $file ( @files ) {
      next unless $file->name =~ m/\.pod$/;

      push @{ $self->_pod_files }, $file;
      $self->zilla->prune_file($file);
   }

   return;
}

1;
