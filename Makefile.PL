use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'File::ERC',
    AUTHOR              => 'John A. Kunze <jak@ucop.edu>',
    VERSION_FROM        => 'VERSION',
    ABSTRACT_FROM       => 'lib/File/ERC.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'Apache2')
      : ()),
    PM			=> {
    	'lib/File/ERC.pm' => 'blib/lib/File/ERC.pm',
    },
    PL_FILES            => {},
    PREREQ_PM => {
	'File::ANVL'	=> 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'File-ERC-*' },
);
