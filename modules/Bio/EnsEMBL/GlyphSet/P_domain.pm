package Bio::EnsEMBL::GlyphSet::P_domain;
use strict;
no warnings "uninitialized";
use base qw(Bio::EnsEMBL::GlyphSet);

## Variables defined in UserConfig.pm 
## 'caption'   -> Track label
## 'logicname' -> Logic name

sub _init {
  my ($self) = @_;
  my $protein       = $self->{'container'};

  $self->_init_bump;

  my $label         = $self->my_config( 'caption'    );
  my $depth         = $self->my_config( 'depth'      );
  my $h             = $self->my_config( 'height'     ) || 4;
  my $font_details  = $self->get_text_simple( undef, 'innertext' );
  my $pix_per_bp    = $self->scalex;

  foreach my $logic_name ( @{$self->my_config( 'logicnames' )||[]} ) {
    warn "LOOPING $logic_name";
    my %hash;
    my @ps_feat = @{$protein->get_all_ProteinFeatures( $logic_name )};
    push @{$hash{$_->hseqname}},$_ foreach @ps_feat;

    my $colour = $self->my_colour( lc($logic_name) );
    foreach my $key (keys %hash) {
      warn ".... $key ....";
      my $href = $self->ID_URL( $logic_name, $key );
      my( @rect, $prsave, $minx, $maxx );
      foreach my $pr (@{$hash{$key}}) {
	warn "...... $pr .....";
        my $x  = $pr->start();
        $minx  = $x if ($x < $minx || !defined($minx));
        my $w  = $pr->end() - $x;
        $maxx  = $pr->end() if ($pr->end() > $maxx || !defined($maxx));
        my $id = $pr->hseqname();
	warn ">>>>>>>>>>>> $x,0 $w,$h $colour";
        push @rect, $self->Rect({
          'x'        => $x,
          'y'        => 0,
          'width'    => $w,
          'height'   => $h,
          'colour'   => $colour,
        });
        $prsave ||= $pr;
      }
      my $title =  sprintf '%s domain: %s; Positions: %d-%d', $label, $key, $minx, $maxx;
         $title .= '; Interpro: '. $prsave->interpro_ac if $prsave->interpro_ac;
         $title .= '; '.$prsave->idesc                  if $prsave->idesc;
      my $Composite = $self->Composite({
        'x'     => $minx,
        'y'     => 0,
        'href'  => $href,
        'title' => $title
      });
      $Composite->push(@rect,
        $self->Rect({
          'x'        => $minx,
          'y'        => $h/2,
          'width'    => $maxx - $minx,
          'height'   => 0,
          'colour'   => $colour,
          'absolutey' => 1,
        })
      );
    #### add a label
      my $desc = $prsave->idesc() || $key;
      my @res = $self->get_text_width( 0, $desc, '', 'font'=>$font_details->{'font'}, 'ptsize' => $font_details->{'fontsize'} );
      $Composite->push($self->Text({
        'font'   => $font_details->{'font'},
        'ptsize' => $font_details->{'fontsize'},
        'halign' => 'left',
        'text'   => $desc,
        'x'      => $Composite->start(),
        'y'      => $h,
        'height' => $font_details->{'height'},
        'width'  => $res[2]/$pix_per_bp,
        'colour' => $colour,
        'absolutey' => 1
      }));

      if($depth>0) {
        my $bump_start = int($Composite->x() * $pix_per_bp);
        my $bump_end   = $bump_start + int( $Composite->width / $pix_per_bp );
        my $row        = $self->bump_row( $bump_start, $bump_end );
        $Composite->y( $Composite->y + ( $row * ( 4 + $h + $font_details->{'height'}))) if $row;
      }
      $self->push($Composite);
    }
  }
}
1;
