#!/usr/bin/perl -w

use strict;
use warnings;
use Test::More tests => 12;
#use Test::More 'no_plan';
use File::Spec;
use Test::MockModule;
use Test::Exception;
use Test::NoWarnings;

my $CLASS;
BEGIN {
    $CLASS = 'App::Sqitch::Config';
    use_ok $CLASS or die;
}

isa_ok my $config = $CLASS->new, $CLASS, 'New config object';
is $config->confname, 'sqitch.conf', 'confname should be "sqitch.conf"';

is_deeply $config->global_file, File::Spec->catfile(
    $Config::Config{prefix}, 'etc', 'sqitch.conf'
), 'Defaulg global file name should be correct';

$ENV{SQITCH_SYSTEM_CONFIG} = 'FOO/BAR';
is $config->global_file, 'FOO/BAR',
    'Should preferably get SQITCH_SYSTEM_CONFIG file from global_file';
is $config->system_file, $config->global_file, 'system_file should alias global_file';

is $config->user_file, File::Spec->catfile(
    File::HomeDir->my_home, '.sqitch', 'sqitch.conf'
), 'Defaulg user file name should be correct';

$ENV{SQITCH_USER_CONFIG} = 'FOO/BAR';
is $config->user_file, 'FOO/BAR',
    'Should preferably get SQITCH_USER_CONFIG file from user_file';

is $config->dir_file, File::Spec->catfile(
    File::Spec->curdir, 'sqitch.conf'
), 'Directory file should be correct';

chdir 't';
is_deeply $config->get_section(section => 'core'), {
    db_name   => "widgetopolis",
    engine    => "pg",
    extension => "ddl",
    sql_dir   => "migrations",
}, 'get_section("core") should work';

is_deeply $config->get_section(section => 'core.pg'), {
    client => "/usr/local/pgsql/bin/psql",
    username => "theory",
}, 'get_section("core.pg") should work';
