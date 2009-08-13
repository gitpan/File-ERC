package File::ERC;

use 5.000000;
use strict;
use warnings;

our $VERSION;
$VERSION = sprintf "%d.%02d", q$Name: Release-0-01 $ =~ /Release-(\d+)-(\d+)/;

require Exporter;
our @ISA = qw(Exporter);

our @EXPORT = qw(
	erc_anvl_longer erc_anvl2erc_turtle num2dk
);
our @EXPORT_OK = qw(
);

use File::ANVL;

# ordered list of kernel element names
our @kernel_labels = qw(
	who
	what
	when
	where
	how
	why
);

# Convert ERC/ANVL to long, explicitly tagged form
# Harmless when applied to ERC/ANVL that is already in long form.
#
sub erc_anvl_longer { my( $erc )=@_;

	my (@elems, @svals, $msg, $name, $value);
	($msg = anvl_recsplit($erc, \@elems)) and
		return "error: anvl_recsplit: $msg";
	while (1) {
		$name = shift @elems;
		$value = shift @elems;
		return ""	unless defined $name; 	# nothing found
		last		if $name eq "erc";
	}
	# If we get an erc with no value, then the erc is already in long
	# form (maybe empty), so we just return it (for idempotence).
	#
	$value =~ /^\s*$/ and		# for valueless "erc" element
		return $erc;		# return the whole "erc" record

	($msg = anvl_valsplit($value, \@svals)) and
		return "error: anvl_valsplit: $msg";

	my $longer = anvl_fmt("erc");		# initialize
	foreach my $label (@kernel_labels) {
		my $sval = shift @svals;
		last		unless defined $sval;
		$longer .= anvl_fmt($label, join("; ", @$sval));
	}
	#foreach  xxxx get final et al.
	#scalar(@$r_vals) and
	#	$longer .= anvl_fmt("etal", join("; ", @$
	return $longer . "\n";;
}

# returns empty string on success, or message on error
# returns string result via 2nd arg, which should be a string
sub erc_anvl2erc_turtle { my( $erc, $rec )=@_;

	! defined($erc) || $erc !~ /^erc.*:/ and
		return "needs an ERC/ANVL record";
	scalar(@_) < 2 || ref($rec) ne "" and
		return "2nd arg should be string to receive converted record";
	my $r_rec = \$_[1];	# create better name for return string

	$erc = erc_anvl_longer($erc)		# canonicalize if needed
		if $erc =~ /^erc.*:\s*(\n\s+)*\S/;

	my ($msg, %rhash);
	($msg = anvl_rechash($erc, \%rhash)) and
		return $msg;

	# start turtle record
	#
	my $this = $rhash{where} || "";
	$$r_rec =
		"\@prefix erc: <http://purl.org/kernel/elements/1.1/>\n" .
		"\@prefix this: <$this>\n";

	# Loop through list of kernel terms and print what's there.
	my $first = "this: ";
	for (@kernel_labels) {
		defined $rhash{$_} and
			$$r_rec .= ($first ? $first : "      ") . "erc:$_ " .
				'"""' . $rhash{$_} . '"""' . ";\n",
			$first &&= "";		# erase first time through
	}
	return $msg;
}

# @prefix erc: <http://purl.org/kernel/elements/1.1/>.
# @prefix this: <http://www.ccel.org/g/gibbon/decline/>.
# this: erc:who "Gibbon, Edward";
#       erc:what "The Decline and Fall of the Roman Empire";
#       erc:when "1781";
#       erc:where "http://www.ccel.org/g/gibbon/decline/".

