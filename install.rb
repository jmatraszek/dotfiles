#!/usr/bin/env ruby

# REQUIREMENTS
# lynx, urlview


require 'fileutils'
include FileUtils

["gitconfig"].each { |file| cp "#{file}.example", file }

["ackrc", "bash_aliases", "bashrc", "gitconfig", "irbrc", "irssi", "mailcap", "mutt", "muttrc", "tigrc", "tmux.conf"].each do |file|
  ln_s("~/.dotfiles/#{file}", "~/.#{file}", :force => true)
end
