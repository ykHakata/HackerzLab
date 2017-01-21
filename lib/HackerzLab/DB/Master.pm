package HackerzLab::DB::Master;
use Mojo::Base 'HackerzLab::DB::Base';
use Mojo::Util qw{dumper};

=encoding utf8

=head1 NAME

HackerzLab::DB::Master - マスターデータオブジェクト

=head1 SYNOPSIS

    # コントローラーにて
    my $master = $self->db->master;

    # モデルにて
    my $master = $self->app->db->master;

    # 5
    my $authority_id = $master->id($id)->authority->get_id;

    # guest
    my $authority_name = $master->id($id)->authority->get_name;

    # +{ 5 => 'guest' }
    my $authority_pointing_hash_ref = $master->id($id)->authority->to_hash;

    # [ 0 ,1, 2, 3, 4, 5 ]
    my $authority_ids = $master->authority->to_ids;

    # +{  0 => '権限なし',
    #     1 => 'root',
    #     2 => 'sudo',
    #     3 => 'admin',
    #     4 => 'general',
    #     5 => 'guest',
    # };
    my $authority_hash_ref = $master->authority->to_hash;

    # 変換したい場合 (定数を求める)

    # 5
    my $authority_const_id = $master->constant('GUEST')->authority->get_id;

    # row オブジェクトの場合
    my $admin_staff = $self->model->admin->staff;
    $admin_staff->create($params);
    my $staff_row = $admin_staff->search_staff_show->staff_row;

    # 5
    $staff_row->authority_master->get_id;

    # guest
    $staff_row->authority_master->get_name;

    # [ 0 ,1, 2, 3, 4, 5 ]
    $staff_row->authority_master->to_ids;

    # +{  0 => '権限なし',
    #     ... 省略
    # };
    $staff_row->authority_master->to_hash;

=cut

has [qw{id constant master_hash master_constant_hash}];

# 呼び出しテスト
sub welcome {
    my $self = shift;
    return 'welcome HackerzLab::DB::Master!!';
}

# authority 管理者権限
sub authority {
    my $self = shift;
    my $hash = +{
        0 => '権限なし',
        1 => 'root',
        2 => 'sudo',
        3 => 'admin',
        4 => 'general',
        5 => 'guest',
    };

    my $constant = +{
        NOT_AUTHORITY => 0,
        ROOT          => 1,
        SUDO          => 2,
        ADMIN         => 3,
        GENERAL       => 4,
        GUEST         => 5,
    };

    $self->master_hash($hash);
    $self->master_constant_hash($constant);
    return $self;
}

# deleted 削除フラグ
sub deleted {
    my $self = shift;
    my $hash = +{
        0 => '削除していない',
        1 => '削除済み',
    };

    my $constant = +{
        NOT_DELETED => 0,
        DELETED     => 1,
    };

    $self->master_hash($hash);
    $self->master_constant_hash($constant);
    return $self;
}

sub get_id {
    my $self = shift;

    my $id;
    if ( $self->constant ) {
        $id = $self->master_constant_hash->{ $self->constant };
        die 'error master methode get_id: ' if !defined $id;
        return $id;
    }
    $id = $self->id;
    die 'error master methode get_id: ' if !defined $id;
    return $id;
}

sub get_name {
    my $self = shift;
    my $name = $self->master_hash->{ $self->id };
    die 'error master methode get_name: ' if !defined $name;
    return $name;
}

sub to_hash {
    my $self = shift;
    my $hash = $self->master_hash;
    my @keys = keys %{$hash};
    die 'error master methode to_hash: ' if !scalar @keys;
    return +{ $self->id => $self->master_hash->{ $self->id }, }
        if defined $self->id;
    return $hash;
}

sub to_ids {
    my $self = shift;
    my $hash = $self->master_hash;
    my @keys = keys %{$hash};
    die 'error master methode to_ids: ' if !scalar @keys;
    my @sort_keys = sort { $a <=> $b } @keys;
    return \@sort_keys;
}

1;

__END__
