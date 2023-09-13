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

    my @content = ( $file->content );

    push @content, $1 if $content[0] =~ s/(^__DATA__.*)//ms;

    # inject the pod
    splice @content, 1, 0, $podfile->content;

    $file->content( join "\n\n", @content );
}

sub prune_files {
   my ($self) = @_;

   my @files = @{ $self->zilla->files };

   foreach my $file ( @files ) {
      next unless $file->name =~ m/\.pod$/;
      next if $file->name =~ /t\/corpus/;

      my $pm = $file->name =~ s/\.pod$/.pm/r;

      # only deal with pod files with associated pm files
      next unless grep { $_->name eq $pm } @files;

      push @{ $self->_pod_files }, $file;
      $self->zilla->prune_file($file);
   }
}

1;
