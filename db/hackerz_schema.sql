DROP TABLE IF EXISTS staff;
CREATE TABLE staff (                                    -- 管理ユーザー
    id              INTEGER PRIMARY KEY AUTOINCREMENT,  -- ID (例: 5)
    login_id        TEXT,                               -- ログインID名 (例: 'hackerz.lab.system@gmail.com')
    password        TEXT,                               -- ログインパスワード (例: 'hackerz')
    authority       INTEGER,                            -- 管理者権限 (例: 0: 権限なし, 1: root, 2: sudo, 3: admin, 4: general, 5: guest)
    deleted         INTEGER,                            -- 削除フラグ (例: 0: 削除していない, 1: 削除済み)
    create_ts       TEXT,                               -- 登録日時 (例: '2016-01-08 12:24:12')
    modify_ts       TEXT                                -- 修正日時 (例: '2016-01-08 12:24:12')
);
DROP TABLE IF EXISTS address;
CREATE TABLE address (                                  -- 住所
    id              INTEGER PRIMARY KEY AUTOINCREMENT,  -- ID (例: 5)
    staff_id        INTEGER,                            -- 管理ユーザーID (例: 5)
    name            TEXT,                               -- 名前 (例: '松野 おそ松')
    rubi            TEXT,                               -- ふりがな (例: 'まつの おそまつ')
    nickname        TEXT,                               -- ニックネーム (例: 'おそまつ')
    email           TEXT,                               -- Eメール (例: 'hackerz.lab.osomatu@gmail.com')
    deleted         INTEGER,                            -- 削除フラグ (例: 0: 削除していない, 1: 削除済み)
    create_ts       TEXT,                               -- 登録日時 (例: '2016-01-08 12:24:12')
    modify_ts       TEXT                                -- 修正日時 (例: '2016-01-08 12:24:12')
);

