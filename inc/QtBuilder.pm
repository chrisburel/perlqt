package QtBuilder;

use warnings;
use strict;
use Carp;

use base 'Module::Build';

my %MODULES = (
    qtcore        => {
        pcfile => 'QtCore',
        sofile => 'QtCore4',
        libs => [qw(-lsmokeqtcore)],
    },
    phonon        => {
        pcfile => 'phonon',
        sofile => 'Phonon',
        libs => [qw(-lsmokephonon)],
    },
    qimageblitz   => {
        pcfile => 'qimageblitz',
        sofile => 'QImageBlitz',
        libs => [qw(-lsmokeqimageblitz)],
    },
    qsci          => {
        pcfile => 'qsci',
        sofile => 'Qsci',
        libs => [qw(-lsmokeqsci)],
    },
    qt3support    => {
        pcfile => 'Qt3Support',
        sofile => 'Qt3Support4',
        libs => [qw(-lsmokeqt3support)],
    },
    qtdbus        => {
        pcfile => 'QtDBus',
        sofile => 'QtDBus4',
        libs => [qw(-lsmokeqtdbus)],
    },
    qtdeclarative => {
        pcfile => 'QtDeclarative',
        sofile => 'QtDeclarative4',
        libs => [qw(-lsmokeqtdeclarative)],
    },
    qtgui         => {
        pcfile => 'QtGui',
        sofile => 'QtGui4',
        libs => [qw(-lsmokeqtgui -lsmokeqtdbus -lsmokeqtnetwork)],
    },
    qthelp        => {
        pcfile => 'QtHelp',
        sofile => 'QtHelp4',
        libs => [qw(-lsmokeqthelp)],
    },
    qtmultimedia  => {
        pcfile => 'QtMultimedia',
        sofile => 'QtMultimedia4',
        libs => [qw(-lsmokeqtmultimedia)],
    },
    qtnetwork     => {
        pcfile => 'QtNetwork',
        sofile => 'QtNetwork4',
        libs => [qw(-lsmokeqtnetwork)],
    },
    qtopengl      => {
        pcfile => 'QtOpenGL',
        sofile => 'QtOpenGL4',
        libs => [qw(-lsmokeqtopengl)],
    },
    qtscript      => {
        pcfile => 'QtScript',
        sofile => 'QtScript4',
        libs => [qw(-lsmokeqtscript)],
    },
    qtsql         => {
        pcfile => 'QtSql',
        sofile => 'QtSql4',
        libs => [qw(-lsmokeqtsql)],
    },
    qtsvg         => {
        pcfile => 'QtSvg',
        sofile => 'QtSvg4',
        libs => [qw(-lsmokeqtsvg)],
    },
    qttest        => {
        pcfile => 'QtTest',
        sofile => 'QtTest4',
        libs => [qw(-lsmokeqttest)],
    },
    qtuitools     => {
        pcfile => 'QtUiTools',
        sofile => 'QtUiTools4',
        libs => [qw(-lsmokeqtuitools)],
    },
    qtwebkit      => {
        pcfile => 'QtWebKit',
        sofile => 'QtWebKit4',
        libs => [qw(-lsmokeqtwebkit)],
    },
    qtxml         => {
        pcfile => 'QtXml',
        sofile => 'QtXml4',
        libs => [qw(-lsmokeqtxml)],
    },
    qtxmlpatterns => {
        pcfile => 'QtXmlPatterns',
        sofile => 'QtXmlPatterns4',
        libs => [qw(-lsmokeqtxmlpatterns)],
    },
    qwt           => {
        pcfile => 'qwt',
        sofile => 'Qwt',
        libs => [qw(-lsmokeqwt)],
    },
);                 

