use Test::More qw( no_plan );

use strict;
use File::ERC;
use File::ANVL;

{	# ERC tests

my @x = num2dk("c1", "h3", "2", "dummy");
is 4, scalar(@x), 'num2dk with 4 args returns 4 values';

is $x[0], 'ERC', 'num2dk c1 return';

is $x[1], 'when', 'num2dk h3 return';

is $x[2], 'what', 'num2dk pure numeric return';

is $x[3], '', 'num2dk with empty return for unknown code';

my $m = anvl_valsplit("foo", "dummy");
like $m, qr/array/, 'valsplit message about 2nd arg referencing an array';

my (@elems, @svals);
#print "before svals=", \@svals, "\n";
$m = anvl_valsplit("ab;cd;ef|foo;bar||;;zaf", \@svals);
#print "after svals=", \@svals, "\n";

is scalar(@svals), 4, 'anvl_valsplit into 4 subvalues';

is scalar(@{$svals[0]}), 3, '1st subvalue cardinality correct';

is scalar(@{$svals[1]}), 2, '2nd subvalue cardinality correct';

is scalar(@{$svals[2]}), 0, '3rd subvalue cardinality correct';

is scalar(@{$svals[3]}), 3, '4th subvalue cardinality correct';

my $r = "erc: Gibbon, Edward | "
	. "The Decline and Fall of the Roman Empire | 1781 | "
	. "http://www.ccel.org/g/gibbon/decline/";
$m = anvl_recsplit($r, \@elems);
is scalar(@elems), 2, 'correct elem count for shortest record form';
#print "rsplit=", join(", ", @elems), "\n";

$m = erc_anvl_longer($r);
like $m, qr/who:/, 'simple anvl_erc_longer';

my $m2 = erc_anvl_longer($m);
is $m2, $m, 'erc_anvl_longer idempotence test (re-run against result)';

$r = "name1;name2;name3|title;subtitle|date|where|vellum|because|a|b|c";
$m2 = anvl_valsplit($r, \@svals);

is scalar(@svals), 9, 'short form with 9 elements/subvalues';

is scalar(@{$svals[0]}), 3, '1st subvalue cardinality correct';

is scalar(@{$svals[1]}), 2, '2nd subvalue cardinality correct';

is scalar(@{$svals[2]}), 1, '3rd subvalue cardinality correct';

is scalar(@{$svals[3]}), 1, '4th subvalue cardinality correct';

$m = anvl_rechash("foo", "dummy");
like $m, qr/hash/, 'rechash message about 2nd arg referencing a hash';

my %rhash;
$m = anvl_rechash("foo: bar", \%rhash);
is $rhash{foo}, 'bar', 'simple one-element record hash';

$m = erc_anvl2erc_turtle("foo: bar");
like $m, qr/ERC.ANVL/, 'turtle conversion abort, not an erc';

my $turtle_rec;
$m = erc_anvl2erc_turtle("erc: bar");
like $m, qr/string/, 'turtle conversion abort, no return string';

$m = erc_anvl2erc_turtle("erc: $r", $turtle_rec);
print "erc: $r\n";
print "$turtle_rec\n";
like $turtle_rec, qr/erc:who.*erc:what.*erc:when.*erc:where/s,
	'turtle conversion with 9 reduced to 6 elems';
# xxx is 9 to 6 ok?

}
