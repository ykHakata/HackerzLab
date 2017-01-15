package HackerzLab::Model::Admin::Staff;
use Mojo::Base 'HackerzLab::Model::Base';

=encoding utf8

=head1 NAME

HackerzLab::Model::Admin::Staff - コントローラーモデル (管理機能/管理者ユーザー管理)

=cut

has [qw{hash_ref_staffs}];

# 呼び出しテスト
sub welcome {
    my $self = shift;
    return 'welcome HackerzLab::Model::Admin::Staff!!';
}

# 一覧画面初期表示用 staff 情報
sub get_hash_ref_index_staff {
    my $self = shift;
    my $teng = $self->app->db->teng;
    my ( $rows, $pager ) = $teng->search_with_pager(
        'staff' => +{ delete_flag => 0 },
        +{ page => 1, rows => 5 }
    );
    my $hash_ref = [ map { $_->get_columns } @{$rows} ];
    $self->hash_ref_staffs($hash_ref);
    return $hash_ref;
}

1;

__END__
