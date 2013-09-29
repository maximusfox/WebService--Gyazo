package WebService::Gyazo::Image;

# Packages
use strict;
use warnings;

sub new {
	my $self = shift;
	my %args = @_;
	$self = bless(\%args, $self);
	
	return $self;
}

sub getSiteUrl {
	my ($self) = @_;

	unless (defined $self->{id} and $self->{id} =~ m#^\w+$#) {
		$self->{id} = 'Wrong image id!';
		return 0;
	}

	return 'http://gyazo.com/'.$self->{id};
}

sub getImageUrl {
	my ($self) = @_;

	unless (defined $self->{id} and $self->{id} =~ m#^\w+$#) {
		$self->{id} = 'Wrong image id!';
		return 0;
	}

	return 'http://gyazo.com/'.$self->{id}.'.png';
}

sub getImageId {
	my ($self) = @_;
	return $self->{id};
}

1;