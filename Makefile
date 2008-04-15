TMPDMG=/tmp/urbantakeover
DMG_NAME=public/files/Urban\ Takeover.dmg

dmg: dmg-clean
	# Prep our disk image source directory
	mkdir -p $(TMPDMG)
	cp -r resources/Urban\ Takeover.app $(TMPDMG)
	# ln -s /Applications/ $(TMPDMG)/Applications
	# Here's where we'll make the dmg
	hdiutil create -srcfolder $(TMPDMG) $(DMG_NAME)

dmg-clean:
	rm -rf $(TMPDMG)
	rm -rf $(DMG_NAME)

deploy:
	ssh consti@urbantakeover.at "cd urbantakeover;./update"