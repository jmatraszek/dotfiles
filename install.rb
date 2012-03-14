#!/usr/bin/env ruby

# REQUIREMENTS
# lynx, urlview


require 'fileutils'
include FileUtils

["gitconfig", "muttrc"].each { |file| cp "#{file}.example", file }

["ackrc", "bash_aliases", "bashrc", "gitconfig", "irbrc", "mailcap", "mutt", "muttrc", "tigrc"].each do |file|
  ln_sf file, "~/.#{file}"
end
