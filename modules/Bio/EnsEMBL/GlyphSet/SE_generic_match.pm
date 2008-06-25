package Bio::EnsEMBL::GlyphSet::SE_generic_match;
use strict;
use Bio::EnsEMBL::GlyphSet;
@Bio::EnsEMBL::GlyphSet::SE_generic_match::ISA = qw(Bio::EnsEMBL::GlyphSet);
use Data::Dumper;
$Data::Dumper::Maxdepth = 3;

sub init_label {
	my ($self) = @_;
	$self->init_label_text( 'Exon evidence' );
}

sub _init {
	my ($self) = @_;
	my $offset = $self->{'container'}->start - 1;
	my $Config  = $self->{'config'};
	my $h             = 8;
#	my $colours       = $self->colours();
	my $fontname      = $Config->species_defs->ENSEMBL_STYLE->{'GRAPHIC_FONT'};
	my $pix_per_bp    = $Config->transform->{'scalex'};
	my $bitmap_length = $Config->image_width(); #int($Config->container_width() * $pix_per_bp);

	$fontname = 'Tiny'; #this is hack since there is no config for Arial
	#warn Dumper($Config->texthelper);
	my($font_w_bp, $font_h_bp) = $Config->texthelper->px2bp($fontname);		
	my $length  = $Config->container_width(); 
	my $all_matches = $Config->{'transcript'}{'evidence'};
	my $strand = $Config->{'transcript'}->{'transcript'}->strand;
	my $H = 0;

	my @draw_end_lines;

	#go through each combined hit sorted on total length
	foreach my $hit_details (sort { $b->{'hit_length'} <=> $a->{'hit_length'} } values %{$all_matches} ) {
		my $start_x = 100000;
		my $finish_x = 0;
		my $hit_name = $hit_details->{'hit_name'};
#		warn "drawing $hit_name";
#		if ($hit_name eq 'BC023530.2') {
#			warn Dumper($hit_details);
#		}
		my $last_end = 0; #true/false (prevents drawing of line from first exon

		#go through each component of the combined hit (ie each supporting_feature)
		foreach my $block (@{$hit_details->{'data'}}) {
			$start_x = $start_x > $block->[0] ? $block->[0] : $start_x;
			$finish_x = $finish_x < $block->[1] ? $block->[1] : $finish_x;

			#draw a line back to the end of the previous exon (little bit hacky to get the boundries just right depending on the strand)
			my ($w,$x);
			if ($strand == 1) {
				$x = $last_end + (1/$pix_per_bp);
				$w = $block->[0] - $last_end - (1/$pix_per_bp);
			}
			else {
				$x = $last_end;
				$w = $block->[1] - $last_end;
			}

			if ($last_end) {
				my $G = new Sanger::Graphics::Glyph::Line({
					'x' => $x,
					'y' => $H + $h/2,
					'h'=>1,
					'width'=> $w,
					'colour'=>'black',
					'absolutey'=>1,});
				#add a dotted attribute if there is a part of the hit missing (defined by fourth element of $block)
				if ($block->[5]) {
					$G->{'dotted'} = 1;
				}
				$self->push($G);
			}
			
			$last_end = $strand == 1 ? $block->[1] : $block->[0];

			#second and third elements of $block define whether there is a mismatch between exon and hit boundries
			if ($block->[3]) {
				push @draw_end_lines, [$block->[0],$H];
			}
			if ($block->[4]) {
				push @draw_end_lines, [$block->[1],$H];
			}

			#draw the location of the exon hit
			my $G = new Sanger::Graphics::Glyph::Rect({
				'x'         => $block->[0] ,
				'y'         => $H,
				'width'     => $block->[1]-$block->[0],
				'height'    => $h,
				'bordercolour' => 'black',
				'absolutey' => 1,
				'title'     => $hit_name,
				'href'      => '',
			});	
			$self->push( $G );
		}

		#draw extensions at the left of the image (ie if evidence extends beyond the start of the image)
		if (   ($hit_details->{'start_extension'} && $strand == 1)
			|| ($hit_details->{'end_extension'} && $strand == -1)) {
			$self->push(new Sanger::Graphics::Glyph::Line({
				'x'         => 0,
				'y'         => $H + 0.5*$h,
				'width'     => $start_x,
				'height'    => 0,
				'absolutey' => 1,
				'colour'    => 'black',
			}));
		}
		#draw extensions at the right of the image
		if (   ($hit_details->{'end_extension'} && $strand == 1)
			|| ($hit_details->{'start_extension'} && $strand == -1)) {
			$self->push(new Sanger::Graphics::Glyph::Line({
				'x'         => $finish_x + (1/$pix_per_bp),
				'y'         => $H + 0.5*$h,
				'width'     => $length-$finish_x,
				'height'    => 0,
				'absolutey' => 1,
				'colour'    => 'black',
			}));
		}		

		if($Config->{'_add_labels'} ) {
			my  $T = length( $hit_name );
			my $width_of_label = $font_w_bp * ( $T ) * 1.5;
			$H += $font_h_bp + 2; #this is hack since there is no config for Arial
			$start_x -= $width_of_label/2; #also not sure about this as a way of setting the label to the far left of the feature
			my $tglyph = new Sanger::Graphics::Glyph::Text({
				'x'         => $start_x,
				'y'         => $H,
				'height'    => $font_h_bp,
				'width'     => $width_of_label,
				'font'      => $fontname,
				'colour'    => 'black',#$colour,
				'text'      => $hit_name,
				'absolutey' => 1,
			});

			$self->push($tglyph);
		}
		$H += 13; #this is yet another hack since there is no config for Arial
	}

	#draw (red) lines for the exon / hit boundry mismatches (draw last so they're on top of everything else)
	foreach my $mismatch_line ( @draw_end_lines ) {
		my $G = new Sanger::Graphics::Glyph::Line({
			'x'         => $mismatch_line->[0] ,
			'y'         => $mismatch_line->[1],
			'width'     => 0,
			'height'    => $h,
			'colour'    => 'red',
			'absolutey' => 1,
		});
		$self->push( $G );
	}
}

1;
