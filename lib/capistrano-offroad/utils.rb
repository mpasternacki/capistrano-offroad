# Small extensions to Capistrano

require 'capistrano'

# depend :remote, :run, "whole command with args"
# runs command, if return code <> 0, dependency fails.
class Capistrano::Deploy::RemoteDependency
  def run(command, options={})
    @message ||= "Cannot run `#{command}'"
    try(command, options)
    self
  end
end

class Capistrano::Configuration
  # set_from_env_or_ask :variable, "Please enter variable name: "
  # If there is VARIABLE in enviroment, set :variable to it, otherwise
  # ask user for a value
  def set_from_env_or_ask(sym, question)
    if ENV.has_key? sym.to_s.upcase then
      set sym, ENV[sym.to_s.upcase]
    else
      set sym do Capistrano::CLI.ui.ask question end
    end
  end

  def warn(short, long=nil)
    @_offroad_util_warnings ||= []
    @_offroad_util_warnings.push short
    puts <<EOF

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                           BIG FAT WARNING:
EOF
    puts short
    puts long if long
puts <<EOF
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

EOF
  end

  def _offroad_emit_warnings()
    if @_offroad_util_warnings
      puts <<-"EOF"

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

                         #{@_offroad_util_warnings.length} WARNING(S) LOGGED
        READ VERY CAREFULLY, FOR I SHALL WRITE THIS ONLY ONCE
                        SCROLL UP FOR DETAILS

EOF
        @_offroad_util_warnings.each { |w| puts " - #{w}" }
        puts <<EOF

                         YOU HAVE BEEN WARNED
EOF
    end
  end
end

Capistrano::Configuration.instance(:must_exist).load do
  on :exit do
    _offroad_emit_warnings
  end
end
