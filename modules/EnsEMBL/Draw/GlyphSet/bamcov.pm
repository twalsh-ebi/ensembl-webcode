=head1 LICENSE

Copyright [1999-2016] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=cut

package EnsEMBL::Draw::GlyphSet::bamcov;

### Module for drawing data in either BAM or BigWig format 
### (initially only for internal data sources where we can
### guarantee there is a BigWig file)

use strict;

use Role::Tiny;

use parent qw(EnsEMBL::Draw::GlyphSet::UserData);

sub can_json { return 1; }

sub init {
  my $self = shift;
  my @roles;
  my $style = $self->my_config('style') || $self->my_config('display') || '';

  if ($style eq 'wiggle' || $style =~ /signal/) {
    push @roles, 'EnsEMBL::Draw::Role::Wiggle';
  }
  else {
    push @roles, 'EnsEMBL::Draw::Role::Bam';
  }

  ## Don't try to apply non-existent roles, or Role::Tiny will complain
  if (scalar @roles) {
    Role::Tiny->apply_roles_to_object($self, @roles);
  }

  $self->{'features'} = $self->features;
}

1;
