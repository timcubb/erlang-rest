require 'rake/clean'

ERL_VER      = 'R14B04'
ERL_HOME     = "/usr/local/Cellar/erlang/#{ERL_VER}/bin"

abort "Please install Erlang #{ERL_VER}: brew update; brew install erlang" unless File.exist?(ERL_HOME)

# Set PATH to use newer Erlang
ENV["PATH"]  = ERL_HOME + ":" + ENV["PATH"]

APPS_DIRS    = Dir["apps/*"]
APPS_EBINS   = Dir["apps/*/ebin"]
DEPS_EBINS   = Dir["deps/*/ebin"]
LIBS_EBINS   = Dir["/usr/local/lib/erlang/lib/*/ebin"]

ALL_EBINS    = APPS_EBINS + DEPS_EBINS + LIBS_EBINS

APP_NAME     = "erlang_rest"
REL_TARGET   = "rel/#{APP_NAME}"

INCLUDE_DIRS = Dir["{apps,deps}/**/include"] unless defined?(INCLUDE_DIRS)

CLEAN.include("apps/**/ebin/*.beam")
CLOBBER.include(REL_TARGET, "deps/**/ebin/*.beam", "apps/**/doc")

FLAGS = %w(
+warn_unused_vars
+warn_export_all
+warn_shadow_vars
+warn_unused_import
+warn_unused_function
+warn_bif_clash
+warn_unused_record
+warn_deprecated_function
+warn_obsolete_guard
+strict_validation
+warn_export_vars
+warn_exported_vars
+warn_missing_spec
+warn_untyped_record
+debug_info
).join(' ') unless defined?(FLAGS)

ERLC_FLAGS = INCLUDE_DIRS.map { |i| "-I#{i}" }.join(' ') + " -Ideps #{FLAGS}" unless defined?(ERLC_FLAGS)

SRC = FileList['apps/**/src/*.erl']
OBJ = SRC.pathmap("%{src,ebin}X.beam")

rule ".beam" => ["%{ebin,src}X.erl"] do |t|
  ebin = File.dirname(t.name)
  sh "erlc -W #{ERLC_FLAGS} -o #{ebin} #{t.source}"
end

task :default => :compile

desc "Start dev environment"
task :dev => :generate do
  rel_dir = Dir["rel/#{APP_NAME}/releases/*/"].sort.last
  boot_file = File.join(rel_dir, APP_NAME)
  sh("erl -pa #{ALL_EBINS.join(' ')} -boot #{boot_file} -config rel/files/dev_app.config -s reloader -s toolbar")
end

desc "Watch files for changes and compile them"
task :watch do
  sh("watchr Watchfile")
end

desc "Get deps and compile"
task :compile => ['rebar:get_deps', 'rebar:compile']

desc "Compile, rel clean and generate"
task :generate => ['compile', 'relclean', 'rebar:generate']

task :default => :compile

task :relclean do
  rm_rf REL_TARGET
end

task "Start release console"
task :console do
  sh %Q{./rel/#{APP_NAME}/bin/#{APP_NAME} console -pa /usr/local/lib/erlang/lib/*/ebin -s toolbar}
end

namespace :rebar do
  task :compile do
    rebar :compile
  end

  task :clean do
    rebar :clean
  end

  task :build_plt do
    rebar 'build-plt', { skip_deps: true }
  end

  task :check_plt do
    rebar 'check_plt', { skip_deps: true }
  end

  task :dialyze do
    rebar :dialyze, { skip_deps: true }
  end

  task :xref do
    rebar :xref, { skip_deps: true }
  end

  task :get_deps do
    rebar 'get-deps'
  end

  task :update_deps do
    rebar 'update-deps'
  end

  task :delete_deps do
    rebar 'delete-deps'
  end

  task :generate do
    rebar :generate
  end

  def rebar(cmd, opts = {})
    rebar_opts = opts.map { |k, v| "#{k}=#{v}" }.join(' ')
    sh "./rebar #{cmd} #{rebar_opts}"
  end
end
