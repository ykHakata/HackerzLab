package HackerzLab::Model::Admin::Staff;
use Mojo::Base 'HackerzLab::Model::Base';

=encoding utf8

=head1 NAME

HackerzLab::Model::Admin::Staff - コントローラーモデル (管理機能/管理者ユーザー管理)

=cut

# 呼び出しテスト
sub welcome {
    my $self = shift;
    return 'welcome HackerzLab::Model::Admin::Staff!!';
}

sub staff_all_rows {
    my $self = shift;
    my @rows = $self->app->db->teng->search( 'staff', +{} );
    return \@rows;
}

1;

__END__
