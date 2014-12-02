#!/usr/bin/env ruby

require 'pathname'
require 'tempfile'
require 'optparse'
require 'logger'

module Logging

  def initialize(logging_level)
    @logger = Logger.new(STDOUT)
    @logger.level = logging_level
  end

  # This is the magical bit that gets mixed into your classes
  def logger
    @logger
  end
end

class Dupes
  include Logging

  def process_fdupes_list(io)
    dupes = Array.new
    io.each_line do |line|
      if line.strip.empty?
        handle_dupes(dupes)
        dupes.clear
      else
        dupes << Pathname.new(line.strip)
      end
    end
  end

  private

  def handle_dupes(dupes)
    if (dupes.size > 1)
      link_all(dupes.first, dupes.drop(1))
    end
  end

  def link_all(destination, files)
    logger.info("Linking #{files.size} files to #{destination}: #{files.map { |e| e.to_s }}")

    if !destination.file?
      logger.warn 'Expected #{destination} to be a file'
      return
    end

    files.each do |f|
      if !f.file?
        logger.warn 'Expected #{f} to be a file'
        next
      end

      tmp = f.dirname + ".dup_#{f.basename.to_s}"
      
      if tmp.exist?
        logger.warn "Cannot rename #{f} to temp file #{tmp}. Destination exists."
        next
      end

      begin
        f.rename(tmp)
      rescue Exception => e
        logger.warn "Skipping #{f}, because renaming to #{tmp} failed: #{e}"
        next
      end

      begin
        logger.debug "Linking: #{f} -> #{destination}"
        f.make_link(destination)
      rescue Exception => e
        logger.fatal "Failed to create link. Renaming #{tmp} to #{f}: #{e}"
        tmp.rename(f) or logger.warn "Renaming #{tmp} to #{f} failed"
      else
        if tmp.exist?
          tmp.unlink or logger.warn "Failed to delete #{tmp}"
        end
      end
    end
  end
end

options = {}
dupes_source = nil

OptionParser.new do |opts|

  options[:debug] = false
  opts.on("-d", "--[no-]debug", "Run with debug messages") do |v|
    options[:debug] = v
  end

  # parse options
  begin
    opts.parse!
  rescue OptionParser::ParseError => error
    puts "Error: " << error.message
    puts opts
    exit 1
  end

  # parse config
  if ARGV.empty?
    dupes_source = STDIN
  else
    dupes_source = Pathname.new(ARGV.join)
  end
end

logging_level = if options[:debug]
  Logger::DEBUG
else
  Logger::INFO
end

Dupes.new(logging_level).process_fdupes_list(dupes_source)
