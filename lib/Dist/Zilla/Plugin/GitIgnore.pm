package Dist::Zilla::Plugin::GitIgnore;

use Moose;
with qw/Dist::Zilla::Role::FileGatherer/;
use MooseX::Types::Moose qw/ArrayRef Str/;

use experimental 'signatures';

use namespace::autoclean;

sub mvp_multivalue_args($class) {
	return 'extras';
}

sub mvp_aliases($class) {
	return { extra => 'extras' };
}

has filename => (
	is => 'ro',
	isa => Str,
	default => '.gitignore',
);

has extras => (
	isa     => ArrayRef[Str],
	traits  => ['Array'],
	default => sub { [] },
	handles => {
		extras => 'elements',
	},
);

sub gather_files($self) {
	my $name = $self->zilla->name;
	my @patterns = ('/.build/', "/$name-*/", "/$name-*.tar.gz");
	push @patterns, $self->extras;

	my $payload = join '', map { "$_\n" } @patterns;
	$self->add_file(Dist::Zilla::File::InMemory->new(
		name    => $self->filename,
		content => $payload,
	));

	return;
}

1;

# ABSTRACT: Add .gitignore during minting

=head1 SYNOPSIS

In your profile.ini

 [GitIgnore]
 extra = *.swp

=head1 DESCRIPTION

This is a minting plugin to add a C<.gitignore> file. By default it ignores only two things that L<Dist::Zilla> itself generates: the F<.build/> directory, and any directory or C<.tar.gz> file starting with C<"$dist_name-"> (e.g. the tarball that C<Dist::Zilla> produces). More patterns can be added using the C<extra> argument.

=attr extras

This is the list of extra patterns for the gitignore file.

=attr filename

This sets the filename. It defaults to F<.gitignore> and probably shouldn't be changed.
