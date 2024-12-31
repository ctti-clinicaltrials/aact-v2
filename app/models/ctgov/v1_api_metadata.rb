module Ctgov
  class V1ApiMetadata < ApplicationRecord
    self.table_name = "support.ctgov_metadata"

    # connect to aact-core database
    establish_connection :external

    def ctgov_section
      path&.split(".")&.first&.gsub("Section", "")&.capitalize
    end


    def ctgov_module
      module_name = path&.split(".")&.second&.gsub("Module", "")
      module_name&.split(/(?=[A-Z])/)&.map(&:capitalize)&.join(" ")
    end


    def formatted_piece
      words = piece&.split(/(?=[A-Z])/)&.map(&:capitalize)
      combined_words = []
      words.each_with_index do |word, index|
        if word.length == 1 && index > 0 && words[index - 1].length == 1
          combined_words[-1] += word
        elsif word.length == 1 && index < words.length - 1 && words[index + 1].length == 1
          combined_words << word
        elsif word.length == 1 && index > 0 && combined_words.last.length > 1
          combined_words[-1] += word
        else
          combined_words << word
        end
      end
      combined_words.join(" ")
    end
  end
end
