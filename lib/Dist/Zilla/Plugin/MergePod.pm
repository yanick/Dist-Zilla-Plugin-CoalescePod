use strict;
use warnings;
package Dist::Zilla::Plugin::MergePod;
# ABSTRACT: merge .pod files into their .pm counterparts

use Moose;

with 'Dist::Zilla::Role::InstallTool';

sub setup_installer {
  my ($self, $arg) = @_;

  require Dist::Zilla::File::InMemory;

  my %pm;
  my @pod;

  for ( @{ $self->zilla->files } ) {
      my $filename = $_->name;
      next unless $filename =~ /\.(pm|pod)$/;

      if ( $1 eq 'pm' ) {
          $pm{$filename} = $_;
      } else {
          push @pod, $_;
      }
  }

  for ( @pod ) {
    ( my $pm = $_->name ) =~ s/\.pod/.pm/;
    next unless $pm{$pm};

    $pm{$pm}->content(
        $pm{$pm}->content . $_->content
    );

    $self->zilla->prune_file($_);
  }

}

1;
