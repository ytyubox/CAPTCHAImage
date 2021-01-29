
init:
	git config core.hooksPath .githooks

scan:
	periphery scan --retain-public --retain-unused-protocol-func-params

testiPhone:
	 xcodebuild -scheme CAPTCHAImage test -sdk iphonesimulator \
	-destination 'platform=iOS Simulator,name=iPhone 11' \
	-destination 'platform=iOS Simulator,name=iPhone 11 Pro' \
	-destination 'platform=iOS Simulator,name=iPhone 11 Pro Max'  \
	-destination 'platform=iOS Simulator,name=iPhone 12'
