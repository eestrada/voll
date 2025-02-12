# frozen_string_literal: true

require_relative 'voll/version'

# Namespace for all things VOLL related.
module Voll
  class Error < StandardError; end

  ws_re='[ \t]*'
  key_re='[a-zA-Z][a-zA-Z0-9_.]*'
  main_re="^(#{ws_re})(#{key_re})(#{ws_re})=(.*)\$"
  main_ltrim_value_re="^(#{ws_re})(#{key_re})(#{ws_re})=(#{ws_re})(.*)\$"
  comment_re="^(#{ws_re})(#.*)\$"
  blank_re="^(#{ws_re})\$"
  list_key_sedexp="s/#{main_re}/\\2/"
  list_value_sedexp="s/#{main_re}/\\4/"
  ltrim_sed_sedexp="s/^#{ws_re}//"
  rtrim_sed_sedexp="s/#{ws_re}$//"
end
