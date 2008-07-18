use inc::Module::Install;

name 'Module-InstallDeps';
all_from 'lib/Module/InstallDeps.pm';

build_requires 'Test::More';
build_requires 'ok';

WriteAll();
