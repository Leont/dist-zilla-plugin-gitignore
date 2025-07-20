package Dist::Zilla::Plugin::Changes;

use Moose;
with qw/Dist::Zilla::Role::FileGatherer/;
use MooseX::Types::Moose qw/Str Int/;

use experimental 'signatures';

use namespace::autoclean;

has filename => (
	is      => 'ro',
	isa     => Str,
	default => 'Changes',
);

has initial => (
	is        => 'ro',
	isa       => Str,
	predicate => 'has_initial',
);

has indent => (
	is        => 'ro',
	isa       => Int,
	default   => 10,   # [NextRelease]
);

sub gather_files($self) {
	my $header = "Revision history for " . $self->zilla->name;
	my @lines = ($header, '', '{{$NEXT}}');

	if ($self->has_initial) {
		my $indent = ' ' x $self->indent;
		push @lines, $indent . $self->initial
	}

	my $payload = join '', map { "$_\n" } @lines;
	$self->add_file(Dist::Zilla::File::InMemory->new(
		name    => $self->filename,
		content => $payload,
	));

	return;
}

1;

# ABSTRACT: Create a changes file

=head1 SYNOPSIS

In your profile.ini

 [Changes]

=head1 DESCRIPTION

This is a minting plugin to add a changelog file, meant to be used together with L<NextRelease|https://metacpan.org/pod/Dist::Zilla::Plugin::NextRelease>.

=attr filename

This sets the filename of the changelog. It defaults to C<Changes>.

=attr initial

This is default entry for the initial version. This could be something like C<Initial release>. If not set, no such line is added.

=attr indent

This is the indentation used for the initial line, it defaults to C<10>, to match the default indentation of C<NextRelease>. This should only be changed if you override the C<format> argument to C<NextRelease>.