my %erc_terms = (
	'h10'	=> 'about-erc',
	'h12'	=> 'about-what',
	'h13'	=> 'about-when',
	'h14'	=> 'about-where',
	'h11'	=> 'about-who',
	'h15'	=> 'about-how',
	'h506'	=> 'contributor',
	'h514'	=> 'coverage',
	'h502'	=> 'creator',
	'h507'	=> 'date',
	'h504'	=> 'description',
	'c1'	=> 'ERC',
	'h0'	=> 'erc',		# eek, collision with next XXXX
	'h0'	=> 'dir_type',
	'v1'	=> ':etal',
	'h509'	=> 'format',
	'c2'	=> 'four h\'s',
	'h510'	=> 'identifier',
	'h602'	=> 'in',
	'h5'	=> 'how',
	'h512'	=> 'language',
	'c3'	=> 'metadata',
	'h30'	=> 'meta-erc',
	'h32'	=> 'meta-what',
	'h33'	=> 'meta-when',
	'h34'	=> 'meta-where',
	'h31'	=> 'meta-who',
	'v2'	=> ':none',
	'h601'	=> 'note',
	'v3'	=> ':null',
	'c4'	=> 'object',
	'h505'	=> 'publisher',
	'c5'	=> 'resource',
	'h513'	=> 'relation',
	'h515'	=> 'rights',
	'h511'	=> 'source',
	'h503'	=> 'subject',
	'h20'	=> 'support-erc',
	'h22'	=> 'support-what',
	'h23'	=> 'support-when',
	'h24'	=> 'support-where',
	'h21'	=> 'support-who',
	'c6'	=> 'stub ERC',
	'v4'	=> ':tba',
	'h501'	=> 'title',
	'h508'	=> 'type',
	'v5'	=> ':unac',
	'v6'	=> ':unal',
	'v7'	=> ':unap',
	'v8'	=> ':unas',
	'v9'	=> ':unav',
	'v10'	=> ':unkn',
	'h2'	=> 'what',
	'h3'	=> 'when',
	'h4'	=> 'where',
	'h1'	=> 'who',
);

# Returns an array of terms corresponding to args given as coded
# synonyms for Dublin Kernel elements, eg, num2dk('h1') -> 'who'.
#
sub num2dk {

	my (@ret, $code);

	for (@_) {
		# Assume an 'h' in front if it starts with a digit.
		#
		($code = $_) =~ s/^(\d)/h$1/;

		# Return a defined hash value or the empty string..
		#
		push @ret, defined($erc_terms{$code}) ?
			$erc_terms{$code} : "";
	}
	return @ret;
}

#my %kernel = (
#	0	=>  'dir_type',
#	1	=>  'who',
#	2	=>  'what',
#	3	=>  'when',
#	4	=>  'where',
#);

##XXX need this any more?
#sub num2dk { my( $number )=@_;
#
#	return $kernel{$number}
#		if (exists($kernel{$number})
#			&& defined($kernel{$number}));
#	return $number;
#}

__END__

=head1 NAME

File::ERC - routines to support Electronic Resource Citations, version 0.01

=head1 SYNOPSIS

 use File::ERC;           # to import routines into a Perl script

 erc_anvl_longer(         # given short form ERC in ANVL, return the
         $erc );          # long, explicitly tagged (canonical) form;
	                  # harmless if $erc already in canonical form

 erc_anvl2erc_turtle(     # convert ERC/ANVL to ERC/Turtle, returning
         $erc,            # empty string on success, message on erro
         $rec );          # returned Turtle record

 num2dk(                  # return array of terms corresponding to args
         $num, ... );     # given as coded synonyms for Dublin Kernel
	                  # elements, eg, num2dk('h1') -> 'who'; `h' is
			  # assumed in front of arg that is pure digits

=head1 DESCRIPTION

This is stub documentation for the B<ERC> Perl module, with
support for representing metadata in an ERC record using a
variety of underlying syntaxes, initially the ANVL format.

ERCs (Electronic Resource Citations) utilize the Dublin Kernel
metadata elements:  who, what, when, and where.

ANVL (A Name Value Language) is label-colon-value format similar
to email headers.

=head1 SEE ALSO

A Metadata Kernel for Electronic Permanence (PDF)
	L<http://journals.tdl.org/jodi/article/view/43>

A Name Value Language (ANVL)
	L<http://www.cdlib.org/inside/diglib/ark/anvlspec.pdf>

=head1 HISTORY

This is an alpha version of ERC tools.  It is written in Perl.

=head1 AUTHOR

John A. Kunze I<jak at ucop dot edu>

=head1 COPYRIGHT AND LICENSE

Copyright 2009 UC Regents.  Open source Apache License, Version 2.

=head1 PREREQUISITES

Script Categories:

=pod SCRIPT CATEGORIES

UNIX : System_administration

=cut
