package Module::InstallDeps;
use Moose;
use Moose::Util::TypeConstraints;

use File::pushd;
use MooseX::Types::Path::Class qw(Dir);
use IPC::Cmd;
use YAML::Tiny; # i can't believe i am using this

with 'MooseX::Getopt';

has 'directory' => (
    is       => 'ro',
    isa      => Dir,
    default  => sub { Path::Class::dir('.')->absolute },
);

has 'cpan' => (
    is      => 'ro',
    isa     => 'ArrayRef[Str]',
    default => sub { ['cpan'] }, # otherwise [qw/cpanp install/]
);

sub BUILD {
    my $self = shift;
    my $cpan = $self->cpan->[0];
    confess "The cpan command '$cpan' cannot be run"
      unless IPC::Cmd::can_run($cpan);

    my $directory = $self->directory;
    confess "$directory does not exist" unless -e $directory && -d _;

}

sub run {
    my ($self) = @_;

    my $cpan = $self->cpan;
    $cpan->[0] = IPC::Cmd::can_run($cpan->[0]);

    my @depends = $self->_extract_depends;
    return unless @depends;

    my $status = scalar IPC::Cmd::run(
        command => [ @$cpan, @depends ],
        verbose => 1,
    );

    return $status;
}

sub _find_meta {
    my ($self) = @_;
    my $directory = $self->directory;
    my $meta = $directory->file('META.yml');
    my $meta_doesnt_exist = sub { $self->_run_makefilepl };
    for(1..2){
        last if -e $meta;
        $meta_doesnt_exist->();
        $meta_doesnt_exist = sub { confess "No META.yml found in $directory, bailing out" };
    }
    return $meta;
}

sub _parse_meta {
    my ($self) = @_;
    my $meta_file = $self->_find_meta;
    return YAML::Tiny->read($meta_file)->[0];
}

sub _extract_depends {
    my ($self) = @_;
    return map {
        my $type = ref $_;
        if($type eq 'ARRAY'){
            @$_;
        }
        elsif($type eq 'HASH'){
            (keys %$_);
        }
        else {
            ();
        }
    } @{$self->_parse_meta || {}}{qw/requires build_requires/};
}


sub _run_makefilepl {
    my ($self) = @_;
    my $makefile_pl = $self->directory->file('Makefile.PL');
    confess 'Cannot find a Makefile.PL' if !-e $makefile_pl;

    my $dh = pushd $self->directory;
    scalar IPC::Cmd::run(
        command => [$, 'Makefile.PL'],
        verbose => 1,
    );

    return;
}

1;

__END__

=head1 NAME

Module::InstallDeps -

