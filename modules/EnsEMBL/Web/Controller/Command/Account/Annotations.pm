package EnsEMBL::Web::Controller::Command::Account::Annotations;

use strict;
use warnings;

use Class::Std;

use EnsEMBL::Web::RegObj;
use base 'EnsEMBL::Web::Controller::Command::Account';

{

sub BUILD {
  my ($self, $ident, $args) = @_; 
  $self->add_filter('EnsEMBL::Web::Controller::Command::Filter::LoggedIn');
}

sub process {
  my $self = shift;
  EnsEMBL::Web::Magic::stuff('Account', 'Annotations', $self, 'Popup');
}

}

1;
