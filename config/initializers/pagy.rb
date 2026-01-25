# frozen_string_literal: true

# Pagy initializer file (config/initializers/pagy.rb)
#
# This file is used to configure the Pagy gem.
# See https://ddnexus.github.io/pagy/ for more details.

require "pagy"

Pagy.options[:overflow] = :last_page