sub import {
    my ($class) = @_;
    foreach my $modname ( sort keys %MODULES ) {
        no strict 'refs';
        *{"${class}::ACTION_$modname"} = sub {
            my $self = shift;

            my $pcfile = $MODULES{$modname}{pcfile};
            my $flags = `pkg-config --cflags $pcfile 2> /dev/null`;

            my (@flags, @libs, @inc_dirs);
            if (defined($flags) && length($flags)) {
                my @flags2 = split(' ', $flags);
                foreach my $flag ( @flags2 ) {
                    if ($flag =~ m/^-I/) {
                        $flag =~ s/^-I//;
                        push @inc_dirs, $flag;
                    }
                    else {
                        push @flags, $flag;
                    }
                }
                # If pkg-config got the cflags, we can assume libs will work too
                push(@libs, split(' ', `pkg-config --libs $pcfile`));
            }
            else {
                print "$pcfile not found. Skipping build of $modname\n";
                return;
            }

            push @libs, @{$MODULES{$modname}{libs}};
            if ($modname ne 'qtcore') {
                push @libs, File::Spec->catdir(Cwd::cwd(), qw(blib arch auto QtCore4 QtCore4.so));
                #push @libs, '/usr/lib/perl5/site_perl/5.10.0/i686-linux-thread-multi/auto/QtCore4/QtCore4.so';
                $self->depends_on('qtcore');
            }

            my $p = $self->{properties};
            local $p->{include_dirs} = [
                'qtcore/src',
                "$modname/src",
                @inc_dirs,
            ];
            local $p->{extra_compiler_flags} = [
                @{$self->extra_compiler_flags},
                @flags
            ];
            local $p->{extra_linker_flags} = [
                @{$self->extra_linker_flags},
                @libs,
            ];

            my @objects;
            # XXX this is stupid, I shouldn't have to delete this from the cache
            delete $self->{properties}{"xs_files"};
            %ExtUtils::ParseXS::IncludedFiles = ();
            @ExtUtils::ParseXS::InitFileCode = ();
            @ExtUtils::ParseXS::BootCode = ();

            my $files = $self->_find_file_by_type('xs',  "$modname/src");
            my @xsfiles;

            $DB::single=1;
            foreach my $file (keys %$files) {
                (my $outfile = $file) =~ s/\.xs$/.c/;
                push @xsfiles, $outfile;
                $self->process_xs($file);
            }
            $files = $self->_find_file_by_type('cpp',  "$modname/src");
            @{$files}{@xsfiles} = 1;
            foreach my $file (keys %$files) {
                push(@objects, $self->compile_c($file));
            }
            #print STDERR join "\n", '######', @objects, '#######', '';

            my $lib_dir = File::Spec->catdir($self->blib, 'arch', 'auto', $MODULES{$modname}{sofile});
            File::Path::mkpath( $lib_dir );

            my $sofile = File::Spec->catfile($lib_dir, $MODULES{$modname}{sofile} . '.so');

            unless($self->up_to_date(\@objects, [$sofile])) {
                $self->_cbuilder->link(
                    lib_file => $sofile,
                    objects => \@objects,
                    extra_linker_flags => $p->{extra_linker_flags},
                );
            }

            $files = $self->_find_file_by_type('pm', "$modname/lib");
            while (my ($file, $dest) = each %$files) {
                my @dirparts = File::Spec->splitdir($dest);
                $dest = File::Spec->catdir(@dirparts[1..$#dirparts]);
                $self->copy_if_modified(from => $file, to => File::Spec->catfile($self->blib, $dest));
            }
        }
    }
}

sub ACTION_code {
    my $self = shift;

    $self->depends_on('qtcore');
    foreach my $modname ( sort keys %MODULES ) {
        next if $modname eq 'qtcore';
        $self->depends_on($modname);
    }
    $self->depends_on('puic');
}

sub ACTION_puic {
    my $self = shift;

    my $p = $self->{properties};
    local $p->{extra_compiler_flags} = [
        @{$self->extra_compiler_flags},
        '-Iqtcore/tools/puic',
        '-Iqtcore/tools/puic/perl',
    ];
    my @objects;
    my $files = $self->_find_file_by_type('cpp',  'qtcore/tools/puic');
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
