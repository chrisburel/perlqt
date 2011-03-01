package QtBuilder;

use warnings;
use strict;
use Carp;

use base 'Module::Build';

sub ACTION_code {
    my $self = shift;
    $self->SUPER::ACTION_code(@_);

    $self->depends_on('puic');
}

sub ACTION_puic {
    my $self = shift;

    my $p = $self->{properties};
    local $p->{extra_compiler_flags} = [
        @{$self->extra_compiler_flags},
        '-Itools/puic',
        '-Itools/puic/perl',
    ];
    my @objects;
    my $files = $self->_find_file_by_type('cpp',  'tools/puic');
    foreach my $file (keys %$files) {
        push(@objects, $self->compile_c($file));
    }

    my $script_dir = File::Spec->catdir($self->blib, 'script');
    File::Path::mkpath( $script_dir );

    my $puic = File::Spec->catfile($script_dir, '/puic4');

    unless($self->up_to_date(\@objects, [$puic])) {
        $self->_cbuilder->link_executable(
            exe_file => $puic,
            objects => \@objects,
            extra_linker_flags => $p->{extra_linker_flags},
        );
    }

    $self->depends_on('config_data');
}

# this is sort of naive about what it takes to build an example.  Also,
# parsing the Makefile may not be the most robust mechanism.
sub ACTION_examples {
    my $self = shift;

    $self->depends_on('puic');
    my $puic = File::Spec->catdir($self->blib, 'script', 'puic4');

    my $makefiles = $self->rscan_dir('examples', qr/Makefile$/);
    foreach my $file (@$makefiles) {
        open(my $fh, '<', $file) or die "cannot open $file";
        my @ui_files;
        while(my $line = <$fh>) {
            if($line =~ m/\tpuic4 *(\w+\.ui) *-o *(Ui_\w+\.pm)/) {
                push(@ui_files, [$1, $2]);
            }
        }
        next unless(@ui_files);

        my ($v, $dir, $f) = File::Spec->splitpath($file);
        foreach my $ui (@ui_files) {
            my $in = File::Spec->catfile($dir, $ui->[0]);
            my $pm = File::Spec->catfile($dir, $ui->[1]);
            next if($self->up_to_date($in, $pm));
            $self->do_system($puic, $in, '-o', $pm) or die $!;
            $self->add_to_cleanup($pm);
        }
    }

    $self->depends_on('config_data');
}

1;
