use inc::Module::Install;

name 'Module-InstallDeps';
all_from 'lib/Module/InstallDeps.pm';

requires 'File::pushd';
requires 'IPC::Cmd';
requires 'Moose';
requires 'MooseX::Getopt';
requires 'MooseX::Types::Path::Class';
requires 'YAML::Tiny';
build_requires 'Test::More';
build_requires 'ok';

install_script('bin/installdeps');

WriteAll();
