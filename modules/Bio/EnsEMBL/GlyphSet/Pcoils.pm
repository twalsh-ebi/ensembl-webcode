package Bio::EnsEMBL::GlyphSet::Pcoils;
use strict;
use vars qw(@ISA);
use Bio::EnsEMBL::GlyphSet;
@ISA = qw(Bio::EnsEMBL::GlyphSet);
use Sanger::Graphics::Glyph::Rect;
use Sanger::Graphics::Glyph::Text;
use Sanger::Graphics::Glyph::Composite;

sub init_label {
    my ($self) = @_;
	return if( defined $self->{'config'}->{'_no_label'} );
    my $label = new Sanger::Graphics::Glyph::Text({
        'text'      => 'Coils',
        'font'      => 'Small',
        'absolutey' => 1,
    });
    $self->label($label);
}

sub _init {
    my ($self, $protein, $Config) = @_;
    my %hash;

    my $y          = 0;
    my $h          = 4;
    my $highlights = $self->highlights();

    my $protein = $self->{'container'};
    my $Config  = $self->{'config'}; 
    
    my @coils_feat = @{$protein->get_all_CoilsFeatures};
    foreach my $feat(@coils_feat) {
	push(@{$hash{$feat->feature2->seqname}},$feat);
    }
    
    my $caption = "Coils";
    foreach my $key (keys %hash) {
	my @row = @{$hash{$key}};
	my $desc = $row[0]->idesc();
	
	my $Composite = new Sanger::Graphics::Glyph::Composite({});
	
	my $colour = $Config->get('Pcoils','col');
	foreach my $pf (@row) {
	    my $x = $pf->feature1->start();
	    my $w = $pf->feature1->end - $x;
	    my $id = $pf->feature2->seqname();
	    
	    my $rect = new Sanger::Graphics::Glyph::Rect({
		'x'        => $x,
		'y'        => $y,
		'width'    => $w,
		'height'   => $h,
		'id'       => $id,
		'colour'   => $colour,
	    });
	    $Composite->push($rect) if(defined $rect);	    
	}
	
	$self->push($Composite);
	$y = $y + 8;
    }
}
1;




















