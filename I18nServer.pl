#!/usr/bin/env perl
use Dancer;
use lib path(dirname(__FILE__), 'lib');
load_app 'I18nServer';
dance;
