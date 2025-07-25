package Dist::Zilla::Plugin::GitIgnore;

use Moose;
with qw/Dist::Zilla::Role::FileGatherer/;
use MooseX::Types::Moose qw/ArrayRef Str Bool/;

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

has skip_gitignore_override => (
	is      => 'ro',
	isa     => Bool,
	default => !!0,
);

has skip_defaults => (
	is      => 'ro',
	isa     => Bool,
	default => !!0,
);

sub gather_files($self) {
	my @patterns;
	if (not $self->skip_defaults) {
		my $name = $self->zilla->name;
		push @patterns, '/.build/', "/$name-*/", "/$name-*.tar.gz";
	}
	push @patterns, '!/.gitignore' if not $self->skip_gitignore_override;

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

This is a minting plugin to add a C<.gitignore> file. By default it ignores only two things that L<Dist::Zilla> itself generates: the F<.build/> directory, and any directory or C<.tar.gz> file starting with C<"$dist_name-"> (e.g. the tarball that C<Dist::Zilla> produces). More patterns can be added using the C<extra> argument. It will also add an override to never ignore the C<.gitignore> file itself (in case users have such a configuration).

=attr extras

This is the list of extra patterns for the gitignore file.

=attr filename

This sets the filename. It defaults to F<.gitignore> and probably shouldn't be changed.

=attr skip_defaults

If enabled, it won't add any default patterns. This is disabled by default.

=attr skip_gitignore_override

If enabled, it won't add skip the .gitignore override to the patterns. You're probably better off leaving it as it is.
