require 'thor'
require_relative 'program'

module KwejkDownloader
  class Cli < Thor
    desc 'start DEST_DIR', 'start downloading'
    def start(dest_dir)
      prog = Program.new out_dir: dest_dir
      prog.start
    end
  end
end
