package HackerzLab::DB::Teng::Row::Staff;
use Mojo::Base 'Teng::Row';

=encoding utf8

=head1 NAME

HackerzLab::DB::Teng::Row::Staff - Teng Row オブジェクト拡張 (staff)

=cut

# 呼び出しテスト
sub welcome {
    my $self = shift;
    return 'welcome HackerzLab::DB::Teng::Row::Staff!!';
}

sub fetch_address {
    my $self = shift;
    return $self->handle->single( 'address',
        +{ staff_id => $self->id, deleted => 0, },
    );
}

1;

__END__

