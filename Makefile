PROJECT = cowolg
PROJECT_DESCRIPTION = Access logs for cowboy
PROJECT_VERSION = 0.0.1

DEPS = cowboy cth_readable jiffy

dep_cth_readable = git https://github.com/ferd/cth_readable.git v1.1.0

SHELL_OPTS = -sname $(PROJECT) -eval 'application:ensure_all_started($(PROJECT))'

TEST_ERLC_OPTS ?= +debug_info                                  \
				  +warn_export_vars                            \
				  +warn_shadow_vars                            \
				  +warn_obsolete_guard                         \
				  +'{parse_transform, cth_readable_transform}'

CT_OPTS = -ct_hooks cth_readable_shell

include erlang.mk
