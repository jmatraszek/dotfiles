#!/usr/bin/env ruby

# REQUIREMENTS
# lynx, urlview


require 'fileutils'
include FileUtils

["gitconfig", "muttrc"].each { |file| cp "#{file}.example", file }

["ackrc", "bash_aliases", "bashrc", "gitconfig", "irbrc", "irssi", "mailcap", "mutt", "muttrc", "tigrc", "tmux.conf"].each do |file|
  ln_sf file, "~/.#{file}"
end
