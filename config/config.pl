{
	hypnotoad => {
		listen  => ["http://*:".($ENV{PORT}||5000)],
		workers => 10,
		proxy => 1
	}
};
