bundle:
	bundle install --path vendor/bundle

lint:
	bundle exec rubocop ./lib -c .rubocop.yml -R -a

test:
	bundle exec rspec

pre_commit:
	lint
	test
