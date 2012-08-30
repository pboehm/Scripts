#!/usr/bin/env ruby
# encoding: UTF-8
#
# Script, welches nach eingehängten Festplatten Ausschau hält
# und einen Serienindex anlegt, Backup durchführt und dann aushängt
#
# Cmdline-Options
#   --no-umount       skip the unmounting of drives
#   --force-backup    does a backup although an backup is already made today
#
# Autor: Philipp Böhm

require 'date'

class Umount

  BASE_MOUNTPOINT="/run/media/philipp"
  SERIES_INDEX_DIR="/home/philipp/.serienindexer/.index"
  LAST_BACKUP_FLAG_FILE="/tmp/.date_of_last_backup"

  # Public: returns information about mounted drives
  def get_devices
    devices = Hash.new

    File.read("/proc/mounts").each_line do |line|
      next unless line.match(/#{BASE_MOUNTPOINT}/)
        device, mountpoint = line.split(/ /)
      next unless File.directory? mountpoint

      basename = File.basename(mountpoint)

      # check for info file
      infofile = File.join(mountpoint, ".umount_info")
      next unless File.file? infofile

      # extract information from this file
      mount = { :mountpoint => mountpoint, :basename => basename }

      File.read(infofile).each_line do |entry|
        next if entry.match(/^\#/)
          next unless entry.match(/\w+=\w+/)

        key, value = entry.strip.split(/=/)
        mount[key.downcase.to_sym] = value
      end

      devices[device] = mount
    end
    devices
  end

  # Public: creates a series index
  def create_series_index(mountpoint, info)
    puts "Erstelle Serien-Index"

    series_dir = File.join(mountpoint, info[:seriesdir])
    return nil unless File.directory? series_dir

    index_file = File.join(SERIES_INDEX_DIR, "#{info[:basename]}.xml")

    cmd = "createserienindex --path=#{series_dir} --index=#{index_file}"

    system(cmd) or fail "Konnte Serienindex nicht erstellen"
  end

  # Public: makes a backup on this drive
  def make_backup(mountpoint, info)
    puts "Führe das Backup durch"

    cmdline = "backup perform --trigger=%s --config-file=~/.backup/config.rb"

    if info[:basename].match(/-fap/)
      system(cmdline % "backup_hdd_fap") or
      fail "Konnte Backup nicht erstellen"
    elsif info[:basename].match(/-tos/)
      system(cmdline % "backup_hdd_tos") or
      fail "Konnte Backup nicht erstellen"
    end
  end

  # Public: umount this drive
  def umount(mountpoint)
    puts "Hänge Drive aus"
    system("umount #{mountpoint}") or fail "Konnte Drive nicht aushängen"
  end

  # Public: starts processing the mounted drives
  def process

    # determine if we should to a backup (once a day)
    make_backup=true
    if File.file? LAST_BACKUP_FLAG_FILE
      last_date = Date.parse(File.read(LAST_BACKUP_FLAG_FILE))

      unless last_date < Date.today
        make_backup=false
      end
    end
    File.open(LAST_BACKUP_FLAG_FILE, 'w') {|f| f.write(Date.today) }
    (make_backup=true) if ARGV.include?('--force-backup')

    # process available drives
    devices = self.get_devices || Hash.new
    fail "Keine Drives gemountet" unless devices.size > 0

    devices.each do |key,value|
      puts "Verarbeite '%s'" % value[:productname]

      self.create_series_index(value[:mountpoint], value) if
      value[:hasseries].match(/true/i)

      self.make_backup(value[:mountpoint], value) if
      ( value[:enablebackup].match(/true/i) && make_backup )

      self.umount(value[:mountpoint]) unless ARGV.include?('--no-umount')

      puts
    end
  end
end

umount = Umount.new
umount.process()
