package HackerzLab::DB::Teng::Row::Staff;
use Mojo::Base 'Teng::Row';
use HackerzLab::DB::Master;

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

sub authority_master {
    my $self = shift;
    my $master = HackerzLab::DB::Master->new( +{ id => $self->authority } );
    return $master->authority;
}

sub insert_staff_with_address {
    my $self   = shift;
    my $params = shift;

    die 'not staff, address row'
        if !$params->{staff_row} || !$params->{address_row};

    # staff テーブル書き込み
    $params->{address_row}->{staff_id}
        = $self->handle->fast_insert( 'staff', $params->{staff_row} );

    # address テーブル書き込み
    my $address_id
        = $self->handle->fast_insert( 'address', $params->{address_row} );

    my $create_ids = +{
        staff_id   => $params->{address_row}->{staff_id},
        address_id => $address_id,
    };
    return $create_ids;
}

sub soft_delete {
    my $self = shift;

    my $master      = HackerzLab::DB::Master->new();
    my $NOT_DELETED = $master->label('NOT_DELETED')->deleted->constant;
    my $DELETED     = $master->label('DELETED')->deleted->constant;

    # 関連するテーブルも削除
    $self->update( +{ deleted => $DELETED } );
    my @address_rows
        = $self->handle->search( 'address', +{ staff_id => $self->id, } );
    for my $row (@address_rows) {
        $row->update( +{ deleted => $DELETED } );
    }
    return;
}

1;

__END__

