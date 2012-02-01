#!/usr/bin/env ruby

require 'fileutils'
include FileUtils

["gitconfig", "muttrc"].each { |file| cp "#{file}.example", file }

["ackrc", "bash_aliases", "bashrc", "gitconfig", "irbrc", "mutt", "muttrc", "tigrc"].each do |file|
  ln_sf file, "~/.#{file}"
end
